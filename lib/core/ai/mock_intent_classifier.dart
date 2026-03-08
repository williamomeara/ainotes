import 'intent_classifier.dart';
import '../../features/unified_input/domain/input_intent.dart';

class MockIntentClassifier implements IntentClassifier {
  @override
  Future<InputIntent> classify(String text) async {
    final lower = text.toLowerCase().trim();

    // Question patterns
    if (RegExp(r'^(what|when|where|who|how|why|find|show me)\b').hasMatch(lower)) {
      return QuestionIntent(question: text);
    }

    // Shopping patterns (check before todos)
    if (RegExp(r'\b(buy|get|purchase|pick up|grocery|groceries)\b').hasMatch(lower)) {
      return NoteIntent(
        suggestedCategoryName: 'shopping',
        cleanedText: text,
      );
    }

    // Todo patterns
    if (RegExp(r'\b(remind me|need to|dont forget|todo|task)\b').hasMatch(lower)) {
      return NoteIntent(
        suggestedCategoryName: 'todos',
        cleanedText: text,
      );
    }

    // Ideas patterns
    if (RegExp(r'\b(idea|concept|maybe|could|brainstorm)\b').hasMatch(lower)) {
      return NoteIntent(
        suggestedCategoryName: 'ideas',
        cleanedText: text,
      );
    }

    // Default: general note
    return NoteIntent(
      suggestedCategoryName: 'general',
      cleanedText: text,
    );
  }
}
