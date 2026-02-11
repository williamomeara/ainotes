import 'dart:math';

import 'embedding_engine.dart';

/// Mock embedding engine for development and testing.
/// Generates deterministic pseudo-embeddings based on text content.
/// Similar texts will produce similar vectors (using simple hashing).
class MockEmbeddingEngine implements EmbeddingEngine {
  bool _loaded = false;
  static final _dimensions = 384; // Match all-MiniLM-L6-v2 dimensions

  @override
  Future<void> loadModel(String modelPath) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _loaded = true;
  }

  @override
  Future<List<double>> embed(String text) async {
    _checkLoaded();
    await Future.delayed(const Duration(milliseconds: 10));
    return _generateEmbedding(text);
  }

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    _checkLoaded();
    await Future.delayed(Duration(milliseconds: 10 * texts.length));
    return texts.map(_generateEmbedding).toList();
  }

  @override
  Future<void> dispose() async {
    _loaded = false;
  }

  void _checkLoaded() {
    if (!_loaded) {
      throw StateError(
          'MockEmbeddingEngine not loaded. Call loadModel() first.');
    }
  }

  /// Generate a deterministic pseudo-embedding from text.
  /// Uses word-level hashing so similar texts produce similar vectors.
  List<double> _generateEmbedding(String text) {
    final vector = List<double>.filled(_dimensions, 0.0);
    final words = text.toLowerCase().split(RegExp(r'\s+'));

    for (final word in words) {
      final hash = word.hashCode;
      final rng = Random(hash);
      for (var i = 0; i < _dimensions; i++) {
        vector[i] += (rng.nextDouble() - 0.5) * 2.0 / words.length;
      }
    }

    // L2 normalize
    var norm = 0.0;
    for (final v in vector) {
      norm += v * v;
    }
    norm = sqrt(norm);
    if (norm > 0) {
      for (var i = 0; i < _dimensions; i++) {
        vector[i] /= norm;
      }
    }

    return vector;
  }

  /// Compute cosine similarity between two embeddings
  static double cosineSimilarity(List<double> a, List<double> b) {
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
