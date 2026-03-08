import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/core/storage/database.dart';
import 'package:ainotes/core/storage/database_provider.dart';
import 'package:ainotes/core/storage/vector_store.dart';
import 'package:ainotes/features/ask/domain/chat_message.dart';
import 'package:ainotes/features/ask/providers/chat_provider.dart';
import 'package:ainotes/features/notes/domain/note_source.dart';
import 'package:ainotes/features/notes/providers/notes_provider.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';

void main() {
  group('ChatProvider', () {
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

    test('sendMessage adds user message immediately', () async {
      final notifier = container.read(chatProvider.notifier);

      await notifier.sendMessage('Hello');

      final state = container.read(chatProvider);
      expect(state.length, greaterThanOrEqualTo(1));
      expect(state.first, isA<UserMessage>());
      expect((state.first as UserMessage).text, 'Hello');
    });

    test('RAG integration returns AI response', () async {
      // Create some notes first
      final notesNotifier = container.read(notesProvider.notifier);
      await notesNotifier.createNote(
        originalText: 'Buy milk and eggs',
        rewrittenText: 'Shopping list: milk, eggs',
        categoryName: 'shopping',
        source: NoteSource.text,
      );

      final chatNotifier = container.read(chatProvider.notifier);
      await chatNotifier.sendMessage('What groceries do I need?');

      final state = container.read(chatProvider);
      expect(state.length, greaterThanOrEqualTo(2));

      // Should have user message and AI response
      final aiMessages = state.whereType<AiMessage>().toList();
      expect(aiMessages, isNotEmpty);
      expect(aiMessages.first.text, isNotEmpty);
    });

    test('AI response includes sources when notes exist', () async {
      // Create a note with text that overlaps heavily with the query
      final notesNotifier = container.read(notesProvider.notifier);
      final note = await notesNotifier.createNote(
        originalText: 'Buy milk and eggs from the grocery store',
        rewrittenText: 'Buy milk and eggs from the grocery store',
        categoryName: 'shopping',
        source: NoteSource.text,
      );

      // Load embedding engine and embed the note so RAG can find it
      final embedding = container.read(embeddingEngineProvider);
      await embedding.loadModel('');
      final pipeline = container.read(processingPipelineProvider);
      await pipeline.embedNote(note!.id, note.rewrittenText);

      // Query with significant word overlap for mock embeddings
      final chatNotifier = container.read(chatProvider.notifier);
      await chatNotifier.sendMessage('Buy milk from the grocery store');

      final state = container.read(chatProvider);
      final aiMessages = state.whereType<AiMessage>().toList();

      expect(aiMessages, isNotEmpty);
      expect(aiMessages.first.sourceNoteIds, isNotEmpty);
      expect(aiMessages.first.sourceNoteIds, contains(note.id));
    });

    test('error handling when no notes exist', () async {
      final notifier = container.read(chatProvider.notifier);

      await notifier.sendMessage('What notes do I have?');

      final state = container.read(chatProvider);
      final aiMessages = state.whereType<AiMessage>().toList();

      // Should still respond even with no notes
      expect(aiMessages, isNotEmpty);
    });

    test('clear removes all messages', () {
      final notifier = container.read(chatProvider.notifier);

      notifier.clear();

      final state = container.read(chatProvider);
      expect(state, isEmpty);
    });

    test('multiple messages maintain order', () async {
      final notifier = container.read(chatProvider.notifier);

      await notifier.sendMessage('First message');
      await notifier.sendMessage('Second message');

      final state = container.read(chatProvider);
      final userMessages = state.whereType<UserMessage>().toList();

      expect(userMessages.length, greaterThanOrEqualTo(2));
      expect(userMessages[0].text, 'First message');
      expect(userMessages[1].text, 'Second message');
    });
  });
}
