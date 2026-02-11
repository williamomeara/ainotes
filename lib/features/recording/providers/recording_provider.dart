import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RecordingState { idle, recording, paused, stopped }

class RecordingSession {
  final RecordingState state;
  final Duration elapsed;
  final String transcript;
  final String partialTranscript;

  const RecordingSession({
    this.state = RecordingState.idle,
    this.elapsed = Duration.zero,
    this.transcript = '',
    this.partialTranscript = '',
  });

  RecordingSession copyWith({
    RecordingState? state,
    Duration? elapsed,
    String? transcript,
    String? partialTranscript,
  }) {
    return RecordingSession(
      state: state ?? this.state,
      elapsed: elapsed ?? this.elapsed,
      transcript: transcript ?? this.transcript,
      partialTranscript: partialTranscript ?? this.partialTranscript,
    );
  }
}

final recordingProvider =
    StateNotifierProvider<RecordingNotifier, RecordingSession>((ref) {
  return RecordingNotifier();
});

class RecordingNotifier extends StateNotifier<RecordingSession> {
  RecordingNotifier() : super(const RecordingSession());

  Timer? _timer;
  Timer? _mockSttTimer;
  int _mockWordIndex = 0;

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
    'dentist about',
    'that appointment',
    'next week.',
  ];

  void start() {
    state = state.copyWith(
      state: RecordingState.recording,
      elapsed: Duration.zero,
      transcript: '',
      partialTranscript: '',
    );
    _mockWordIndex = 0;
    _startTimer();
    _startMockStt();
  }

  void pause() {
    state = state.copyWith(state: RecordingState.paused);
    _timer?.cancel();
    _mockSttTimer?.cancel();
  }

  void resume() {
    state = state.copyWith(state: RecordingState.recording);
    _startTimer();
    _startMockStt();
  }

  void stop() {
    _timer?.cancel();
    _mockSttTimer?.cancel();

    // Finalize any partial transcript
    final finalTranscript =
        '${state.transcript}${state.partialTranscript}'.trim();
    state = state.copyWith(
      state: RecordingState.stopped,
      transcript:
          finalTranscript.isEmpty ? _mockWords.join(' ') : finalTranscript,
      partialTranscript: '',
    );
  }

  void reset() {
    _timer?.cancel();
    _mockSttTimer?.cancel();
    state = const RecordingSession();
    _mockWordIndex = 0;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  void _startMockStt() {
    _mockSttTimer =
        Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (_mockWordIndex < _mockWords.length) {
        final word = _mockWords[_mockWordIndex];
        _mockWordIndex++;

        // Every 3 words, finalize the partial into the transcript
        if (_mockWordIndex % 4 == 0) {
          state = state.copyWith(
            transcript:
                '${'${state.transcript}${state.partialTranscript} $word'.trim()} ',
            partialTranscript: '',
          );
        } else {
          state = state.copyWith(
            partialTranscript: '${state.partialTranscript} $word'.trim(),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mockSttTimer?.cancel();
    super.dispose();
  }
}
