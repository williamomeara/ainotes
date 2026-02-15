import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/core/ai/mock_embedding_engine.dart';

void main() {
  group('MockEmbeddingEngine', () {
    late MockEmbeddingEngine engine;

    setUp(() {
      engine = MockEmbeddingEngine();
    });

    test('throws if not loaded', () async {
      expect(() => engine.embed('test'), throwsStateError);
    });

    test('embed returns 768-dimensional vector', () async {
      await engine.loadModel('');
      final embedding = await engine.embed('hello world');
      expect(embedding.length, 768);
    });

    test('embedBatch returns correct count', () async {
      await engine.loadModel('');
      final embeddings =
          await engine.embedBatch(['hello', 'world', 'test']);
      expect(embeddings.length, 3);
      expect(embeddings[0].length, 768);
    });

    test('similar texts produce similar embeddings', () async {
      await engine.loadModel('');
      final e1 = await engine.embed('buy milk and eggs');
      final e2 = await engine.embed('get milk and bread');
      final e3 = await engine.embed('quantum physics research');

      final sim12 = MockEmbeddingEngine.cosineSimilarity(e1, e2);
      final sim13 = MockEmbeddingEngine.cosineSimilarity(e1, e3);

      // Similar texts should have higher similarity
      expect(sim12, greaterThan(sim13));
    });

    test('same text produces identical embeddings', () async {
      await engine.loadModel('');
      final e1 = await engine.embed('hello world');
      final e2 = await engine.embed('hello world');

      final sim = MockEmbeddingEngine.cosineSimilarity(e1, e2);
      expect(sim, closeTo(1.0, 0.001));
    });

    test('embeddings are normalized', () async {
      await engine.loadModel('');
      final embedding = await engine.embed('test text');

      var norm = 0.0;
      for (final v in embedding) {
        norm += v * v;
      }
      expect(norm, closeTo(1.0, 0.01));
    });
  });
}
