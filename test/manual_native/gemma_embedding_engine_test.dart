@Tags(['manual'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'package:ainotes/core/ai/gemma_embedding_engine.dart';

/// Manual tests for GemmaEmbeddingEngine with real EmbeddingGemma 300M model.
/// Requires flutter_gemma plugin and model installed.
void main() {
  group('GemmaEmbeddingEngine (Manual)', () {
    late GemmaEmbeddingEngine engine;

    setUpAll(() async {
      // Initialize FlutterGemma
      await FlutterGemma.initialize();

      engine = GemmaEmbeddingEngine();
      await engine.loadModel(''); // GemmaEmbeddingEngine manages path internally
    });

    tearDownAll(() async {
      await engine.dispose();
    });

    test('embedding produces 768-dimensional vectors', () async {
      final text = 'This is a test sentence';
      final embedding = await engine.embed(text);

      expect(embedding, isNotNull);
      expect(embedding.length, 768); // EmbeddingGemma output dimension
    });

    test('embeddings are normalized (magnitude ~1.0)', () async {
      final text = 'Normalized vector test';
      final embedding = await engine.embed(text);

      // Calculate magnitude
      final magnitude = _calculateMagnitude(embedding);

      expect(magnitude, closeTo(1.0, 0.1)); // Should be close to 1.0
    });

    test('similar texts have higher cosine similarity', () async {
      final text1 = 'Buy milk and eggs from the grocery store';
      final text2 = 'Get groceries: milk, eggs';

      final embedding1 = await engine.embed(text1);
      final embedding2 = await engine.embed(text2);

      final similarity = _cosineSimilarity(embedding1, embedding2);

      expect(similarity, greaterThan(0.7)); // Should be highly similar
    });

    test('dissimilar texts have lower cosine similarity', () async {
      final text1 = 'Buy milk and eggs';
      final text2 = 'Project deadline is next Friday';

      final embedding1 = await engine.embed(text1);
      final embedding2 = await engine.embed(text2);

      final similarity = _cosineSimilarity(embedding1, embedding2);

      expect(similarity, lessThan(0.5)); // Should be less similar
    });

    test('identical texts have similarity ~1.0', () async {
      final text = 'This is a test sentence';

      final embedding1 = await engine.embed(text);
      final embedding2 = await engine.embed(text);

      final similarity = _cosineSimilarity(embedding1, embedding2);

      expect(similarity, closeTo(1.0, 0.01));
    });

    test('embedBatch processes multiple texts', () async {
      final texts = [
        'First sentence',
        'Second sentence',
        'Third sentence',
      ];

      final embeddings = await engine.embedBatch(texts);

      expect(embeddings.length, 3);
      expect(embeddings[0].length, 768);
      expect(embeddings[1].length, 768);
      expect(embeddings[2].length, 768);
    });

    test('batch embedding is faster than sequential', () async {
      final texts = List.generate(5, (i) => 'Test sentence $i');

      // Sequential embedding
      final sw1 = Stopwatch()..start();
      for (final text in texts) {
        await engine.embed(text);
      }
      sw1.stop();

      // Batch embedding
      final sw2 = Stopwatch()..start();
      await engine.embedBatch(texts);
      sw2.stop();

      // Batch should be faster (or at least not significantly slower)
      expect(sw2.elapsedMilliseconds, lessThanOrEqualTo(sw1.elapsedMilliseconds * 1.2));
    });

    test('embedding completes in reasonable time (<500ms)', () async {
      final stopwatch = Stopwatch()..start();

      await engine.embed('Quick performance test');

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('handles empty text', () async {
      final embedding = await engine.embed('');

      expect(embedding, isNotNull);
      expect(embedding.length, 768);
    });

    test('handles long text (>512 tokens)', () async {
      final longText = 'word ' * 600; // ~600 words, likely >512 tokens
      final embedding = await engine.embed(longText);

      expect(embedding, isNotNull);
      expect(embedding.length, 768);
    });

    test('semantic similarity: synonyms', () async {
      final text1 = 'happy';
      final text2 = 'joyful';

      final embedding1 = await engine.embed(text1);
      final embedding2 = await engine.embed(text2);

      final similarity = _cosineSimilarity(embedding1, embedding2);

      expect(similarity, greaterThan(0.6)); // Synonyms should be similar
    });

    test('semantic similarity: antonyms', () async {
      final text1 = 'happy';
      final text2 = 'sad';

      final embedding1 = await engine.embed(text1);
      final embedding2 = await engine.embed(text2);

      final similarity = _cosineSimilarity(embedding1, embedding2);

      expect(similarity, lessThan(0.7)); // Antonyms should be less similar
    });

    test('handles special characters', () async {
      final text = 'Text with #hashtags, @mentions, and emojis 😊';
      final embedding = await engine.embed(text);

      expect(embedding, isNotNull);
      expect(embedding.length, 768);
    });
  });
}

/// Calculate cosine similarity between two vectors.
double _cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length) {
    throw ArgumentError('Vectors must have same length');
  }

  double dotProduct = 0.0;
  double magnitudeA = 0.0;
  double magnitudeB = 0.0;

  for (int i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    magnitudeA += a[i] * a[i];
    magnitudeB += b[i] * b[i];
  }

  magnitudeA = magnitudeA.sqrt();
  magnitudeB = magnitudeB.sqrt();

  if (magnitudeA == 0 || magnitudeB == 0) return 0.0;

  return dotProduct / (magnitudeA * magnitudeB);
}

/// Calculate magnitude of a vector.
double _calculateMagnitude(List<double> vector) {
  double sum = 0.0;
  for (final value in vector) {
    sum += value * value;
  }
  return sum.sqrt();
}

extension on double {
  double sqrt() => this < 0 ? 0 : dartmath.sqrt(this);
}

import 'dart:math' as dartmath;
