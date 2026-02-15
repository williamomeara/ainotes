import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_embedding_engine.dart';
import 'package:ainotes/core/ai/mock_llm_engine.dart';
import 'package:ainotes/features/ask/domain/chat_message.dart';
import 'package:ainotes/features/ask/providers/chat_provider.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_category.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';

void main() {
  group('Note to RAG Flow Integration', () {
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

    test('create knowledge base → ask question → verify answer cites correct sources',
        () async {
      final processingNotifier = container.read(processingJobProvider.notifier);
      final pipeline = container.read(processingPipelineProvider);

      // Create knowledge base
      final note1 = await processingNotifier.processInput(
        'Project deadline is next Friday',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note1!.id, note1.rewrittenText);

      final note2 = await processingNotifier.processInput(
        'Meeting with client on Tuesday at 2pm',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note2!.id, note2.rewrittenText);

      final note3 = await processingNotifier.processInput(
        'Buy milk and eggs',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note3!.id, note3.rewrittenText);

      // Ask question about deadline
      final chatNotifier = container.read(chatProvider.notifier);
      await chatNotifier.sendMessage('When is my project due?');

      final chatState = container.read(chatProvider);
      final aiMessages = chatState.whereType<AiMessage>().toList();

      expect(aiMessages, isNotEmpty);
      expect(aiMessages.first.text, isNotEmpty);

      // Should cite the project deadline note
      expect(aiMessages.first.sourceNoteIds, isNotEmpty);
      expect(aiMessages.first.sourceNoteIds, contains(note1.id));
    });

    test('RAG with no notes shows fallback message', () async {
      final chatNotifier = container.read(chatProvider.notifier);

      await chatNotifier.sendMessage('What are my notes about?');

      final chatState = container.read(chatProvider);
      final aiMessages = chatState.whereType<AiMessage>().toList();

      expect(aiMessages, isNotEmpty);
      // Should have some response even with no notes
      expect(aiMessages.first.text, isNotEmpty);
    });

    test('question retrieves multiple relevant notes', () async {
      final processingNotifier = container.read(processingJobProvider.notifier);
      final pipeline = container.read(processingPipelineProvider);

      // Create multiple shopping notes
      final note1 = await processingNotifier.processInput(
        'Buy milk and eggs',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note1!.id, note1.rewrittenText);

      final note2 = await processingNotifier.processInput(
        'Get bread from bakery',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note2!.id, note2.rewrittenText);

      final note3 = await processingNotifier.processInput(
        'Shopping list: butter, cheese',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note3!.id, note3.rewrittenText);

      // Ask about groceries
      final chatNotifier = container.read(chatProvider.notifier);
      await chatNotifier.sendMessage('What groceries do I need?');

      final chatState = container.read(chatProvider);
      final aiMessages = chatState.whereType<AiMessage>().toList();

      expect(aiMessages, isNotEmpty);
      expect(aiMessages.first.sources, isNotEmpty);

      // Should cite multiple shopping notes
      expect(aiMessages.first.sourceNoteIds.length, greaterThanOrEqualTo(2));
    });

    test('answer synthesizes information from multiple sources', () async {
      final processingNotifier = container.read(processingJobProvider.notifier);
      final pipeline = container.read(processingPipelineProvider);

      // Create complementary notes
      final note1 = await processingNotifier.processInput(
        'Client prefers morning meetings',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note1!.id, note1.rewrittenText);

      final note2 = await processingNotifier.processInput(
        'Client office is in downtown',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note2!.id, note2.rewrittenText);

      // Ask question requiring synthesis
      final chatNotifier = container.read(chatProvider.notifier);
      await chatNotifier.sendMessage('What do I know about the client?');

      final chatState = container.read(chatProvider);
      final aiMessages = chatState.whereType<AiMessage>().toList();

      expect(aiMessages, isNotEmpty);

      // Should cite both notes
      final sources = aiMessages.first.sources ?? [];
      expect(sources.length, greaterThanOrEqualTo(2));
    });

    test('chat history maintains conversation context', () async {
      final chatNotifier = container.read(chatProvider.notifier);

      // First message
      await chatNotifier.sendMessage('Hello');

      // Second message
      await chatNotifier.sendMessage('What can you help me with?');

      final chatState = container.read(chatProvider);
      expect(chatState.length, greaterThanOrEqualTo(4)); // 2 user + 2 AI messages

      // Messages should be in order
      final userMessages = chatState.whereType<UserMessage>().toList();
      expect(userMessages[0].text, 'Hello');
      expect(userMessages[1].text, 'What can you help me with?');
    });

    test('clearHistory removes all messages', () async {
      final chatNotifier = container.read(chatProvider.notifier);

      await chatNotifier.sendMessage('First message');
      await chatNotifier.sendMessage('Second message');

      expect(container.read(chatProvider), isNotEmpty);

      chatNotifier.clearHistory();

      expect(container.read(chatProvider), isEmpty);
    });

    test('RAG retrieval is semantically aware', () async {
      final processingNotifier = container.read(processingJobProvider.notifier);
      final pipeline = container.read(processingPipelineProvider);

      // Create note with specific terminology
      final note = await processingNotifier.processInput(
        'The quarterly financial report is due on March 31st',
        source: NoteSource.text,
      );
      await pipeline.embedNote(note!.id, note.rewrittenText);

      // Ask with different but related terminology
      final chatNotifier = container.read(chatProvider.notifier);
      await chatNotifier.sendMessage('When is the Q1 report deadline?');

      final chatState = container.read(chatProvider);
      final aiMessages = chatState.whereType<AiMessage>().toList();

      expect(aiMessages, isNotEmpty);
      expect(aiMessages.first.sources, isNotEmpty);
      expect(aiMessages.first.sources!.first.id, note.id);
    });
  });
}
