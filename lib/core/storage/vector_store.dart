import '../rag/cosine_similarity.dart';

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

abstract class VectorStore {
  Future<void> addChunk({
    required String noteId,
    required int chunkIndex,
    required String text,
    required List<double> embedding,
  });

  Future<void> removeNote(String noteId);

  Future<List<VectorSearchResult>> search(
    List<double> queryEmbedding, {
    int topK = 5,
    double minSimilarity = 0.0,
  });

  int get chunkCount;

  Set<String> get noteIds;

  Future<void> clear();
}

class InMemoryVectorStore extends VectorStore {
  final List<_VectorEntry> _entries = [];

  @override
  Future<void> addChunk({
    required String noteId,
    required int chunkIndex,
    required String text,
    required List<double> embedding,
  }) async {
    _entries.removeWhere(
        (e) => e.noteId == noteId && e.chunkIndex == chunkIndex);
    _entries.add(_VectorEntry(
      noteId: noteId,
      chunkIndex: chunkIndex,
      text: text,
      embedding: embedding,
    ));
  }

  @override
  Future<void> removeNote(String noteId) async {
    _entries.removeWhere((e) => e.noteId == noteId);
  }

  @override
  Future<List<VectorSearchResult>> search(
    List<double> queryEmbedding, {
    int topK = 5,
    double minSimilarity = 0.0,
  }) async {
    if (_entries.isEmpty) return [];

    final scored = _entries.map((entry) {
      final sim = cosineSimilarity(queryEmbedding, entry.embedding);
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

  @override
  int get chunkCount => _entries.length;

  @override
  Set<String> get noteIds => _entries.map((e) => e.noteId).toSet();

  @override
  Future<void> clear() async {
    _entries.clear();
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
