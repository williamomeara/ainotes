import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/mock_stt_engine.dart';
import '../../../core/ai/stt_engine.dart';
import '../domain/recording_state.dart';

/// Provider for the STT engine - can be overridden in tests/production
final sttEngineProvider = Provider<STTEngine>((ref) {
  // Default to mock engine for Phase 2 development
  // Will be replaced with SherpaSTTEngine in production
  return MockSTTEngine();
});

/// Main recording provider - manages recording state and lifecycle
final recordingProvider = StateNotifierProvider<RecordingNotifier, RecordingSession>((ref) {
  return RecordingNotifier(ref);
});

class RecordingNotifier extends StateNotifier<RecordingSession> {
  RecordingNotifier(this.ref) : super(const RecordingSession());

  final Ref ref;

  late final STTEngine _sttEngine;

  Timer? _elapsedTimer;
  StreamSubscription<String>? _transcriptionSubscription;

  // Placeholder for audio stream (will be provided by actual recording)
  StreamController<List<int>>? _audioStreamController;

  /// Start recording and transcription
  Future<void> startRecording() async {
    try {
      // Initialize STT engine
      _sttEngine = ref.read(sttEngineProvider);
      await _sttEngine.initialize('');

      // Reset state
      state = const RecordingSession();

      // Create audio stream controller for mock
      _audioStreamController = StreamController<List<int>>();

      // Update state to recording
      state = state.copyWith(status: RecordingStatus.recording);

      // Start elapsed time timer (updates every 100ms)
      _startElapsedTimer();

      // Start transcription stream from audio
      _startTranscription(_audioStreamController!.stream);
    } catch (e) {
      state = state.copyWith(status: RecordingStatus.idle);
      rethrow;
    }
  }

  /// Pause recording (audio and transcription)
  Future<void> pauseRecording() async {
    try {
      _elapsedTimer?.cancel();
      _transcriptionSubscription?.pause();
      state = state.copyWith(status: RecordingStatus.paused);
    } catch (e) {
      rethrow;
    }
  }

  /// Resume recording from pause
  Future<void> resumeRecording() async {
    try {
      state = state.copyWith(status: RecordingStatus.recording);
      _startElapsedTimer();
      _transcriptionSubscription?.resume();
    } catch (e) {
      rethrow;
    }
  }

  /// Stop recording and finalize transcript
  Future<String> stopRecording() async {
    try {
      _elapsedTimer?.cancel();
      _transcriptionSubscription?.cancel();
      _audioStreamController?.close();

      // Combine finalized and partial transcripts
      final finalTranscript = state.transcript.isEmpty
          ? state.partialTranscript
          : '${state.transcript} ${state.partialTranscript}'.trim();

      state = state.copyWith(
        status: RecordingStatus.stopped,
        transcript: finalTranscript,
        partialTranscript: '',
        audioDuration: state.elapsed,
      );

      await _sttEngine.dispose();
      return finalTranscript;
    } catch (e) {
      rethrow;
    }
  }

  /// Reset to idle state
  void reset() {
    _elapsedTimer?.cancel();
    _transcriptionSubscription?.cancel();
    _audioStreamController?.close();
    state = const RecordingSession();
  }

  /// Start timer for elapsed time (updates every 100ms)
  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (state.status != RecordingStatus.recording) return;
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(milliseconds: 100),
      );
    });
  }

  /// Start listening to transcription stream from STT engine
  void _startTranscription(Stream<List<int>> audioStream) {
    try {
      _transcriptionSubscription?.cancel();

      // Create transcription stream from STT engine
      final transcriptionStream = _sttEngine.transcribeStream(audioStream);

      _transcriptionSubscription = transcriptionStream.listen(
        (transcript) {
          if (state.status != RecordingStatus.recording) return;

          // Update state with new transcript
          // If ends with period/space, it's finalized; otherwise partial
          if (transcript.endsWith('.') || transcript.endsWith(' ')) {
            state = state.copyWith(
              transcript: state.transcript.isEmpty
                  ? transcript.trim()
                  : '${state.transcript} ${transcript.trim()}',
              partialTranscript: '',
            );
          } else {
            state = state.copyWith(partialTranscript: transcript);
          }
        },
        onError: (error) {
          state = state.copyWith(status: RecordingStatus.stopped);
        },
        onDone: () {
          // Finalize partial transcript on stream end
          if (state.partialTranscript.isNotEmpty) {
            state = state.copyWith(
              transcript: state.transcript.isEmpty
                  ? state.partialTranscript
                  : '${state.transcript} ${state.partialTranscript}',
              partialTranscript: '',
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(status: RecordingStatus.idle);
      rethrow;
    }
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _transcriptionSubscription?.cancel();
    _audioStreamController?.close();
    super.dispose();
  }
}
