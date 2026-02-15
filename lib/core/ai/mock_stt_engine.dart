import 'dart:async';

import 'stt_engine.dart';

/// Mock STT engine for testing and development
/// Returns incrementally transcribed words at intervals
class MockSTTEngine implements STTEngine {
  static const _mockWords = [
    'I need to',
    'remember to',
    'pick up',
    'groceries',
    'after work',
    'today.',
    'Also,',
    'I should',
    'call the',
    'dentist',
  ];

  bool _initialized = false;

  @override
  Future<void> initialize(String modelPath) async {
    _initialized = true;
  }

  @override
  Stream<String> transcribeStream(Stream<List<int>> audioStream) {
    if (!_initialized) {
      throw StateError('MockSTTEngine not initialized');
    }

    final controller = StreamController<String>();

    // Ignore audio stream, just emit mock words at intervals
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }

      final wordIndex = (timer.tick - 1) % _mockWords.length;
      final word = _mockWords[wordIndex];
      controller.add(word);

      if (wordIndex == _mockWords.length - 1) {
        timer.cancel();
        controller.close();
      }
    });

    return controller.stream;
  }

  @override
  Future<String> transcribe(String audioFilePath) async {
    if (!_initialized) {
      throw StateError('MockSTTEngine not initialized');
    }
    return _mockWords.join(' ');
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}
