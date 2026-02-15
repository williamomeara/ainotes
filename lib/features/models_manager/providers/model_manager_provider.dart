import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/ai/gemma_embedding_engine.dart';
import '../domain/download_state.dart';
import '../domain/ml_model.dart';

/// State for the model manager.
class ModelManagerState {
  final List<MLModel> models;
  final Map<String, DownloadState> downloadStates;

  const ModelManagerState({
    this.models = const [],
    this.downloadStates = const {},
  });

  ModelManagerState copyWith({
    List<MLModel>? models,
    Map<String, DownloadState>? downloadStates,
  }) {
    return ModelManagerState(
      models: models ?? this.models,
      downloadStates: downloadStates ?? this.downloadStates,
    );
  }

  DownloadState getDownloadState(String modelId) {
    return downloadStates[modelId] ?? const DownloadState.notStarted();
  }

  bool get allModelsReady => models.every(
        (m) => downloadStates[m.id] is Ready,
      );

  int get downloadedCount =>
      downloadStates.values.whereType<Ready>().length;

  String get totalSizeFormatted {
    final totalBytes = models.fold<int>(0, (sum, m) => sum + m.sizeBytes);
    if (totalBytes >= 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(totalBytes / (1024 * 1024)).round()} MB';
  }
}

final modelManagerProvider =
    StateNotifierProvider<ModelManagerNotifier, ModelManagerState>((ref) {
  return ModelManagerNotifier();
});

class ModelManagerNotifier extends StateNotifier<ModelManagerState> {
  StreamSubscription<TaskUpdate>? _updateSubscription;

  ModelManagerNotifier()
      : super(ModelManagerState(
          models: ModelRegistry.availableModels,
        )) {
    _init();
  }

  Future<void> _init() async {
    await _initDownloader();
    await _checkLocalModels();
    await resumeIncompleteDownloads();
  }

  Future<void> _initDownloader() async {
    await FileDownloader().trackTasks();

    FileDownloader().configureNotification(
      running: const TaskNotification(
        'Downloading {filename}',
        '{progress}%',
      ),
      complete: const TaskNotification(
        'Download complete',
        '{filename} ready',
      ),
      error: const TaskNotification(
        'Download failed',
        'Tap to retry',
      ),
      paused: const TaskNotification(
        'Download paused',
        '{progress}% complete',
      ),
      progressBar: true,
    );

    _updateSubscription = FileDownloader().updates.listen(_handleUpdate);
  }

  void _handleUpdate(TaskUpdate update) {
    final modelId = update.task.metaData;
    if (modelId.isEmpty) return;

    if (update is TaskProgressUpdate) {
      if (update.progress >= 0) {
        _updateState(
          modelId,
          DownloadState.downloading(progress: update.progress),
        );
      }
    } else if (update is TaskStatusUpdate) {
      switch (update.status) {
        case TaskStatus.complete:
          _onDownloadComplete(modelId, update.task);
        case TaskStatus.failed:
          _updateState(
            modelId,
            DownloadState.error(
              message: update.exception?.description ?? 'Download failed',
            ),
          );
        case TaskStatus.paused:
          final currentState = state.getDownloadState(modelId);
          final progress =
              currentState is Downloading ? currentState.progress : 0.0;
          _updateState(modelId, DownloadState.paused(progress: progress));
        case TaskStatus.canceled:
          _updateState(modelId, const DownloadState.notStarted());
        case TaskStatus.enqueued:
        case TaskStatus.running:
          // Already handled by progress updates
          break;
        case TaskStatus.notFound:
          _updateState(
            modelId,
            const DownloadState.error(message: 'Task not found'),
          );
        case TaskStatus.waitingToRetry:
          // Keep showing current progress during retry wait
          break;
      }
    }
  }

