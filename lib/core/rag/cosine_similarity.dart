import 'dart:math';

/// Compute cosine similarity between two embedding vectors.
/// Returns 0.0 if vectors have different lengths or zero magnitude.
double cosineSimilarity(List<double> a, List<double> b) {
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
