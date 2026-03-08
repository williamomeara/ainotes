import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/features/processing/domain/processing_pipeline.dart';

/// Semantic assertion helpers that adapt to real vs mock engines.

/// Check that the LLM rewrite cleaned up the input meaningfully.
void assertRewriteQuality({
  required String original,
  required String rewritten,
  required List<String> expectedWords,
  required bool isRealLLM,
}) {
  expect(rewritten.isNotEmpty, isTrue,
      reason: 'Rewritten text should not be empty');
  expect(rewritten != original, isTrue,
      reason: 'Rewritten text should differ from original');

  if (isRealLLM) {
    // Real LLM should remove filler words
    final lower = rewritten.toLowerCase();
    final fillerWords = ['um', 'uh', 'like', 'you know', 'so '];
    for (final filler in fillerWords) {
      // Allow "so" when it's part of a real word or sentence start
      if (filler == 'so ') continue;
      expect(lower.contains(RegExp('\\b${RegExp.escape(filler)}\\b')), isFalse,
          reason: 'Real LLM should remove filler word "$filler"');
    }

    // Should preserve key content words
    for (final word in expectedWords) {
      expect(lower.contains(word.toLowerCase()), isTrue,
          reason:
              'Rewrite should preserve key word "$word" (got: $rewritten)');
    }
  }
}

/// Check that classification matched the expected category.
void assertClassificationQuality({
  required String actual,
  required String expected,
  required double confidence,
  required bool isRealLLM,
}) {
  if (isRealLLM) {
    expect(actual, equals(expected),
        reason:
            'Real LLM should classify as $expected, got $actual');
    expect(confidence, greaterThan(0.5),
        reason: 'Real LLM confidence should be > 0.5, got $confidence');
  } else {
    // Mock: just check it returned a non-empty category name
    expect(actual.isNotEmpty, isTrue,
        reason: 'Should return a non-empty category name');
  }
}

/// Check that extracted tags are reasonable.
void assertTagQuality({
  required List<String> tags,
  required String noteText,
  required bool isRealLLM,
}) {
  expect(tags.isNotEmpty, isTrue, reason: 'Should extract at least one tag');

  if (isRealLLM) {
    // At least one tag should relate to the note content
    final lowerText = noteText.toLowerCase();
    final hasRelevantTag = tags.any((tag) => lowerText.contains(tag));
    expect(hasRelevantTag, isTrue,
        reason:
            'At least one tag should appear in the note text. Tags: $tags');
  }
}

/// Check that a RAG answer is reasonable.
void assertRAGAnswer({
  required String answer,
  required List<String> sourceNoteIds,
  required List<String> expectedKeywords,
  required List<String> expectedSourceIds,
  required bool isRealLLM,
  required bool isRealEmbedding,
}) {
  expect(answer.isNotEmpty, isTrue, reason: 'RAG answer should not be empty');

  if (isRealLLM) {
    final lower = answer.toLowerCase();
    for (final keyword in expectedKeywords) {
      expect(lower.contains(keyword.toLowerCase()), isTrue,
          reason: 'RAG answer should mention "$keyword" (got: $answer)');
    }
  }

  if (isRealEmbedding) {
    // Real embeddings should retrieve the correct source notes
    for (final id in expectedSourceIds) {
      expect(sourceNoteIds.contains(id), isTrue,
          reason:
              'RAG should cite source "$id". Got sources: $sourceNoteIds');
    }
  }
}

/// Check that a ProcessingResult has valid structure.
void assertProcessingResultValid(ProcessingResult result) {
  expect(result.rewrittenText.isNotEmpty, isTrue,
      reason: 'Rewritten text should not be empty');
  expect(result.categoryName.isNotEmpty, isTrue,
      reason: 'Category name should not be empty');
  expect(result.confidence, greaterThanOrEqualTo(0.0),
      reason: 'Confidence should be >= 0');
  expect(result.confidence, lessThanOrEqualTo(1.0),
      reason: 'Confidence should be <= 1');
}
