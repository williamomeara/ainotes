import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/core/ai/mock_stt_engine.dart';

void main() {
  group('MockSTTEngine', () {
    late MockSTTEngine engine;

    setUp(() {
      engine = MockSTTEngine();
    });

    test('throws if not initialized', () {
      final stream = StreamController<List<int>>();
      expect(() => engine.transcribeStream(stream.stream), throwsStateError);
      stream.close();
    });

    test('transcribe returns full text', () async {
      await engine.initialize('');
      final result = await engine.transcribe('test.wav');
      expect(result, isNotEmpty);
      expect(result, contains('groceries'));
    });

    test('transcribeStream emits words', () async {
      await engine.initialize('');
      final stream = StreamController<List<int>>();
      final words = <String>[];

      final sub = engine.transcribeStream(stream.stream).listen((word) {
        words.add(word);
      });

      // Wait for stream to complete
      await Future.delayed(const Duration(seconds: 8));
      await sub.cancel();
      stream.close();

      expect(words, isNotEmpty);
    });

    test('dispose resets', () async {
      await engine.initialize('');
      await engine.dispose();
      final stream = StreamController<List<int>>();
      expect(() => engine.transcribeStream(stream.stream), throwsStateError);
      stream.close();
    });
  });
}
