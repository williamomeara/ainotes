import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/features/recording/domain/recording_state.dart';
import 'package:ainotes/features/recording/providers/recording_provider.dart';

void main() {
  group('RecordingProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('start begins recording', () async {
      final notifier = container.read(recordingProvider.notifier);

      await notifier.startRecording();

      final state = container.read(recordingProvider);
      expect(state.status, RecordingStatus.recording);
    });

    test('pause suspends recording', () async {
      final notifier = container.read(recordingProvider.notifier);

      await notifier.startRecording();
      await notifier.pauseRecording();

      final state = container.read(recordingProvider);
      expect(state.status, RecordingStatus.paused);
    });

    test('resume continues recording after pause', () async {
      final notifier = container.read(recordingProvider.notifier);

      await notifier.startRecording();
      await notifier.pauseRecording();
      await notifier.resumeRecording();

      final state = container.read(recordingProvider);
      expect(state.status, RecordingStatus.recording);
    });

    test('stop ends recording', () async {
      final notifier = container.read(recordingProvider.notifier);

      await notifier.startRecording();
      await notifier.stopRecording();

      final state = container.read(recordingProvider);
      expect(state.status, RecordingStatus.stopped);
    });

    test('transcript updates during recording', () async {
      final notifier = container.read(recordingProvider.notifier);

      await notifier.startRecording();
      await pumpEventQueue(times: 10);

      final state = container.read(recordingProvider);
      // MockSTTEngine should stream transcript
      expect(state.transcript, isNotEmpty);
    });

    test('timer updates during recording', () async {
      final notifier = container.read(recordingProvider.notifier);

      await notifier.startRecording();
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(recordingProvider);
      expect(state.elapsed, greaterThan(Duration.zero));
    });

    test('lifecycle: start → pause → resume → stop', () async {
      final notifier = container.read(recordingProvider.notifier);

      // Start
      await notifier.startRecording();
      expect(container.read(recordingProvider).status, RecordingStatus.recording);

      // Pause
      await notifier.pauseRecording();
      expect(container.read(recordingProvider).status, RecordingStatus.paused);

      // Resume
      await notifier.resumeRecording();
      expect(container.read(recordingProvider).status, RecordingStatus.recording);

      // Stop
      await notifier.stopRecording();
      expect(container.read(recordingProvider).status, RecordingStatus.stopped);
    });
  });
}
