@Tags(['manual'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'package:ainotes/core/ai/gemma_embedding_engine.dart';
import 'package:ainotes/core/ai/llamadart_engine.dart';
import 'package:ainotes/core/rag/rag_engine.dart';
import 'package:ainotes/core/storage/vector_store.dart';

/// Manual end-to-end RAG integration test with real AI models.
/// Tests the complete flow: note → embed → query → answer.
void main() {
  group('Native RAG Integration (Manual)', () {
    late LlamaDartEngine llmEngine;
    late GemmaEmbeddingEngine embeddingEngine;
    late InMemoryVectorStore vectorStore;
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

      vectorStore = InMemoryVectorStore();

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
      await ragEngine.indexNote(noteId: noteId, text: noteText);

      // 3. Query with a question
      final answer = await ragEngine.query('When is the project deadline?');

      // 4. Verify answer
      expect(answer.answer, isNotEmpty);
      expect(answer.answer.toLowerCase(), contains('march'));
      expect(answer.sourceNoteIds, isNotEmpty);
      expect(answer.sourceNoteIds.first, noteId);
    });

    test('answer cites correct source notes', () async {
      // Create multiple notes
      const note1 = ('note-1', 'Buy milk and eggs');
      const note2 = ('note-2', 'Call dentist tomorrow');
      const note3 = ('note-3', 'Get groceries for meal prep');

      await ragEngine.indexNote(noteId: note1.$1, text: note1.$2);
      await ragEngine.indexNote(noteId: note2.$1, text: note2.$2);
      await ragEngine.indexNote(noteId: note3.$1, text: note3.$2);

      // Query about groceries
      final answer = await ragEngine.query('What do I need to buy?');

      expect(answer.sourceNoteIds, isNotEmpty);

      // Should cite grocery-related notes (note1 and/or note3)
      expect(answer.sourceNoteIds, anyElement(anyOf('note-1', 'note-3')));
    });

    test('answer quality is coherent and relevant', () async {
      const noteText = '''
        Meeting notes from Jan 15:
        - Discussed Q1 revenue targets
        - Client wants quarterly reports
        - Follow up on contract renewal in March
      ''';

      await ragEngine.indexNote(noteId: 'meeting-note', text: noteText);

      final answer = await ragEngine.query('What did we discuss in the meeting?');

      expect(answer.answer, isNotEmpty);
      expect(answer.answer.toLowerCase(), anyOf(
        contains('revenue'),
        contains('quarterly'),
        contains('contract'),
      ));

      // Should be a complete sentence/paragraph, not fragments
      expect(answer.answer.split(' ').length, greaterThan(5));
    });

    test('multiple sources are synthesized correctly', () async {
      const note1 = ('client-1', 'Client prefers morning meetings');
      const note2 = ('client-2', 'Client office is downtown');
      const note3 = ('client-3', 'Client project started in January');

      await ragEngine.indexNote(noteId: note1.$1, text: note1.$2);
      await ragEngine.indexNote(noteId: note2.$1, text: note2.$2);
      await ragEngine.indexNote(noteId: note3.$1, text: note3.$2);

      final answer = await ragEngine.query('Tell me about the client');

      expect(answer.sourceNoteIds.length, greaterThanOrEqualTo(2));

      // Answer should incorporate info from multiple sources
      final responseWords = answer.answer.toLowerCase().split(' ').toSet();
      final hasMultipleTopics = (
        responseWords.contains('meeting') || responseWords.contains('morning')
      ) && (
        responseWords.contains('downtown') || responseWords.contains('office')
      );
      expect(hasMultipleTopics, true);
    });

    test('RAG handles no relevant notes gracefully', () async {
      // Index unrelated note
      await ragEngine.indexNote(noteId: 'unrelated', text: 'Buy milk and eggs');

      // Query about something totally different
      final answer = await ragEngine.query('What is the weather like?');

      expect(answer.answer, isNotEmpty);
      // Should acknowledge no relevant notes or provide general response
    });

    test('semantic search finds notes even with different wording', () async {
      const noteText = 'Need to purchase organic dairy products from Whole Foods';
      await ragEngine.indexNote(noteId: 'dairy-note', text: noteText);

      final answer = await ragEngine.query('What groceries should I get?');

      expect(answer.sourceNoteIds, isNotEmpty);
      expect(answer.sourceNoteIds.first, 'dairy-note');
      expect(answer.answer.toLowerCase(), anyOf(
        contains('dairy'),
        contains('organic'),
        contains('groceries'),
      ));
    });

    test('performance: RAG query completes in <5s', () async {
      // Index several notes
      for (int i = 0; i < 5; i++) {
        await ragEngine.indexNote(noteId: 'note-$i', text: 'Sample note content $i');
      }

      final stopwatch = Stopwatch()..start();
      await ragEngine.query('What are my notes about?');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('findSimilar returns ranked results', () async {
      await ragEngine.indexNote(noteId: 'shopping-1', text: 'Buy milk and eggs');
      await ragEngine.indexNote(noteId: 'shopping-2', text: 'Get bread from bakery');
      await ragEngine.indexNote(noteId: 'meeting-1', text: 'Project meeting tomorrow');

      final results = await ragEngine.findSimilar('grocery shopping');

      expect(results, isNotEmpty);
      expect(results.length, greaterThanOrEqualTo(2));

      // First results should be shopping-related
      expect(results.first, anyOf('shopping-1', 'shopping-2'));
    });

    test('removeNote deletes from vector index', () async {
      await ragEngine.indexNote(noteId: 'temp-note', text: 'Temporary note');

      var results = await ragEngine.findSimilar('temporary');
      expect(results, isNotEmpty);

      await ragEngine.removeNote('temp-note');

      results = await ragEngine.findSimilar('temporary');
      expect(results.where((id) => id == 'temp-note'), isEmpty);
    });
  });
}
