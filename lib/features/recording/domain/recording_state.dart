import 'package:freezed_annotation/freezed_annotation.dart';

part 'recording_state.freezed.dart';

/// Recording lifecycle states
enum RecordingStatus {
  idle,
  recording,
  paused,
  stopped,
}

/// Immutable state for an active recording session
@freezed
class RecordingSession with _$RecordingSession {
  const factory RecordingSession({
    /// Current recording status (idle, recording, paused, stopped)
    @Default(RecordingStatus.idle) RecordingStatus status,

    /// Elapsed time since recording started
    @Default(Duration.zero) Duration elapsed,

    /// Full finalized transcript (confirmed words)
    @Default('') String transcript,

    /// Partial/interim transcript (current word being spoken)
    @Default('') String partialTranscript,

    /// Path to saved audio file (populated after stop)
    String? audioFilePath,

    /// Total audio duration
    Duration? audioDuration,
  }) = _RecordingSession;
}
