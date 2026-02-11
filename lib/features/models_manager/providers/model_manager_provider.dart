import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  ModelManagerNotifier()
      : super(ModelManagerState(
          models: ModelRegistry.availableModels,
        )) {
    // In mock mode, all models are "ready" (using mock engines)
    _initMockState();
  }

  void _initMockState() {
    final states = <String, DownloadState>{};
    for (final model in state.models) {
      states[model.id] = const DownloadState.ready(localPath: 'mock://');
    }
    state = state.copyWith(downloadStates: states);
  }

  /// Simulate downloading a model.
  Future<void> downloadModel(String modelId) async {
    final newStates = Map<String, DownloadState>.from(state.downloadStates);
    newStates[modelId] = const DownloadState.downloading(progress: 0.0);
    state = state.copyWith(downloadStates: newStates);

    // Simulate download progress
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      final updatedStates =
          Map<String, DownloadState>.from(state.downloadStates);
      updatedStates[modelId] =
          DownloadState.downloading(progress: i / 10.0);
      state = state.copyWith(downloadStates: updatedStates);
    }

    final finalStates =
        Map<String, DownloadState>.from(state.downloadStates);
    finalStates[modelId] = const DownloadState.ready(localPath: 'mock://');
    state = state.copyWith(downloadStates: finalStates);
  }

  /// Delete a downloaded model.
  Future<void> deleteModel(String modelId) async {
    final newStates = Map<String, DownloadState>.from(state.downloadStates);
    newStates[modelId] = const DownloadState.notStarted();
    state = state.copyWith(downloadStates: newStates);
  }
}
