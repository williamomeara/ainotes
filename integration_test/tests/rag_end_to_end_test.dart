import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/assertions.dart';
import '../helpers/test_data.dart';
import '../helpers/test_harness.dart';

/// Register RAG end-to-end tests.
///
/// setUpAll: process all 7 test notes through the pipeline, then index them.
/// Each test queries the RAG engine and checks the answer.
void registerRAGEndToEndTests(TestHarness Function() getHarness) {
  group('RAG End-to-End', () {
    late TestHarness harness;

    /// Note IDs assigned during setUpAll, keyed by testNotes index.
    final noteIds = <int, String>{};

    setUpAll(() async {
      harness = getHarness();
      debugPrint('[RAG] Indexing ${testNotes.length} test notes...');

      for (var i = 0; i < testNotes.length; i++) {
        final note = testNotes[i];
        final noteId = 'rag-test-$i';
        noteIds[i] = noteId;

        // Process through pipeline to get rewritten text
        final result = await harness.pipeline.process(note.rawInput).timeout(
            harness.isRealLLM
                ? const Duration(seconds: 120)
                : const Duration(seconds: 10));

        // Index in vector store via RAG engine
        await harness.ragEngine.indexNote(
          noteId: noteId,
          text: result.rewrittenText,
        );

        debugPrint(
            '[RAG] Indexed note $i ("${note.description}") as $noteId');
      }

      debugPrint(
          '[RAG] All notes indexed. Vector store chunks: ${harness.vectorStore.chunkCount}');
    });

    for (var i = 0; i < testQueries.length; i++) {
      final query = testQueries[i];

      test('answers "${query.question}"', () async {
        final stopwatch = Stopwatch()..start();

        final result = await harness.ragEngine.query(query.question).timeout(
            harness.isRealLLM
                ? const Duration(seconds: 120)
                : const Duration(seconds: 15));

        stopwatch.stop();
        debugPrint(
            '[PERF] RAG query "${query.question}": ${stopwatch.elapsedMilliseconds}ms');
        debugPrint('[RAG] Answer: ${result.answer}');
        debugPrint('[RAG] Sources: ${result.sourceNoteIds}');

        final expectedSourceIds =
            query.expectedSourceIndices.map((idx) => noteIds[idx]!).toList();

        assertRAGAnswer(
          answer: result.answer,
          sourceNoteIds: result.sourceNoteIds,
          expectedKeywords: query.expectedAnswerKeywords,
          expectedSourceIds: expectedSourceIds,
          isRealLLM: harness.isRealLLM,
          isRealEmbedding: harness.isRealEmbedding,
        );
      }, timeout: const Timeout(Duration(seconds: 180)));
    }

    test('findSimilar returns related notes', () async {
      final similar = await harness.ragEngine
          .findSimilar('grocery shopping list items to buy');

      debugPrint('[RAG] findSimilar results: $similar');

      expect(similar.isNotEmpty, isTrue,
          reason: 'Should find at least one similar note');

      if (harness.isRealEmbedding) {
        // Real embeddings should rank the grocery note highest
        expect(similar.first, equals(noteIds[0]),
            reason: 'Grocery note should be most similar to grocery query');
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('handles irrelevant query gracefully', () async {
      final result = await harness.ragEngine
          .query('What is the capital of France?')
          .timeout(harness.isRealLLM
              ? const Duration(seconds: 120)
              : const Duration(seconds: 15));

      debugPrint('[RAG] Irrelevant query answer: ${result.answer}');

      // Should still return something (even if it says "not found")
      expect(result.answer.isNotEmpty, isTrue,
          reason: 'Should return an answer even for irrelevant queries');
    }, timeout: const Timeout(Duration(seconds: 180)));
  });
}
