import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/core/rag/rag_engine.dart';
import 'package:ainotes/core/storage/vector_store.dart';

void main() {
  group('RAGEngine', () {
    late RAGEngine rag;
    late MockLLMEngine llm;
    late MockEmbeddingEngine embedding;
    late VectorStore vectorStore;

    setUp(() async {
      llm = MockLLMEngine();
      embedding = MockEmbeddingEngine();
      vectorStore = VectorStore();
      rag = RAGEngine(
        llmEngine: llm,
        embeddingEngine: embedding,
        vectorStore: vectorStore,
      );
      await llm.loadModel('');
      await embedding.loadModel('');
    });

    test('indexNote adds chunks to vector store', () async {
      await rag.indexNote(
        noteId: 'note-1',
        text: 'Buy milk and eggs from the grocery store',
      );
      expect(vectorStore.chunkCount, greaterThan(0));
      expect(vectorStore.noteIds, contains('note-1'));
    });

    test('removeNote removes from vector store', () async {
      await rag.indexNote(noteId: 'note-1', text: 'Test content');
      await rag.removeNote('note-1');
      expect(vectorStore.noteIds, isNot(contains('note-1')));
    });

    test('query returns answer with sources', () async {
      await rag.indexNote(
          noteId: 'note-1', text: 'Buy milk and eggs');
      await rag.indexNote(
          noteId: 'note-2', text: 'Call the dentist tomorrow');

      final result = await rag.query('What groceries do I need?');
      expect(result.answer, isNotEmpty);
      expect(result.sourceNoteIds, isNotEmpty);
    });

    test('query with no indexed notes returns fallback', () async {
      final result = await rag.query('What is anything?');
      expect(result.answer, contains("couldn't find"));
      expect(result.sourceNoteIds, isEmpty);
    });

    test('findSimilar returns related note IDs', () async {
      await rag.indexNote(noteId: 'note-1', text: 'Buy milk and eggs from the grocery store');
      await rag.indexNote(
          noteId: 'note-2', text: 'Buy milk and bread from the grocery store');

      // Query with text very similar to indexed notes
      final similar = await rag.findSimilar('Buy milk from the grocery store');
      expect(similar, isNotEmpty);
    });
  });
}
