import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/features/ask/domain/chat_message.dart';
import 'package:ainotes/features/ask/providers/chat_provider.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_category.dart';
import 'package:ainotes/features/notes/providers/notes_provider.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';

void main() {
  group('ChatProvider', () {
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

    test('sendMessage adds user message immediately', () async {
      final notifier = container.read(chatProvider.notifier);

      await notifier.sendMessage('Hello');

      final state = container.read(chatProvider);
      expect(state.length, greaterThanOrEqualTo(1));
      expect(state.first, isA<UserMessage>());
      expect(state.first.text, 'Hello');
    });

    test('RAG integration returns AI response', () async {
      // Create some notes first
      final notesNotifier = container.read(notesProvider.notifier);
      await notesNotifier.createNote(
        originalText: 'Buy milk and eggs',
        rewrittenText: 'Shopping list: milk, eggs',
        category: NoteCategory.shopping,
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
      // Create a note
      final notesNotifier = container.read(notesProvider.notifier);
      final note = await notesNotifier.createNote(
        originalText: 'Project deadline is next Friday',
        rewrittenText: 'Project deadline: next Friday',
        category: NoteCategory.general,
        source: NoteSource.text,
      );

      final chatNotifier = container.read(chatProvider.notifier);
      await chatNotifier.sendMessage('When is my project due?');

      final state = container.read(chatProvider);
      final aiMessages = state.whereType<AiMessage>().toList();

      expect(aiMessages, isNotEmpty);
      expect(aiMessages.first.sourceNoteIds, isNotEmpty);
      expect(aiMessages.first.sourceNoteIds, contains(note!.id));
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
