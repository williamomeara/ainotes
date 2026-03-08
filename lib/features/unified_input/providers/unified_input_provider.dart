import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ai/mock_intent_classifier.dart';
import '../../notes/providers/notes_provider.dart';
import '../../notes/domain/note_source.dart';
import '../../ask/providers/chat_provider.dart';
import '../../processing/providers/pipeline_provider.dart';
import '../domain/input_intent.dart';

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

final unifiedInputProvider =
    StateNotifierProvider<UnifiedInputNotifier, UnifiedInputState>((ref) {
  return UnifiedInputNotifier(ref);
});

class UnifiedInputNotifier extends StateNotifier<UnifiedInputState> {
  final Ref ref;
  BuildContext? _context;

  UnifiedInputNotifier(this.ref) : super(const UnifiedInputState());

  void setContext(BuildContext context) {
    _context = context;
  }

  /// Submit input through the pipeline.
  Future<void> submitInput(String text, {required NoteSource source}) async {
    if (text.trim().isEmpty) return;

    final preview = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    debugPrint('[AiNotes] Input received: "$preview" (source: ${source.name})');

    state = state.copyWith(isProcessing: true, error: null);

    try {
      // Always use fast regex-based classifier for routing decisions.
      // The LLM intent classifier is too slow for the submit flow (10-20s).
      // Detailed LLM classification happens in the background pipeline.
      final classifier = MockIntentClassifier();
      debugPrint('[AiNotes] Routing with MockIntentClassifier (fast path)');
      final intent = await classifier.classify(text);
      debugPrint('[AiNotes] Intent result: ${intent.runtimeType} - $intent');

      switch (intent) {
        case NoteIntent():
          debugPrint('[AiNotes] -> Note route (category hint: ${intent.suggestedCategoryName})');

          final note = await ref.read(notesProvider.notifier).createNote(
                originalText: text,
                rewrittenText: '',
                categoryName: intent.suggestedCategoryName,
                confidence: 0.0,
                source: source,
                isDraft: true,
              );

          if (note != null) {
            debugPrint('[AiNotes] Draft note created: ${note.id} (isDraft=true, category=${note.categoryName})');
            state = state.copyWith(isProcessing: false);

            // Navigate to Home to show the draft card with typewriter effect
            if (_context != null && _context!.mounted) {
              _context!.go('/home');
            }

            debugPrint('[AiNotes] Launching background processing for ${note.id}');
            _processInBackground(note.id, text, source);
          } else {
            throw Exception('Failed to create draft note');
          }
          break;

        case QuestionIntent(:final question):
          debugPrint('[AiNotes] -> Ask route');
          await ref.read(chatProvider.notifier).sendMessage(question);
          if (_context != null) {
            _context!.go('/ask');
          }
          debugPrint('[AiNotes] Routed to Ask tab');
          state = state.copyWith(isProcessing: false);
          break;
      }
    } catch (e, st) {
      debugPrint('[AiNotes] Input processing FAILED: $e');
      debugPrint('[AiNotes] Stack trace: $st');
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void _processInBackground(String noteId, String text, NoteSource source) {
    ref.read(processingJobProvider.notifier).processAndUpdate(
          noteId: noteId,
          rawText: text,
          source: source,
        );
  }
}
