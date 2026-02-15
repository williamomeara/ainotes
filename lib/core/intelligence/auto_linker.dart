import '../ai/embedding_engine.dart';
import '../ai/mock_embedding_engine.dart';
import '../storage/vector_store.dart';

/// Finds semantically related notes based on embedding similarity.
class AutoLinker {
  final EmbeddingEngine embeddingEngine;
  final VectorStore vectorStore;

  AutoLinker({
    required this.embeddingEngine,
    required this.vectorStore,
  });

  /// Find note IDs related to the given text, excluding the given note.
  Future<List<String>> findRelated(
    String text, {
    required String excludeNoteId,
    int topK = 5,
    double minSimilarity = 0.3,
  }) async {
    try {
      await embeddingEngine.loadModel('');
      final embedding = await embeddingEngine.embed(text);
      final results = await vectorStore.search(
        embedding,
        topK: topK + 5, // Get extra to filter out excluded note
        minSimilarity: minSimilarity,
      );

      return results
          .where((r) => r.noteId != excludeNoteId)
          .map((r) => r.noteId)
          .toSet()
          .take(topK)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Check if a new note should be merged with an existing one.
  /// Returns the ID of the note to merge with, or null.
  Future<String?> findMergeTarget(
    String newText, {
    double mergeThreshold = 0.8,
  }) async {
    try {
      await embeddingEngine.loadModel('');
      final embedding = await embeddingEngine.embed(newText);
      final results = await vectorStore.search(
        embedding,
        topK: 1,
        minSimilarity: mergeThreshold,
      );

      if (results.isNotEmpty) {
        return results.first.noteId;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Compute similarity between two texts.
  Future<double> similarity(String a, String b) async {
    await embeddingEngine.loadModel('');
    final embeddings = await embeddingEngine.embedBatch([a, b]);
    return MockEmbeddingEngine.cosineSimilarity(embeddings[0], embeddings[1]);
  }
}
