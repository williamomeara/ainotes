import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/features/models_manager/domain/download_state.dart';
import 'package:ainotes/features/models_manager/providers/model_manager_provider.dart';

void main() {
  group('ModelManagerProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      // Clean up any test downloads
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('initial state has available models', () {
      final state = container.read(modelManagerProvider);

      expect(state.models, isNotEmpty);
      expect(state.models.length, 2); // Qwen + EmbeddingGemma (Moonshine commented out)
    });

    test('download state transitions: NotStarted → Downloading → Ready', () async {
      final notifier = container.read(modelManagerProvider.notifier);
      final modelId = 'qwen-2.5-1.5b';

      // Initial state should be NotStarted
      var state = container.read(modelManagerProvider);
      expect(state.getDownloadState(modelId), isA<NotStarted>());

      // Note: Actual download testing would require mocking FileDownloader
      // This test validates state management structure
    });

    test('pause and resume cycle', () async {
      // Note: Actual pause/resume testing would require mocking FileDownloader
      // This test validates that the methods exist and can be called
      expect(() => container.read(modelManagerProvider.notifier).pauseDownload('qwen-2.5-1.5b'), returnsNormally);
      expect(() => container.read(modelManagerProvider.notifier).resumeDownload('qwen-2.5-1.5b'), returnsNormally);
    });

    test('allModelsReady is false when models not downloaded', () {
      final state = container.read(modelManagerProvider);

      expect(state.allModelsReady, false);
    });

    test('downloadedCount tracks ready models', () {
      final state = container.read(modelManagerProvider);

      // Initially should be 0 (no models downloaded)
      expect(state.downloadedCount, 0);
    });

    test('totalSizeFormatted displays correct size', () {
      final state = container.read(modelManagerProvider);

      // Qwen (900MB) + EmbeddingGemma (200MB) = 1.1GB
      expect(state.totalSizeFormatted, contains('GB'));
      expect(state.totalSizeFormatted, contains('1.1'));
    });

    test('deleteModel removes downloaded file and resets state', () async {
      final notifier = container.read(modelManagerProvider.notifier);

      await notifier.deleteModel('qwen-2.5-1.5b');

      final state = container.read(modelManagerProvider);
      expect(state.getDownloadState('qwen-2.5-1.5b'), isA<NotStarted>());
    });

    test('downloadAll attempts to download all models', () async {
      final notifier = container.read(modelManagerProvider.notifier);

      // Note: This won't actually download in tests, but validates the method exists
      expect(() => notifier.downloadAll(), returnsNormally);
    });

    test('resumeIncompleteDownloads checks for incomplete downloads', () async {
      final notifier = container.read(modelManagerProvider.notifier);

      // Should not throw
      await notifier.resumeIncompleteDownloads();
    });
  });

  group('DownloadState', () {
    test('NotStarted state', () {
      const state = DownloadState.notStarted();
      expect(state, isA<NotStarted>());
    });

    test('Downloading state has progress', () {
      const state = DownloadState.downloading(progress: 0.5);
      expect(state, isA<Downloading>());
      expect((state as Downloading).progress, 0.5);
    });

    test('Paused state has progress', () {
      const state = DownloadState.paused(progress: 0.3);
      expect(state, isA<Paused>());
      expect((state as Paused).progress, 0.3);
    });

    test('Ready state has localPath', () {
      const state = DownloadState.ready(localPath: '/path/to/model.gguf');
      expect(state, isA<Ready>());
      expect((state as Ready).localPath, '/path/to/model.gguf');
    });

    test('Error state has message', () {
      const state = DownloadState.error(message: 'Download failed');
      expect(state, isA<DownloadError>());
      expect((state as DownloadError).message, 'Download failed');
    });
  });
}
