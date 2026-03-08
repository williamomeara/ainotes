import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/core/storage/database.dart';
import 'package:ainotes/core/storage/database_provider.dart';
import 'package:ainotes/core/storage/vector_store.dart';
import 'package:ainotes/features/notes/domain/note_source.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';
import 'package:ainotes/features/recording/domain/recording_state.dart';
import 'package:ainotes/features/recording/providers/recording_provider.dart';
import 'package:ainotes/features/unified_input/providers/unified_input_provider.dart';

void main() {
  group('Voice to Note Flow Integration', () {
    late ProviderContainer container;
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          llmEngineProvider.overrideWithValue(MockLLMEngine()),
          embeddingEngineProvider.overrideWithValue(MockEmbeddingEngine()),
          vectorStoreProvider.overrideWithValue(InMemoryVectorStore()),
        ],
      );
    });

    tearDown(() async {
      // Allow background processing to settle before disposing
      await Future.delayed(const Duration(milliseconds: 500));
      container.dispose();
      await db.close();
    });

    test('full flow: start recording → transcript → submit → LLM pipeline → note created',
        () async {
      // 1. Start recording
      final recordingNotifier = container.read(recordingProvider.notifier);
      await recordingNotifier.startRecording();

      // 2. Wait for transcript
      await pumpEventQueue(times: 10);
      final recordingState = container.read(recordingProvider);
      expect(recordingState.status, RecordingStatus.recording);
      expect(recordingState.transcript, isNotEmpty);

      // 3. Stop recording
      await recordingNotifier.stopRecording();
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
      await recordingNotifier.startRecording();
      await pumpEventQueue(times: 5);
      await recordingNotifier.stopRecording();

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
      expect(note!.categoryName, 'shopping');
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

      await recordingNotifier.startRecording();
      await pumpEventQueue(times: 5);

      final transcript1 = container.read(recordingProvider).transcript;

      await recordingNotifier.pauseRecording();
      await recordingNotifier.resumeRecording();
      await pumpEventQueue(times: 5);

      final transcript2 = container.read(recordingProvider).transcript;

      expect(transcript2.length, greaterThanOrEqualTo(transcript1.length));
      expect(transcript2, startsWith(transcript1));
    });
  });
}
