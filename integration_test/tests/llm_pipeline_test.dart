import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/assertions.dart';
import '../helpers/test_data.dart';
import '../helpers/test_harness.dart';

/// Register LLM pipeline tests.
///
/// Uses getter-function pattern to avoid accessing [harness] at
/// registration time (before setUpAll has run).
void registerLLMPipelineTests(TestHarness Function() getHarness) {
  group('LLM Pipeline', () {
    late TestHarness harness;

    setUp(() {
      harness = getHarness();
    });

    for (var i = 0; i < testNotes.length; i++) {
      final note = testNotes[i];

      test('processes "${note.description}"', () async {
        final perCallTimeout = harness.isRealLLM
            ? const Duration(seconds: 120)
            : const Duration(seconds: 10);

        final stopwatch = Stopwatch()..start();

        final result = await harness.pipeline
            .process(note.rawInput)
            .timeout(perCallTimeout);

        stopwatch.stop();
        debugPrint(
            '[PERF] Pipeline "${note.description}": ${stopwatch.elapsedMilliseconds}ms'
            ' (${harness.isRealLLM ? "real" : "mock"} LLM)');

        // Structural validity
        assertProcessingResultValid(result);

        // Rewrite quality
        assertRewriteQuality(
          original: note.rawInput,
          rewritten: result.rewrittenText,
          expectedWords: note.expectedContentWords,
          isRealLLM: harness.isRealLLM,
        );

        // Classification quality
        assertClassificationQuality(
          actual: result.categoryName,
          expected: note.expectedCategory,
          confidence: result.confidence,
          isRealLLM: harness.isRealLLM,
        );

        // Tag quality
        assertTagQuality(
          tags: result.tags,
          noteText: note.rawInput,
          isRealLLM: harness.isRealLLM,
        );
      },
          // Use generous timeout — actual per-call timeout is enforced above.
          timeout: const Timeout(Duration(seconds: 180)));
    }
  });
}
