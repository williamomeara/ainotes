@Tags(['manual'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'package:ainotes/core/ai/gemma_embedding_engine.dart';
import 'package:ainotes/core/ai/llamadart_engine.dart';
import 'package:ainotes/core/rag/rag_engine.dart';
import 'package:ainotes/core/storage/vector_store.dart';
import 'package:ainotes/features/notes/domain/note.dart';

/// Manual end-to-end RAG integration test with real AI models.
/// Tests the complete flow: note → embed → query → answer.
void main() {
  group('Native RAG Integration (Manual)', () {
    late LlamaDartEngine llmEngine;
    late GemmaEmbeddingEngine embeddingEngine;
    late VectorStore vectorStore;
    late RAGEngine ragEngine;

    const llmModelPath =
        'test/manual_native/fixtures/qwen2.5-1.5b-instruct-q4_k_m.gguf';

    setUpAll(() async {
      // Verify LLM model file exists
      final file = File(llmModelPath);
      if (!await file.exists()) {
        fail(
          'LLM model file not found. See test/manual_native/README.md for setup.',
        );
      }

      // Initialize FlutterGemma
      await FlutterGemma.initialize();

      // Load engines
      llmEngine = LlamaDartEngine();
      await llmEngine.loadModel(llmModelPath);

      embeddingEngine = GemmaEmbeddingEngine();
      await embeddingEngine.loadModel('');

      vectorStore = VectorStore();

      ragEngine = RAGEngine(
        embeddingEngine: embeddingEngine,
        llmEngine: llmEngine,
        vectorStore: vectorStore,
      );
    });

    tearDownAll(() async {
      await llmEngine.dispose();
      await embeddingEngine.dispose();
    });

    test('end-to-end: create note → embed → query → answer', () async {
      // 1. Create a note
      const noteId = 'test-note-1';
      const noteText = 'Project deadline is March 31st. Need to complete design phase by March 15th.';

      // 2. Embed the note
      await ragEngine.indexNote(noteId, noteText);

      // 3. Query with a question
      final answer = await ragEngine.query('When is the project deadline?');

      // 4. Verify answer
      expect(answer.response, isNotEmpty);
      expect(answer.response.toLowerCase(), contains('march'));
      expect(answer.sources, isNotEmpty);
      expect(answer.sources.first.noteId, noteId);
    });

    test('answer cites correct source notes', () async {
      // Create multiple notes
      const note1 = ('note-1', 'Buy milk and eggs');
      const note2 = ('note-2', 'Call dentist tomorrow');
      const note3 = ('note-3', 'Get groceries for meal prep');

      await ragEngine.indexNote(note1.$1, note1.$2);
      await ragEngine.indexNote(note2.$1, note2.$2);
      await ragEngine.indexNote(note3.$1, note3.$2);

      // Query about groceries
      final answer = await ragEngine.query('What do I need to buy?');

      expect(answer.sources, isNotEmpty);

      // Should cite grocery-related notes (note1 and/or note3)
      final sourceIds = answer.sources.map((s) => s.noteId).toSet();
      expect(sourceIds, anyElement(anyOf('note-1', 'note-3')));
    });

    test('answer quality is coherent and relevant', () async {
      const noteText = '''
        Meeting notes from Jan 15:
        - Discussed Q1 revenue targets
        - Client wants quarterly reports
        - Follow up on contract renewal in March
      ''';

      await ragEngine.indexNote('meeting-note', noteText);

      final answer = await ragEngine.query('What did we discuss in the meeting?');

      expect(answer.response, isNotEmpty);
      expect(answer.response.toLowerCase(), anyOf(
        contains('revenue'),
        contains('quarterly'),
        contains('contract'),
      ));

      // Should be a complete sentence/paragraph, not fragments
      expect(answer.response.split(' ').length, greaterThan(5));
    });

    test('multiple sources are synthesized correctly', () async {
      const note1 = ('client-1', 'Client prefers morning meetings');
      const note2 = ('client-2', 'Client office is downtown');
      const note3 = ('client-3', 'Client project started in January');

      await ragEngine.indexNote(note1.$1, note1.$2);
      await ragEngine.indexNote(note2.$1, note2.$2);
      await ragEngine.indexNote(note3.$1, note3.$2);

      final answer = await ragEngine.query('Tell me about the client');

      expect(answer.sources.length, greaterThanOrEqualTo(2));

      // Answer should incorporate info from multiple sources
      final responseWords = answer.response.toLowerCase().split(' ').toSet();
      final hasMultipleTopics = (
        responseWords.contains('meeting') || responseWords.contains('morning')
      ) && (
        responseWords.contains('downtown') || responseWords.contains('office')
      );
      expect(hasMultipleTopics, true);
    });

    test('RAG handles no relevant notes gracefully', () async {
      // Index unrelated note
      await ragEngine.indexNote('unrelated', 'Buy milk and eggs');

      // Query about something totally different
      final answer = await ragEngine.query('What is the weather like?');

      expect(answer.response, isNotEmpty);
      // Should acknowledge no relevant notes or provide general response
    });

    test('semantic search finds notes even with different wording', () async {
      const noteText = 'Need to purchase organic dairy products from Whole Foods';
      await ragEngine.indexNote('dairy-note', noteText);

      final answer = await ragEngine.query('What groceries should I get?');

      expect(answer.sources, isNotEmpty);
      expect(answer.sources.first.noteId, 'dairy-note');
      expect(answer.response.toLowerCase(), anyOf(
        contains('dairy'),
        contains('organic'),
        contains('groceries'),
      ));
    });

    test('performance: RAG query completes in <5s', () async {
      // Index several notes
      for (int i = 0; i < 5; i++) {
        await ragEngine.indexNote('note-$i', 'Sample note content $i');
      }

      final stopwatch = Stopwatch()..start();
      await ragEngine.query('What are my notes about?');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('findSimilarNotes returns ranked results', () async {
      await ragEngine.indexNote('shopping-1', 'Buy milk and eggs');
      await ragEngine.indexNote('shopping-2', 'Get bread from bakery');
      await ragEngine.indexNote('meeting-1', 'Project meeting tomorrow');

      final results = await ragEngine.findSimilarNotes('grocery shopping');

      expect(results, isNotEmpty);
      expect(results.length, greaterThanOrEqualTo(2));

      // First results should be shopping-related
      expect(results.first.noteId, anyOf('shopping-1', 'shopping-2'));

      // Results should be sorted by similarity
      for (int i = 1; i < results.length; i++) {
        expect(results[i].similarity, lessThanOrEqualTo(results[i-1].similarity));
      }
    });

    test('removeNote deletes from vector index', () async {
      await ragEngine.indexNote('temp-note', 'Temporary note');

      var results = await ragEngine.findSimilarNotes('temporary');
      expect(results, isNotEmpty);

      await ragEngine.removeNote('temp-note');

      results = await ragEngine.findSimilarNotes('temporary');
      expect(results.where((r) => r.noteId == 'temp-note'), isEmpty);
    });
  });
}
