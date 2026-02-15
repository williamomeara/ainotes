import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/core/rag/rag_engine.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_category.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';

void main() {
  group('Note to Search Flow Integration', () {
    late ProviderContainer container;
    late RAGEngine ragEngine;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          llmEngineProvider.overrideWithValue(MockLLMEngine()),
          embeddingEngineProvider.overrideWithValue(MockEmbeddingEngine()),
        ],
      );

      final pipeline = container.read(processingPipelineProvider);
      ragEngine = RAGEngine(
        embeddingEngine: container.read(embeddingEngineProvider),
        llmEngine: container.read(llmEngineProvider),
        vectorStore: container.read(vectorStoreProvider),
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('create note → embed → semantic search finds it', () async {
      // Create note
      final processingNotifier = container.read(processingJobProvider.notifier);
      final note = await processingNotifier.processInput(
        'Buy organic milk and eggs from the grocery store',
        source: NoteSource.text,
      );

      expect(note, isNotNull);

      // Embed the note
      final pipeline = container.read(processingPipelineProvider);
      await pipeline.embedNote(note!.id, note.rewrittenText);

      // Search with semantically similar query
      final results = await ragEngine.findSimilarNotes('groceries shopping list');

      expect(results, isNotEmpty);
      expect(results.first.noteId, note.id);
    });

    test('search results are ranked by similarity', () async {
      final processingNotifier = container.read(processingJobProvider.notifier);
      final pipeline = container.read(processingPipelineProvider);

      // Create multiple notes
      final note1 = await processingNotifier.processInput(
        'Buy milk and eggs',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note1!.id, note1.rewrittenText);

      final note2 = await processingNotifier.processInput(
        'Call dentist about appointment',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note2!.id, note2.rewrittenText);

      final note3 = await processingNotifier.processInput(
        'Get groceries for meal prep',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note3!.id, note3.rewrittenText);

      // Search for groceries-related notes
      final results = await ragEngine.findSimilarNotes('grocery shopping');

      expect(results.length, greaterThanOrEqualTo(2));

      // First result should be most relevant (groceries or milk/eggs)
      final topResultIds = results.take(2).map((r) => r.noteId).toList();
      expect(topResultIds, anyElement(anyOf(note1.id, note3.id)));

      // Dentist note should be lower ranked
      final dentistRank = results.indexWhere((r) => r.noteId == note2.id);
      expect(dentistRank, greaterThan(1));
    });

    test('semantic search finds related notes even with different wording',
        () async {
      final processingNotifier = container.read(processingJobProvider.notifier);
      final pipeline = container.read(processingPipelineProvider);

      // Create note with specific wording
      final note = await processingNotifier.processInput(
        'Need to purchase dairy products',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note!.id, note.rewrittenText);

      // Search with different but semantically similar wording
      final results = await ragEngine.findSimilarNotes('buy milk and cheese');

      expect(results, isNotEmpty);
      expect(results.first.noteId, note.id);
      expect(results.first.similarity, greaterThan(0.5)); // Should be similar
    });

    test('empty query returns empty results', () async {
      final results = await ragEngine.findSimilarNotes('');

      expect(results, isEmpty);
    });

    test('search with no indexed notes returns empty results', () async {
      final results = await ragEngine.findSimilarNotes('anything');

      expect(results, isEmpty);
    });

    test('multiple notes with similar content are all returned', () async {
      final processingNotifier = container.read(processingJobProvider.notifier);
      final pipeline = container.read(processingPipelineProvider);

      // Create multiple shopping notes
      final note1 = await processingNotifier.processInput(
        'Buy milk',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note1!.id, note1.rewrittenText);

      final note2 = await processingNotifier.processInput(
        'Get bread from store',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note2!.id, note2.rewrittenText);

      final note3 = await processingNotifier.processInput(
        'Shopping list: eggs, butter',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note3!.id, note3.rewrittenText);

      // Search for shopping
      final results = await ragEngine.findSimilarNotes('grocery shopping', limit: 10);

      // Should return all three shopping-related notes
      expect(results.length, greaterThanOrEqualTo(3));
    });
  });
}
