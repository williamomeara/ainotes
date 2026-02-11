import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ai/intent_classifier.dart';
import '../../../core/ai/mock_intent_classifier.dart';
import '../../notes/providers/notes_provider.dart';
import '../../notes/domain/note_category.dart';
import '../../ask/providers/chat_provider.dart';
import '../domain/input_intent.dart';

// Provider for intent classifier
final intentClassifierProvider = Provider<IntentClassifier>((ref) {
  return MockIntentClassifier();
});

// Unified input state
class UnifiedInputState {
  final bool isProcessing;
  final String? error;

  const UnifiedInputState({
    this.isProcessing = false,
    this.error,
  });

  UnifiedInputState copyWith({bool? isProcessing, String? error}) {
    return UnifiedInputState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }
}

// Unified input provider
final unifiedInputProvider = StateNotifierProvider<UnifiedInputNotifier, UnifiedInputState>((ref) {
  return UnifiedInputNotifier(ref);
});

class UnifiedInputNotifier extends StateNotifier<UnifiedInputState> {
  final Ref ref;
  BuildContext? _context;

  UnifiedInputNotifier(this.ref) : super(const UnifiedInputState());

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> submitInput(String text, {required NoteSource source}) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(isProcessing: true, error: null);

    try {
      // Classify intent
      final classifier = ref.read(intentClassifierProvider);
      final intent = await classifier.classify(text);

      switch (intent) {
        case NoteIntent(:final suggestedCategory, :final cleanedText):
          // Create note
          await ref.read(notesProvider.notifier).createNote(
            originalText: text,
            rewrittenText: cleanedText,
            category: suggestedCategory,
            confidence: 0.8,
            source: source,
          );
          // Stay on current tab
          break;

        case QuestionIntent(:final question):
          // Send to chat
          await ref.read(chatProvider.notifier).sendMessage(question);
          // Navigate to Ask tab
          if (_context != null) {
            _context!.go('/ask');
          }
          break;
      }

      state = state.copyWith(isProcessing: false);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }
}
