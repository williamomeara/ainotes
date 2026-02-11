import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/chat_message.dart';

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  Future<void> sendMessage(String text) async {
    // Add user message
    state = [
      ...state,
      ChatMessage.user(text: text, timestamp: DateTime.now()),
    ];

    // Mock AI response after a short delay
    await Future.delayed(const Duration(milliseconds: 800));

    state = [
      ...state,
      ChatMessage.ai(
        text:
            "I found some relevant information in your notes. This is a mock response — the RAG engine will power real answers in Phase 4.",
        timestamp: DateTime.now(),
        sourceNoteIds: [],
      ),
    ];
  }

  void clear() {
    state = [];
  }
}
