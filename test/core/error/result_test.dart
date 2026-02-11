import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/core/error/result.dart';

void main() {
  group('Result', () {
    test('Ok holds data', () {
      const result = Ok(42);
      expect(result.isOk, true);
      expect(result.isErr, false);
      expect(result.value, 42);
    });

    test('Err holds message', () {
      const result = Err<int>('fail');
      expect(result.isOk, false);
      expect(result.isErr, true);
      expect(result.error, 'fail');
    });

    test('when dispatches correctly', () {
      const Result<int> ok = Ok(10);
      const Result<int> err = Err('bad');

      expect(ok.when(ok: (d) => d * 2, err: (m) => -1), 20);
      expect(err.when(ok: (d) => d * 2, err: (m) => -1), -1);
    });

    test('switch exhaustiveness', () {
      const Result<String> result = Ok('hello');
      final output = switch (result) {
        Ok(:final data) => data.toUpperCase(),
        Err(:final message) => message,
      };
      expect(output, 'HELLO');
    });
  });
}
