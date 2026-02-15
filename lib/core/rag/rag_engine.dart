import '../ai/embedding_engine.dart';
import '../ai/llm_engine.dart';
import '../ai/mock_embedding_engine.dart';
import '../storage/vector_store.dart';
import 'chunker.dart';
import 'context_builder.dart';

/// Result of a RAG query, including the answer and source note IDs.
class RAGResult {
  final String answer;
  final List<String> sourceNoteIds;

  const RAGResult({required this.answer, required this.sourceNoteIds});
}

/// Orchestrates the RAG pipeline:
/// query -> embed -> retrieve similar chunks -> build context -> LLM generate
class RAGEngine {
  final EmbeddingEngine embeddingEngine;
  final LLMEngine llmEngine;
  final VectorStore vectorStore;
  final Chunker chunker;
  final ContextBuilder contextBuilder;

  RAGEngine({
    required this.embeddingEngine,
    required this.llmEngine,
    required this.vectorStore,
    this.chunker = const Chunker(),
    this.contextBuilder = const ContextBuilder(),
  });

  /// Index a note's text into the vector store.
  Future<void> indexNote({
    required String noteId,
    required String text,
  }) async {
    final chunks = chunker.chunk(text);
    if (chunks.isEmpty) return;

    final embeddings = await embeddingEngine.embedBatch(chunks);

    for (var i = 0; i < chunks.length; i++) {
      await vectorStore.addChunk(
        noteId: noteId,
        chunkIndex: i,
        text: chunks[i],
        embedding: embeddings[i],
      );
    }
  }

  /// Remove a note's chunks from the vector store.
  Future<void> removeNote(String noteId) async {
    await vectorStore.removeNote(noteId);
  }

  /// Query the knowledge base using RAG.
  Future<RAGResult> query(String question, {int topK = 5}) async {
    // Embed the query
    final queryEmbedding = await embeddingEngine.embed(question);

    // Retrieve similar chunks
    final results = await vectorStore.search(queryEmbedding, topK: topK);

    if (results.isEmpty) {
      return const RAGResult(
        answer:
            "I couldn't find any relevant information in your notes. Try adding more notes first!",
        sourceNoteIds: [],
      );
    }

    // Build context and generate answer
    final chunks = results.map((r) => r.text).toList();
    final noteIds = results.map((r) => r.noteId).toSet().toList();
    final prompt = contextBuilder.buildRAGPrompt(
      question: question,
      retrievedChunks: chunks,
    );

    final answer = await llmEngine.generate(prompt);

    return RAGResult(answer: answer, sourceNoteIds: noteIds);
  }

  /// Find notes similar to given text.
  Future<List<String>> findSimilar(String text, {int topK = 5}) async {
    final embedding = await embeddingEngine.embed(text);
    final results = await vectorStore.search(embedding, topK: topK);
    return results.map((r) => r.noteId).toSet().toList();
  }

  /// Compute similarity between two texts.
  Future<double> similarity(String a, String b) async {
    final embeddings = await embeddingEngine.embedBatch([a, b]);
    return MockEmbeddingEngine.cosineSimilarity(embeddings[0], embeddings[1]);
  }
}
