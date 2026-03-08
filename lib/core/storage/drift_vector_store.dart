import '../rag/cosine_similarity.dart';
import 'daos/chunks_dao.dart';
import 'vector_store.dart';

class DriftVectorStore extends VectorStore {
  final ChunksDao _chunksDao;

  // In-memory cache for fast cosine similarity search
  final List<_CachedChunk> _cache = [];
  bool _loaded = false;

  DriftVectorStore(this._chunksDao);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final entries = await _chunksDao.getAll();
    _cache.clear();
    for (final e in entries) {
      _cache.add(_CachedChunk(
        noteId: e.noteId,
        chunkIndex: e.chunkIndex,
        text: e.chunkText,
        embedding: e.embedding.toList(),
      ));
    }
    _loaded = true;
  }

  @override
  Future<void> addChunk({
    required String noteId,
    required int chunkIndex,
    required String text,
    required List<double> embedding,
  }) async {
    await _chunksDao.upsertChunk(
      noteId: noteId,
      chunkIndex: chunkIndex,
      chunkText: text,
      embedding: embedding,
    );

    // Update cache
    _cache.removeWhere(
        (e) => e.noteId == noteId && e.chunkIndex == chunkIndex);
    _cache.add(_CachedChunk(
      noteId: noteId,
      chunkIndex: chunkIndex,
      text: text,
      embedding: embedding,
    ));
    _loaded = true;
  }

  @override
  Future<void> removeNote(String noteId) async {
    await _chunksDao.removeNote(noteId);
    _cache.removeWhere((e) => e.noteId == noteId);
  }

  @override
  Future<List<VectorSearchResult>> search(
    List<double> queryEmbedding, {
    int topK = 5,
    double minSimilarity = 0.0,
  }) async {
    await _ensureLoaded();
    if (_cache.isEmpty) return [];

    final scored = _cache.map((entry) {
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
  int get chunkCount => _cache.length;

  @override
  Set<String> get noteIds => _cache.map((e) => e.noteId).toSet();

  @override
  Future<void> clear() async {
    for (final noteId in noteIds.toList()) {
      await _chunksDao.removeNote(noteId);
    }
    _cache.clear();
  }
}

class _CachedChunk {
  final String noteId;
  final int chunkIndex;
  final String text;
  final List<double> embedding;

  const _CachedChunk({
    required this.noteId,
    required this.chunkIndex,
    required this.text,
    required this.embedding,
  });
}
