import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/core/storage/database.dart';
import 'package:ainotes/core/storage/database_provider.dart';
import 'package:ainotes/core/storage/vector_store.dart';
import 'package:ainotes/features/notes/domain/note_source.dart';
import 'package:ainotes/features/processing/domain/processing_pipeline.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';

void main() {
  group('ProcessingJobProvider', () {
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
      container.dispose();
      await db.close();
    });

    test('processInput creates note with rewritten text', () async {
      final notifier = container.read(processingJobProvider.notifier);

      final note = await notifier.processInput(
        'um so like I need to get milk',
        source: NoteSource.voice,
      );

      expect(note, isNotNull);
      expect(note!.originalText, 'um so like I need to get milk');
      expect(note.rewrittenText, isNot(contains('um')));
      expect(note.rewrittenText, isNot(contains('like')));
      expect(note.source, NoteSource.voice);
    });

    test('state updates through pipeline steps', () async {
      final notifier = container.read(processingJobProvider.notifier);

      final stateUpdates = <ProcessingStep>[];
      container.listen(
        processingJobProvider,
        (previous, next) {
          if (next.currentStep != null) {
            stateUpdates.add(next.currentStep!);
          }
        },
      );

      await notifier.processInput('Test input');

      // Should progress through: rewriting → classifying → tagging → embedding
      expect(stateUpdates.length, greaterThan(0));
      expect(stateUpdates, contains(ProcessingStep.rewriting));
      expect(stateUpdates, contains(ProcessingStep.classifying));
    });

    test('classifies shopping notes correctly', () async {
      final notifier = container.read(processingJobProvider.notifier);

      final note = await notifier.processInput('Buy milk and eggs');

      expect(note, isNotNull);
      expect(note!.categoryName, 'shopping');
      expect(note.confidence, greaterThan(0.8));
    });

    test('classifies todo notes correctly', () async {
      final notifier = container.read(processingJobProvider.notifier);

      final note = await notifier.processInput('Remind me to call dentist');

      expect(note, isNotNull);
      expect(note!.categoryName, 'todos');
    });

    test('extracts tags from note text', () async {
      final notifier = container.read(processingJobProvider.notifier);

      final note = await notifier.processInput(
        'Need to buy groceries for the weekly meal prep',
      );

      expect(note, isNotNull);
      expect(note!.tags, isNotEmpty);
      expect(note.tags, anyElement(contains('groceries')));
    });

    test('error handling when LLM fails', () async {
      // Override with a failing mock
      final failingDb = AppDatabase(NativeDatabase.memory());
      final failingContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(failingDb),
          llmEngineProvider.overrideWithValue(_FailingLLMEngine()),
          embeddingEngineProvider.overrideWithValue(MockEmbeddingEngine()),
          vectorStoreProvider.overrideWithValue(InMemoryVectorStore()),
        ],
      );

      final notifier = failingContainer.read(processingJobProvider.notifier);

      final note = await notifier.processInput('Test input');

      expect(note, isNull);
      expect(failingContainer.read(processingJobProvider).error, isNotNull);

      failingContainer.dispose();
      await failingDb.close();
    });

    test('reset clears processing state', () async {
      final notifier = container.read(processingJobProvider.notifier);

      await notifier.processInput('Test input');
      notifier.reset();

      final state = container.read(processingJobProvider);
      expect(state.isProcessing, false);
      expect(state.currentStep, isNull);
      expect(state.noteId, isNull);
      expect(state.error, isNull);
    });

    test('isProcessing is true during processing', () async {
      final notifier = container.read(processingJobProvider.notifier);

      // Start processing
      final future = notifier.processInput('Test input');

      // Check state is processing
      await pumpEventQueue();
      final state = container.read(processingJobProvider);
      expect(state.isProcessing, true);

      // Wait for completion
      await future;

      // Check state is no longer processing
      final finalState = container.read(processingJobProvider);
      expect(finalState.isProcessing, false);
    });
  });
}

/// A failing LLM engine for testing error handling.
class _FailingLLMEngine extends MockLLMEngine {
  @override
  Future<String> generate(String prompt, {int? maxTokens, double? temperature}) async {
    throw Exception('LLM generation failed');
  }
}
