import 'package:flutter/foundation.dart';

import 'package:ainotes/core/ai/embedding_engine.dart';
import 'package:ainotes/core/ai/gemma_embedding_engine.dart';
import 'package:ainotes/core/ai/intent_classifier.dart';
import 'package:ainotes/core/ai/llamadart_engine.dart';
import 'package:ainotes/core/ai/llm_engine.dart';
import 'package:ainotes/core/ai/llm_intent_classifier.dart';
import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_intent_classifier.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/core/rag/rag_engine.dart';
import 'package:ainotes/core/storage/vector_store.dart';
import 'package:ainotes/features/processing/domain/processing_pipeline.dart';

import 'engine_detector.dart';

/// Pre-configured test harness with detected (or mock) engines.
///
/// Bypasses Riverpod entirely — creates engines and pipeline directly.
class TestHarness {
  final EngineAvailability availability;
  final LLMEngine llmEngine;
  final EmbeddingEngine embeddingEngine;
  final VectorStore vectorStore;
  late final ProcessingPipeline pipeline;
  late final RAGEngine ragEngine;
  late final IntentClassifier intentClassifier;

  bool get isRealLLM => llmEngine is LlamaDartEngine;
  bool get isRealEmbedding => embeddingEngine is GemmaEmbeddingEngine;

  TestHarness._({
    required this.availability,
    required this.llmEngine,
    required this.embeddingEngine,
    required this.vectorStore,
  }) {
    pipeline = ProcessingPipeline(
      llmEngine: llmEngine,
      embeddingEngine: embeddingEngine,
      vectorStore: vectorStore,
    );
    ragEngine = RAGEngine(
      llmEngine: llmEngine,
      embeddingEngine: embeddingEngine,
      vectorStore: vectorStore,
    );
    intentClassifier = isRealLLM
        ? LLMIntentClassifier(llmEngine: llmEngine, modelPath: '')
        : MockIntentClassifier();
  }

  /// Create and initialise a test harness, loading models as needed.
  static Future<TestHarness> create(EngineAvailability availability) async {
    // --- LLM ---
    late final LLMEngine llm;
    if (availability.llmAvailable) {
      debugPrint('[HARNESS] Loading real LLM from ${availability.llmModelPath}');
      llm = LlamaDartEngine();
      await llm.loadModel(availability.llmModelPath!);
      debugPrint('[HARNESS] Real LLM loaded');
    } else {
      debugPrint('[HARNESS] Using MockLLMEngine');
      llm = MockLLMEngine();
      await llm.loadModel('');
    }

    // --- Embedding ---
    EmbeddingEngine emb;
    if (availability.embeddingAvailable) {
      debugPrint('[HARNESS] Loading real GemmaEmbeddingEngine');
      emb = GemmaEmbeddingEngine();
      try {
        await emb.loadModel('');
        debugPrint('[HARNESS] Real embedding engine loaded');
      } catch (e) {
        debugPrint('[HARNESS] Real embedding load failed, falling back to mock: $e');
        emb = MockEmbeddingEngine();
        await emb.loadModel('');
      }
    } else {
      debugPrint('[HARNESS] Using MockEmbeddingEngine');
      emb = MockEmbeddingEngine();
      await emb.loadModel('');
    }

    return TestHarness._(
      availability: availability,
      llmEngine: llm,
      embeddingEngine: emb,
      vectorStore: InMemoryVectorStore(),
    );
  }

  /// Clean up resources.
  Future<void> dispose() async {
    debugPrint('[HARNESS] Disposing engines...');
    await llmEngine.dispose();
    await embeddingEngine.dispose();
    await vectorStore.clear();
    debugPrint('[HARNESS] Disposed');
  }
}
