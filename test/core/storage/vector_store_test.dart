import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/core/storage/vector_store.dart';

void main() {
  group('VectorStore', () {
    late VectorStore store;

    setUp(() {
      store = VectorStore();
    });

    test('starts empty', () {
      expect(store.chunkCount, 0);
      expect(store.noteIds, isEmpty);
    });

    test('addChunk stores entry', () async {
      await store.addChunk(
        noteId: 'n1',
        chunkIndex: 0,
        text: 'hello',
        embedding: List.filled(10, 0.1),
      );
      expect(store.chunkCount, 1);
      expect(store.noteIds, contains('n1'));
    });

    test('removeNote removes all chunks', () async {
      await store.addChunk(
        noteId: 'n1',
        chunkIndex: 0,
        text: 'a',
        embedding: List.filled(10, 0.1),
      );
      await store.addChunk(
        noteId: 'n1',
        chunkIndex: 1,
        text: 'b',
        embedding: List.filled(10, 0.2),
      );
      expect(store.chunkCount, 2);

      await store.removeNote('n1');
      expect(store.chunkCount, 0);
    });

    test('search finds most similar', () async {
      // Add two chunks with different embeddings
      final embedding1 = List.generate(10, (i) => i == 0 ? 1.0 : 0.0);
      final embedding2 = List.generate(10, (i) => i == 1 ? 1.0 : 0.0);

      await store.addChunk(
        noteId: 'n1',
        chunkIndex: 0,
        text: 'first',
        embedding: embedding1,
      );
      await store.addChunk(
        noteId: 'n2',
        chunkIndex: 0,
        text: 'second',
        embedding: embedding2,
      );

      // Query similar to n1
      final query = List.generate(10, (i) => i == 0 ? 0.9 : 0.1);
      final results = await store.search(query, topK: 2);

      expect(results.length, 2);
      expect(results[0].noteId, 'n1'); // Most similar
    });

    test('search respects topK', () async {
      for (var i = 0; i < 10; i++) {
        final rng = Random(i);
        await store.addChunk(
          noteId: 'n$i',
          chunkIndex: 0,
          text: 'text $i',
          embedding: List.generate(10, (_) => rng.nextDouble()),
        );
      }

      final query = List.filled(10, 0.5);
      final results = await store.search(query, topK: 3);
      expect(results.length, 3);
    });

    test('clear removes all entries', () async {
      await store.addChunk(
        noteId: 'n1',
        chunkIndex: 0,
        text: 'hello',
        embedding: List.filled(10, 0.1),
      );
      await store.clear();
      expect(store.chunkCount, 0);
    });
  });
}
