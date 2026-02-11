/// Splits text into overlapping chunks for embedding.
/// Each chunk is roughly 400-512 tokens (approximated as words).
class Chunker {
  final int maxChunkWords;
  final double overlapRatio;

  const Chunker({
    this.maxChunkWords = 100,
    this.overlapRatio = 0.2,
  });

  /// Split text into overlapping chunks.
  /// Returns list of chunk strings.
  List<String> chunk(String text) {
    if (text.trim().isEmpty) return [];

    final words = text.split(RegExp(r'\s+'));
    if (words.length <= maxChunkWords) return [text.trim()];

    final overlapWords = (maxChunkWords * overlapRatio).round();
    final step = maxChunkWords - overlapWords;
    final chunks = <String>[];

    for (var i = 0; i < words.length; i += step) {
      final end = (i + maxChunkWords).clamp(0, words.length);
      chunks.add(words.sublist(i, end).join(' '));
      if (end == words.length) break;
    }

    return chunks;
  }
}
