import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';

void main() {
  group('MockLLMEngine', () {
    late MockLLMEngine engine;

    setUp(() {
      engine = MockLLMEngine();
    });

    test('throws if not loaded', () async {
      expect(() => engine.generate('test'), throwsStateError);
    });

    test('loadModel initializes', () async {
      await engine.loadModel('');
      final result = await engine.generate('Processed: hello');
      expect(result, isNotEmpty);
    });

    test('rewrite prompt cleans text', () async {
      await engine.loadModel('');
      final result = await engine.generate(
          'Rewrite the following:\num okay so like get milk');
      expect(result, isNotEmpty);
      expect(result.contains('um'), false);
    });

    test('classify prompt returns JSON', () async {
      await engine.loadModel('');
      final result = await engine.generate('Classify: buy milk and eggs');
      expect(result, contains('shopping'));
    });

    test('extract tags prompt returns tags', () async {
      await engine.loadModel('');
      final result =
          await engine.generate('Extract tags from: grocery shopping for milk');
      expect(result, contains('groceries'));
    });

    test('generateStream yields words', () async {
      await engine.loadModel('');
      final words = <String>[];
      await for (final word in engine.generateStream('Processed: hello')) {
        words.add(word);
      }
      expect(words, isNotEmpty);
    });

    test('dispose resets state', () async {
      await engine.loadModel('');
      await engine.dispose();
      expect(() => engine.generate('test'), throwsStateError);
    });
  });
}
