import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/engine_detector.dart';
import 'helpers/test_harness.dart';

import 'tests/intent_routing_test.dart';
import 'tests/llm_pipeline_test.dart';
import 'tests/note_persistence_test.dart';
import 'tests/rag_end_to_end_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestHarness harness;

  setUpAll(() async {
    debugPrint('=== AiNotes On-Device Integration Tests ===');
    debugPrint('');

    // Detect available engines
    final availability = await EngineDetector.detect();
    debugPrint('');
    debugPrint('[CONFIG] LLM available: ${availability.llmAvailable}');
    debugPrint('[CONFIG] Embedding available: ${availability.embeddingAvailable}');

    // Build harness (loads models)
    harness = await TestHarness.create(availability);
    debugPrint('[CONFIG] Using ${harness.isRealLLM ? "REAL" : "MOCK"} LLM');
    debugPrint(
        '[CONFIG] Using ${harness.isRealEmbedding ? "REAL" : "MOCK"} embeddings');
    debugPrint('');
  });

  tearDownAll(() async {
    await harness.dispose();
    debugPrint('=== Tests complete ===');
  });

  // --- Register all test groups ---

  // Intent routing (fast, no AI engines needed)
  registerIntentRoutingTests();

  // Note persistence (filesystem, no AI engines needed)
  registerNotePersistenceTests();

  // LLM pipeline (uses real or mock LLM)
  registerLLMPipelineTests(() => harness);

  // RAG end-to-end (uses all engines)
  registerRAGEndToEndTests(() => harness);
}
