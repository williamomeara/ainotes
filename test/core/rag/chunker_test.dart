import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/core/rag/chunker.dart';

void main() {
  group('Chunker', () {
    const chunker = Chunker(maxChunkWords: 10, overlapRatio: 0.2);

    test('empty text returns empty list', () {
      expect(chunker.chunk(''), isEmpty);
      expect(chunker.chunk('   '), isEmpty);
    });

    test('short text returns single chunk', () {
      final chunks = chunker.chunk('Hello world');
      expect(chunks.length, 1);
      expect(chunks[0], 'Hello world');
    });

    test('long text splits into chunks', () {
      final words = List.generate(25, (i) => 'word$i').join(' ');
      final chunks = chunker.chunk(words);
      expect(chunks.length, greaterThan(1));
    });

    test('chunks have overlap', () {
      final words = List.generate(20, (i) => 'word$i').join(' ');
      final chunks = chunker.chunk(words);
      if (chunks.length >= 2) {
        // Check that chunks overlap (some words from end of chunk 1 appear in start of chunk 2)
        final words1 = chunks[0].split(' ');
        final words2 = chunks[1].split(' ');
        final lastWords = words1.sublist(words1.length - 2);
        expect(words2.any((w) => lastWords.contains(w)), true);
      }
    });

    test('default chunker has reasonable defaults', () {
      const defaultChunker = Chunker();
      expect(defaultChunker.maxChunkWords, 100);
      expect(defaultChunker.overlapRatio, 0.2);
    });
  });
}
