import 'dart:math';

/// Result from a vector similarity search.
class VectorSearchResult {
  final String noteId;
  final int chunkIndex;
  final String text;
  final double similarity;

  const VectorSearchResult({
    required this.noteId,
    required this.chunkIndex,
    required this.text,
    required this.similarity,
  });
}

/// In-memory vector store with cosine similarity search.
/// In production, this would use ObjectBox HNSW for persistent storage.
class VectorStore {
  final List<_VectorEntry> _entries = [];

  /// Add a text chunk with its embedding vector.
  Future<void> addChunk({
    required String noteId,
    required int chunkIndex,
    required String text,
    required List<double> embedding,
  }) async {
    // Remove existing entry for this note+chunk if present
    _entries.removeWhere(
        (e) => e.noteId == noteId && e.chunkIndex == chunkIndex);

    _entries.add(_VectorEntry(
      noteId: noteId,
      chunkIndex: chunkIndex,
      text: text,
      embedding: embedding,
    ));
  }

  /// Remove all chunks for a note.
  Future<void> removeNote(String noteId) async {
    _entries.removeWhere((e) => e.noteId == noteId);
  }

  /// Search for the most similar chunks to a query embedding.
  Future<List<VectorSearchResult>> search(
    List<double> queryEmbedding, {
    int topK = 5,
    double minSimilarity = 0.0,
  }) async {
    if (_entries.isEmpty) return [];

    final scored = _entries.map((entry) {
      final sim = _cosineSimilarity(queryEmbedding, entry.embedding);
      return VectorSearchResult(
        noteId: entry.noteId,
        chunkIndex: entry.chunkIndex,
        text: entry.text,
        similarity: sim,
      );
    }).where((r) => r.similarity >= minSimilarity).toList();

    scored.sort((a, b) => b.similarity.compareTo(a.similarity));
    return scored.take(topK).toList();
  }

  /// Get the number of stored chunks.
  int get chunkCount => _entries.length;

  /// Get all unique note IDs in the store.
  Set<String> get noteIds => _entries.map((e) => e.noteId).toSet();

  /// Clear all entries.
  Future<void> clear() async {
    _entries.clear();
  }

  static double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = sqrt(normA) * sqrt(normB);
    return denom > 0 ? dot / denom : 0.0;
  }
}

class _VectorEntry {
  final String noteId;
  final int chunkIndex;
  final String text;
  final List<double> embedding;

  const _VectorEntry({
    required this.noteId,
    required this.chunkIndex,
    required this.text,
    required this.embedding,
  });
}
