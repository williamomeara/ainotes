import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/embedding_engine.dart';
import 'package:ainotes/core/ai/gemma_embedding_engine.dart';
import 'package:ainotes/core/ai/llamadart_engine.dart';
import 'package:ainotes/core/ai/llm_engine.dart';
import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/features/models_manager/domain/download_state.dart';
import 'package:ainotes/features/models_manager/providers/model_manager_provider.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';

void main() {
  group('PipelineProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('llmEngineProvider returns MockLLMEngine when model not ready', () {
      final engine = container.read(llmEngineProvider);
      expect(engine, isA<MockLLMEngine>());
    });

    test('embeddingEngineProvider returns MockEmbeddingEngine when model not ready',
        () {
      final engine = container.read(embeddingEngineProvider);
      expect(engine, isA<MockEmbeddingEngine>());
    });

    test('auto-switching: mock → native when LLM model ready', () {
      final mockContainer = ProviderContainer(
        overrides: [
          modelManagerProvider.overrideWithValue(
            _createMockModelManagerState(
              llmReady: true,
              embeddingReady: false,
            ),
          ),
        ],
      );

      final engine = mockContainer.read(llmEngineProvider);

      // Should return LlamaDartEngine when model is ready
      expect(engine, isA<LlamaDartEngine>());
      expect(engine, isNot(isA<MockLLMEngine>()));

      mockContainer.dispose();
    });

    test('auto-switching: mock → native when embedding model ready', () {
      final mockContainer = ProviderContainer(
        overrides: [
          modelManagerProvider.overrideWithValue(
            _createMockModelManagerState(
              llmReady: false,
              embeddingReady: true,
            ),
          ),
        ],
      );

      final engine = mockContainer.read(embeddingEngineProvider);

      // Should return GemmaEmbeddingEngine when model is ready
      expect(engine, isA<GemmaEmbeddingEngine>());
      expect(engine, isNot(isA<MockEmbeddingEngine>()));

      mockContainer.dispose();
    });

    test('auto-switching: both engines use native when both models ready', () {
      final mockContainer = ProviderContainer(
        overrides: [
          modelManagerProvider.overrideWithValue(
            _createMockModelManagerState(
              llmReady: true,
              embeddingReady: true,
            ),
          ),
        ],
      );

      final llmEngine = mockContainer.read(llmEngineProvider);
      final embEngine = mockContainer.read(embeddingEngineProvider);

      expect(llmEngine, isNot(isA<MockLLMEngine>()));
      expect(embEngine, isNot(isA<MockEmbeddingEngine>()));

      mockContainer.dispose();
    });

    test('processingPipelineProvider provides ProcessingPipeline', () {
      final pipeline = container.read(processingPipelineProvider);

      expect(pipeline, isNotNull);
    });

    test('vectorStoreProvider provides VectorStore singleton', () {
      final store1 = container.read(vectorStoreProvider);
      final store2 = container.read(vectorStoreProvider);

      expect(store1, same(store2)); // Should be singleton
    });
  });
}

/// Create mock model manager state for testing
ModelManagerState _createMockModelManagerState({
  required bool llmReady,
  required bool embeddingReady,
}) {
  return ModelManagerState(
    models: const [],
    downloadStates: {
      'qwen-2.5-1.5b': llmReady
          ? const DownloadState.ready(localPath: '/fake/path/model.gguf')
          : const DownloadState.notStarted(),
      'embedding-gemma-300m': embeddingReady
          ? const DownloadState.ready(localPath: 'gemma-embedder://')
          : const DownloadState.notStarted(),
    },
  );
}
