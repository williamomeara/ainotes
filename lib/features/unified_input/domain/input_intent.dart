import '../../notes/domain/note_category.dart';

sealed class InputIntent {}

class NoteIntent extends InputIntent {
  final NoteCategory suggestedCategory;
  final String cleanedText;

  NoteIntent({
    required this.suggestedCategory,
    required this.cleanedText,
  });
}

class QuestionIntent extends InputIntent {
  final String question;

  QuestionIntent({required this.question});
}
