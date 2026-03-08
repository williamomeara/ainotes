import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  /// Returns the first model that is actively downloading, or null.
  (MLModel, Downloading)? get activeDownload {
    for (final model in models) {
      final ds = downloadStates[model.id];
      if (ds is Downloading) return (model, ds);
    }
    return null;
  }

  int get downloadingCount =>
      downloadStates.values.whereType<Downloading>().length;

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
  ModelManagerNotifier()
      : super(ModelManagerState(
          models: ModelRegistry.availableModels,
        )) {
    _init();
  }

  Future<void> _init() async {
    await _initDownloader();
    await _clearStaleTasks();
    await _checkLocalModels();
  }

  /// Cancel all leftover tasks and wipe the downloader DB to prevent zombie
  /// tasks from prior sessions from accumulating and fighting new downloads.
  Future<void> _clearStaleTasks() async {
    await FileDownloader().cancelAll();
    await FileDownloader().database.deleteAllRecords();
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

    // Use callback API instead of the .updates stream. flutter_gemma's
    // SmartDownloader internally calls FileDownloader().updates.asBroadcastStream()
    // which fails if anyone has already called .listen() on that single-subscription
    // stream. The callback API is independent of the stream and avoids the conflict.
    FileDownloader().registerCallbacks(
      taskStatusCallback: _handleStatusUpdate,
      taskProgressCallback: _handleProgressUpdate,
    );
  }

  void _handleProgressUpdate(TaskProgressUpdate update) {
    final modelId = update.task.metaData;
    if (modelId.isEmpty) return;

    if (update.progress >= 0) {
      final currentState = state.getDownloadState(modelId);
      final startTime = currentState is Downloading
          ? (currentState.startTime ?? DateTime.now())
          : DateTime.now();

      final model = state.models.firstWhere((m) => m.id == modelId);
      final totalBytes = model.sizeBytes;
      final downloadedBytes = (update.progress * totalBytes).round();

      _updateState(
        modelId,
        DownloadState.downloading(
          progress: update.progress,
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
          startTime: startTime,
        ),
      );
    }
  }

  void _handleStatusUpdate(TaskStatusUpdate update) {
    final modelId = update.task.metaData;
    if (modelId.isEmpty) return;

    switch (update.status) {
      case TaskStatus.complete:
        _onDownloadComplete(modelId, update.task);
      case TaskStatus.failed:
        final exception = update.exception;
        String errorMsg;

        if (exception is TaskHttpException) {
          final code = exception.httpResponseCode;
          if (code == 401 || code == 403) {
            errorMsg =
                'Authentication required (HTTP $code). Model URL may be gated.';
          } else if (code == 404) {
            errorMsg = 'Model file not found (HTTP 404). URL may have changed.';
          } else {
            errorMsg = 'HTTP error $code: ${exception.description}';
          }
        } else {
          errorMsg = exception?.description ?? 'Download failed';
        }

        _updateState(modelId, DownloadState.error(message: errorMsg));
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
        // Check if both embedding model + tokenizer files exist on disk
        if (await GemmaEmbeddingEngine.isInstalled()) {
          final paths = await GemmaEmbeddingEngine.localFilePaths();
          states[model.id] = DownloadState.ready(localPath: paths.modelPath);
        } else {
          states[model.id] = const DownloadState.notStarted();
        }
        continue;
      }
      final path = await _modelFilePath(model);
      if (path != null) {
        states[model.id] = DownloadState.ready(localPath: path);
      } else {
        states[model.id] = const DownloadState.notStarted();
      }
    }
    state = state.copyWith(downloadStates: states);
  }

  /// Pre-flight check: verify URL is accessible before starting a download.
  /// Returns null if OK, or an error message string.
  Future<String?> _preflightCheck(String url) async {
    try {
      final response = await http
          .head(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      final code = response.statusCode;
      // 200 = direct, 302/301 = CDN redirect (both fine)
      if (code >= 200 && code < 400) return null;
      if (code == 401 || code == 403) {
        return 'Authentication required for this model URL (HTTP $code).';
      }
      if (code == 404) {
        return 'Model file not found at URL (HTTP $code).';
      }
      return 'Unexpected HTTP $code from model URL.';
    } on SocketException {
      return 'No network connection. Check your internet and retry.';
    } on HttpException catch (e) {
      return 'Network error: ${e.message}';
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return 'Connection timed out. Check your internet and retry.';
      }
      return 'Network error: $e';
    }
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

    // Pre-flight: verify URL is accessible before enqueuing download
    final preflightError = await _preflightCheck(url);
    if (preflightError != null) {
      _updateState(modelId, DownloadState.error(message: preflightError));
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

    // Use regular DownloadTask instead of ParallelDownloadTask — parallel
    // chunks are fragile on unstable WiFi (band-hopping kills all chunks
    // simultaneously, triggering a cascade of WorkManager reschedules).
    final task = DownloadTask(
      url: url,
      filename: fileName,
      directory: 'models',
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      allowPause: true,
      retries: 5,
      requiresWiFi: false,
      metaData: modelId,
    );

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

  /// Download embedding model + tokenizer directly via FileDownloader, then
  /// register with flutter_gemma via file paths. This bypasses flutter_gemma's
  /// SmartDownloader which has a broadcast stream bug in v0.12.3.
  Future<void> _downloadEmbeddingModel(String modelId) async {
    // Pre-flight: verify both URLs are accessible before starting
    final modelError =
        await _preflightCheck(GemmaEmbeddingEngine.modelUrl);
    if (modelError != null) {
      _updateState(modelId, DownloadState.error(message: modelError));
      return;
    }
    final tokenizerError =
        await _preflightCheck(GemmaEmbeddingEngine.tokenizerUrl);
    if (tokenizerError != null) {
      _updateState(modelId, DownloadState.error(message: tokenizerError));
      return;
    }

    final embeddingStartTime = DateTime.now();
    final model = state.models.firstWhere((m) => m.id == modelId);
    final totalBytes = model.sizeBytes;
    _updateState(modelId, DownloadState.downloading(
      progress: 0.0,
      totalBytes: totalBytes,
      startTime: embeddingStartTime,
    ));

    try {
      await GemmaEmbeddingEngine.installModel(
        onModelProgress: (progress) {
          if (!mounted) return;
          final p = progress * 0.9;
          _updateState(modelId, DownloadState.downloading(
            progress: p,
            downloadedBytes: (p * totalBytes).round(),
            totalBytes: totalBytes,
            startTime: embeddingStartTime,
          ));
        },
        onTokenizerProgress: (progress) {
          if (!mounted) return;
          final p = 0.9 + progress * 0.1;
          _updateState(modelId, DownloadState.downloading(
            progress: p,
            downloadedBytes: (p * totalBytes).round(),
            totalBytes: totalBytes,
            startTime: embeddingStartTime,
          ));
        },
      );

      if (!mounted) return;
      final paths = await GemmaEmbeddingEngine.localFilePaths();
      _updateState(modelId, DownloadState.ready(localPath: paths.modelPath));
    } catch (e) {
      if (!mounted) return;

      String errorMsg = 'Install failed: ${e.toString()}';
      if (e.toString().contains('network') ||
          e.toString().contains('Network')) {
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

    final model = state.models.firstWhere((m) => m.id == modelId);
    if (model.type == MLModelType.embedding) {
      // Delete both model and tokenizer files
      final paths = await GemmaEmbeddingEngine.localFilePaths();
      final modelFile = File(paths.modelPath);
      if (await modelFile.exists()) await modelFile.delete();
      final tokenizerFile = File(paths.tokenizerPath);
      if (await tokenizerFile.exists()) await tokenizerFile.delete();
    } else {
      final currentState = state.getDownloadState(modelId);
      if (currentState is Ready) {
        final file = File(currentState.localPath);
        if (await file.exists()) await file.delete();
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

  /// Get the local file path for a model, checking multiple locations.
  /// Returns null if the model file is not found anywhere.
  Future<String?> _modelFilePath(MLModel model) async {
    if (model.type == MLModelType.embedding) return null;

    final url = model.downloadUrl;
    if (url == null) return null;

    final fileName = Uri.parse(url).pathSegments.last;

    // Primary: app documents dir
    final dir = await getApplicationDocumentsDirectory();
    final primary = '${dir.path}/models/$fileName';
    if (await File(primary).exists()) return primary;

    // Dev fallback: adb push target
    final devPath = '/data/local/tmp/$fileName';
    if (await File(devPath).exists()) return devPath;

    return null;
  }

  @override
  void dispose() {
    FileDownloader().unregisterCallbacks();
    super.dispose();
  }
}
