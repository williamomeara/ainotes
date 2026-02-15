import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/mock_embedding_engine.dart';
import '../../../core/ai/mock_llm_engine.dart';
import '../../../core/rag/rag_engine.dart';
import '../../processing/providers/pipeline_provider.dart';
import '../domain/chat_message.dart';

/// RAG engine provider for Q&A.
final ragEngineProvider = Provider<RAGEngine>((ref) {
  return RAGEngine(
    embeddingEngine: ref.watch(embeddingEngineProvider),
    llmEngine: ref.watch(llmEngineProvider),
    vectorStore: ref.watch(vectorStoreProvider),
  );
});

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;

  ChatNotifier(this.ref) : super([]);

  Future<void> sendMessage(String text) async {
    // Add user message
    state = [
      ...state,
      ChatMessage.user(text: text, timestamp: DateTime.now()),
    ];

    try {
      // Initialize engines if needed
      final llm = ref.read(llmEngineProvider);
      final embedding = ref.read(embeddingEngineProvider);
      if (llm is MockLLMEngine) await llm.loadModel('');
      if (embedding is MockEmbeddingEngine) await embedding.loadModel('');

      // Use RAG engine for Q&A
      final ragEngine = ref.read(ragEngineProvider);
      final result = await ragEngine.query(text);

      state = [
        ...state,
        ChatMessage.ai(
          text: result.answer,
          timestamp: DateTime.now(),
          sourceNoteIds: result.sourceNoteIds,
        ),
      ];
    } catch (_) {
      state = [
        ...state,
        ChatMessage.ai(
          text: "I'm having trouble processing your question. "
              "Try adding more notes first, then ask me again!",
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  void clear() {
    state = [];
  }
}
