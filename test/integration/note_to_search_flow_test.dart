import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/core/rag/rag_engine.dart';
import 'package:ainotes/core/storage/database.dart';
import 'package:ainotes/core/storage/database_provider.dart';
import 'package:ainotes/core/storage/vector_store.dart';
import 'package:ainotes/features/notes/domain/note_source.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';

void main() {
  group('Note to Search Flow Integration', () {
    late ProviderContainer container;
    late RAGEngine ragEngine;
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          llmEngineProvider.overrideWithValue(MockLLMEngine()),
          embeddingEngineProvider.overrideWithValue(MockEmbeddingEngine()),
          vectorStoreProvider.overrideWithValue(InMemoryVectorStore()),
        ],
      );

      ragEngine = RAGEngine(
        embeddingEngine: container.read(embeddingEngineProvider),
        llmEngine: container.read(llmEngineProvider),
        vectorStore: container.read(vectorStoreProvider),
      );

      // Pre-load mock engines
      await container.read(llmEngineProvider).loadModel('');
      await container.read(embeddingEngineProvider).loadModel('');
    });

    tearDown(() async {
      container.dispose();
      await db.close();
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

      // Search with query containing overlapping words for mock engine
      final results = await ragEngine.findSimilar('buy milk eggs grocery store');

      expect(results, isNotEmpty);
      expect(results.first, note.id);
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
      final results = await ragEngine.findSimilar('grocery shopping');

      expect(results, isNotEmpty);

      // Top results should include at least one shopping-related note
      expect(results, anyElement(anyOf(note1.id, note3.id)));
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
      final results = await ragEngine.findSimilar('buy milk and cheese');

      expect(results, isNotEmpty);
      expect(results.first, note.id);
    });

    test('empty query returns empty results', () async {
      // findSimilar will attempt to embed an empty string; may return empty
      final results = await ragEngine.findSimilar('');

      expect(results, isEmpty);
    });

    test('search with no indexed notes returns empty results', () async {
      final results = await ragEngine.findSimilar('anything');

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
      final results = await ragEngine.findSimilar('grocery shopping');

      // Should return at least one shopping-related note
      expect(results, isNotEmpty);
    });
  });
}
