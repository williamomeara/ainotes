@Tags(['manual'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/llamadart_engine.dart';
import 'package:ainotes/core/rag/prompt_templates.dart';

/// Manual tests for LlamaDartEngine with real Qwen 2.5 1.5B model.
/// Requires model file in test/manual_native/fixtures/
void main() {
  group('LlamaDartEngine (Manual)', () {
    late LlamaDartEngine engine;
    const modelPath =
        'test/manual_native/fixtures/qwen2.5-1.5b-instruct-q4_k_m.gguf';

    setUpAll(() async {
      // Verify model file exists
      final file = File(modelPath);
      if (!await file.exists()) {
        fail(
          'Model file not found at $modelPath. See test/manual_native/README.md for download instructions.',
        );
      }

      engine = LlamaDartEngine();
      await engine.loadModel(modelPath);
    });

    tearDownAll(() async {
      await engine.dispose();
    });

    test('load Qwen model from GGUF file', () async {
      // Should have loaded in setUpAll without errors
      expect(engine, isNotNull);
    });

    test('rewriting removes filler words', () async {
      final input = 'um so like I need to uh get milk and eggs you know';
      final prompt = PromptTemplates.rewritePrompt(input);

      final output = await engine.generate(prompt);

      expect(output, isNotEmpty);
      expect(output.toLowerCase(), isNot(contains('um')));
      expect(output.toLowerCase(), isNot(contains('uh')));
      expect(output.toLowerCase(), isNot(contains('like')));
      expect(output.toLowerCase(), contains('milk'));
      expect(output.toLowerCase(), contains('eggs'));
    });

    test('classification returns valid category', () async {
      final input = 'Buy milk and eggs from the store';
      final prompt = PromptTemplates.classifyPrompt(input);

      final output = await engine.generate(prompt);

      expect(output, isNotEmpty);
      // Should classify as shopping
      expect(output.toLowerCase(), anyOf(contains('shopping'), contains('shop')));
    });

    test('classification provides confidence score', () async {
      final input = 'Remind me to call the dentist tomorrow';
      final prompt = PromptTemplates.classifyPrompt(input);

      final output = await engine.generate(prompt);

      expect(output, isNotEmpty);
      // Should include confidence (0.0-1.0)
      final hasConfidence = RegExp(r'0\.\d+|1\.0').hasMatch(output);
      expect(hasConfidence, true);
    });

    test('tag extraction finds relevant keywords', () async {
      final text = 'Need to buy groceries for weekly meal prep on Sunday';
      final prompt = PromptTemplates.extractTagsPrompt(text);

      final output = await engine.generate(prompt);

      expect(output, isNotEmpty);
      expect(output.toLowerCase(), anyOf(
        contains('groceries'),
        contains('meal'),
        contains('weekly'),
      ));
    });

    test('LLM handles long input (>100 tokens)', () async {
      final longInput = '''
        I had a really productive meeting today with the client.
        We discussed the project timeline, budget constraints, and deliverables.
        They want the first phase completed by end of March, which seems doable.
        Need to follow up with the design team about mockups and get quotes from vendors.
      ''';
      final prompt = PromptTemplates.rewritePrompt(longInput);

      final output = await engine.generate(prompt);

      expect(output, isNotEmpty);
      expect(output.length, greaterThan(50));
    });

    test('streaming generation works', () async {
      final input = 'What is artificial intelligence?';
      final prompt = PromptTemplates.qaPrompt(input, '');

      final tokens = <String>[];
      await for (final token in engine.generateStream(prompt)) {
        tokens.add(token);
        if (tokens.length > 20) break; // Limit for testing
      }

      expect(tokens, isNotEmpty);
      expect(tokens.length, greaterThan(5));
    });

    test('generation completes in reasonable time (<5s)', () async {
      final stopwatch = Stopwatch()..start();

      final input = 'Summarize this: The quick brown fox jumps over the lazy dog.';
      final prompt = PromptTemplates.rewritePrompt(input);

      await engine.generate(prompt);

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('handles empty input gracefully', () async {
      final prompt = PromptTemplates.rewritePrompt('');

      expect(() => engine.generate(prompt), returnsNormally);
    });

    test('handles special characters in input', () async {
      final input = 'Buy "organic" milk & eggs @ \$5 each!';
      final prompt = PromptTemplates.rewritePrompt(input);

      final output = await engine.generate(prompt);

      expect(output, isNotEmpty);
    });
  });
}