  Future<void> _onDownloadComplete(String modelId, Task task) async {
    final filePath = await task.filePath();

    // Validate file exists and has expected size
    final file = File(filePath);
    if (!await file.exists()) {
      _updateState(
        modelId,
        const DownloadState.error(
          message: 'Download completed but file not found',
        ),
      );
      return;
    }

    final model = state.models.firstWhere((m) => m.id == modelId);
    final actualSize = await file.length();
    final expectedSize = model.sizeBytes;

    // Allow 5% variance due to compression/headers
    if ((actualSize - expectedSize).abs() > expectedSize * 0.05) {
      _updateState(
        modelId,
        DownloadState.error(
          message:
              'File size mismatch (got ${_formatBytes(actualSize)}, expected ${_formatBytes(expectedSize)})',
        ),
      );
      return;
    }

    _updateState(modelId, DownloadState.ready(localPath: filePath));
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).round()} MB';
  }

  /// Check which models are already downloaded locally.
  Future<void> _checkLocalModels() async {
    final states = <String, DownloadState>{};
    for (final model in state.models) {
      if (model.type == MLModelType.embedding) {
        // flutter_gemma manages its own storage; skip file check
        states[model.id] = const DownloadState.notStarted();
        continue;
      }
      final path = await _modelFilePath(model);
      if (path != null && await File(path).exists()) {
        states[model.id] = DownloadState.ready(localPath: path);
      } else {
        states[model.id] = const DownloadState.notStarted();
      }
    }
    state = state.copyWith(downloadStates: states);
  }

  /// Download a model.
  Future<void> downloadModel(String modelId) async {
    final model = state.models.firstWhere((m) => m.id == modelId);

    // Embedding model uses flutter_gemma's built-in installer
    if (model.type == MLModelType.embedding) {
      await _downloadEmbeddingModel(modelId);
      return;
    }

    final url = model.downloadUrl;
    if (url == null || url.isEmpty) {
      _updateState(
        modelId,
        const DownloadState.error(message: 'No download URL configured'),
      );
      return;
    }

    _updateState(modelId, const DownloadState.downloading(progress: 0.0));

    // Ensure models directory exists (background_downloader doesn't auto-create)
    final appDocDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDocDir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }

    final fileName = Uri.parse(url).pathSegments.last;

    // Use ParallelDownloadTask for large files (>500MB), regular for smaller
    final Task task;
    if (model.sizeBytes > 500 * 1024 * 1024) {
      task = ParallelDownloadTask(
        url: url,
        filename: fileName,
        directory: 'models',
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        allowPause: true,
        retries: 5,
        requiresWiFi: false, // Allow cellular downloads for development/testing
        chunks: 4,
        metaData: modelId,
      );
    } else {
      task = DownloadTask(
        url: url,
        filename: fileName,
        directory: 'models',
        baseDirectory: BaseDirectory.applicationDocuments,
        updates: Updates.statusAndProgress,
        allowPause: true,
        retries: 5,
        requiresWiFi: false, // Allow cellular downloads for development/testing
        metaData: modelId,
      );
    }

    await FileDownloader().enqueue(task);
  }

  /// Download all models that aren't already ready.
  Future<void> downloadAll() async {
    for (final model in state.models) {
      final ds = state.getDownloadState(model.id);
      if (ds is! Ready) {
        await downloadModel(model.id);
      }
    }
  }

  /// Pause a downloading model.
  Future<void> pauseDownload(String modelId) async {
    final records = await FileDownloader().database.allRecords();
    for (final record in records) {
      if (record.task.metaData == modelId && record.task is DownloadTask) {
        await FileDownloader().pause(record.task as DownloadTask);
        break;
      }
    }
  }

  /// Resume a paused or failed download.
  Future<void> resumeDownload(String modelId) async {
    final records = await FileDownloader().database.allRecords();
    for (final record in records) {
      if (record.task.metaData == modelId && record.task is DownloadTask) {
        if (record.status == TaskStatus.paused) {
          await FileDownloader().resume(record.task as DownloadTask);
        } else {
          // Re-enqueue for failed/other states
          await downloadModel(modelId);
        }
        return;
      }
    }
    // No record found, start fresh
    await downloadModel(modelId);
  }

  /// Resume any incomplete downloads from a previous session.
  Future<void> resumeIncompleteDownloads() async {
    final records = await FileDownloader().database.allRecords();
    for (final record in records) {
      final modelId = record.task.metaData;
      if (modelId.isEmpty) continue;

      if (record.status == TaskStatus.paused &&
          record.task is DownloadTask) {
        _updateState(modelId, const DownloadState.paused(progress: 0.0));
        await FileDownloader().resume(record.task as DownloadTask);
      } else if (record.status == TaskStatus.running ||
          record.status == TaskStatus.enqueued) {
        _updateState(
            modelId, const DownloadState.downloading(progress: 0.0));
      } else if (record.status == TaskStatus.complete) {
        final filePath = await record.task.filePath();
        _updateState(modelId, DownloadState.ready(localPath: filePath));
      }
    }
  }

  /// Download embedding model via flutter_gemma's built-in installer.
  /// Note: Does not retry on failure to avoid stream listener errors.
  Future<void> _downloadEmbeddingModel(String modelId) async {
    // Check if FlutterGemma plugin is available
    final prefs = await SharedPreferences.getInstance();
    final gemmaAvailable = prefs.getBool('flutter_gemma_available') ?? false;

    if (!gemmaAvailable) {
      _updateState(
        modelId,
        const DownloadState.error(
          message:
              'FlutterGemma plugin not available. Restart app or reinstall.',
        ),
      );
      return;
    }

    _updateState(modelId, const DownloadState.downloading(progress: 0.0));

    try {
      // Use flutter_gemma's installer which handles auth/licensing
      await GemmaEmbeddingEngine.installModel(
        onModelProgress: (progress) {
          if (!mounted) return;
          _updateState(
              modelId, DownloadState.downloading(progress: progress * 0.9));
        },
        onTokenizerProgress: (progress) {
          if (!mounted) return;
          _updateState(modelId,
              DownloadState.downloading(progress: 0.9 + progress * 0.1));
        },
      );

      if (!mounted) return;
      _updateState(
          modelId, const DownloadState.ready(localPath: 'gemma-embedder://'));
    } catch (e) {
      if (!mounted) return;

      // Provide actionable error messages
      String errorMsg = 'Install failed: ${e.toString()}';
      if (e.toString().contains('not installed')) {
        errorMsg =
            'FlutterGemma not properly installed. Try restarting the app.';
      } else if (e.toString().contains('network')) {
        errorMsg = 'Network error. Check connection and retry.';
      }

      _updateState(modelId, DownloadState.error(message: errorMsg));
    }
  }

  /// Delete a downloaded model.
  Future<void> deleteModel(String modelId) async {
    // Cancel any active download first
    final records = await FileDownloader().database.allRecords();
    for (final record in records) {
      if (record.task.metaData == modelId) {
        await FileDownloader().cancelTaskWithId(record.task.taskId);
      }
    }

    final currentState = state.getDownloadState(modelId);
    if (currentState is Ready &&
        currentState.localPath != 'gemma-embedder://') {
      final file = File(currentState.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _updateState(modelId, const DownloadState.notStarted());
  }

  void _updateState(String modelId, DownloadState downloadState) {
    if (!mounted) return;
    final newStates = Map<String, DownloadState>.from(state.downloadStates);
    newStates[modelId] = downloadState;
    state = state.copyWith(downloadStates: newStates);
  }

  /// Get the expected local file path for a model.
  Future<String?> _modelFilePath(MLModel model) async {
    if (model.type == MLModelType.embedding) return null;

    final url = model.downloadUrl;
    if (url == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = Uri.parse(url).pathSegments.last;
    return '${dir.path}/models/$fileName';
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }
}
