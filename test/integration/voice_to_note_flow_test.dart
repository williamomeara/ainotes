import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/core/ai/mock_stt_engine.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_category.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';
import 'package:ainotes/features/recording/providers/recording_provider.dart';
import 'package:ainotes/features/unified_input/providers/unified_input_provider.dart';

void main() {
  group('Voice to Note Flow Integration', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          llmEngineProvider.overrideWithValue(MockLLMEngine()),
          embeddingEngineProvider.overrideWithValue(MockEmbeddingEngine()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('full flow: start recording → transcript → submit → LLM pipeline → note created',
        () async {
      // 1. Start recording
      final recordingNotifier = container.read(recordingProvider.notifier);
      await recordingNotifier.start();

      // 2. Wait for transcript
      await pumpEventQueue(times: 10);
      final recordingState = container.read(recordingProvider);
      expect(recordingState.isRecording, true);
      expect(recordingState.transcript, isNotEmpty);

      // 3. Stop recording
      await recordingNotifier.stop();
      final transcript = recordingState.transcript;

      // 4. Submit transcript through unified input
      final inputNotifier = container.read(unifiedInputProvider.notifier);
      await inputNotifier.submitInput(
        transcript,
        source: NoteSource.voice,
      );

      // 5. Verify note was created
      final inputState = container.read(unifiedInputProvider);
      expect(inputState.isProcessing, false);
      expect(inputState.error, isNull);

      final processingState = container.read(processingJobProvider);
      expect(processingState.noteId, isNotNull);
    });

    test('note has correct source (voice)', () async {
      final recordingNotifier = container.read(recordingProvider.notifier);
      await recordingNotifier.start();
      await pumpEventQueue(times: 5);
      await recordingNotifier.stop();

      final transcript = container.read(recordingProvider).transcript;

      final inputNotifier = container.read(unifiedInputProvider.notifier);
      await inputNotifier.submitInput(transcript, source: NoteSource.voice);

      final processingNotifier = container.read(processingJobProvider.notifier);
      final note = await processingNotifier.processInput(
        transcript,
        source: NoteSource.voice,
      );

      expect(note, isNotNull);
      expect(note!.source, NoteSource.voice);
      expect(note.audioDuration, isNotNull);
    });

    test('note has correct category (shopping)', () async {
      final inputNotifier = container.read(unifiedInputProvider.notifier);
      await inputNotifier.submitInput(
        'Buy milk and bread',
        source: NoteSource.voice,
      );

      final processingNotifier = container.read(processingJobProvider.notifier);
      final note = await processingNotifier.processInput(
        'Buy milk and bread',
        source: NoteSource.voice,
      );

      expect(note, isNotNull);
      expect(note!.category, NoteCategory.shopping);
    });

    test('note has rewritten text (filler words removed)', () async {
      final inputNotifier = container.read(unifiedInputProvider.notifier);
      final rawText = 'um so like I need to get milk and uh eggs';

      await inputNotifier.submitInput(rawText, source: NoteSource.voice);

      final processingNotifier = container.read(processingJobProvider.notifier);
      final note = await processingNotifier.processInput(
        rawText,
        source: NoteSource.voice,
      );

      expect(note, isNotNull);
      expect(note!.originalText, rawText);
      expect(note.rewrittenText, isNot(contains('um')));
      expect(note.rewrittenText, isNot(contains('uh')));
      expect(note.rewrittenText, isNot(contains('like')));
    });

    test('pause and resume maintains transcript continuity', () async {
      final recordingNotifier = container.read(recordingProvider.notifier);

      await recordingNotifier.start();
      await pumpEventQueue(times: 5);

      final transcript1 = container.read(recordingProvider).transcript;

      await recordingNotifier.pause();
      await recordingNotifier.resume();
      await pumpEventQueue(times: 5);

      final transcript2 = container.read(recordingProvider).transcript;

      expect(transcript2.length, greaterThanOrEqualTo(transcript1.length));
      expect(transcript2, startsWith(transcript1));
    });
  });
}
