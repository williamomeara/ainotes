sealed class InputIntent {}

class NoteIntent extends InputIntent {
  final String suggestedCategoryName;
  final String cleanedText;

  NoteIntent({
    required this.suggestedCategoryName,
    required this.cleanedText,
  });
}

class QuestionIntent extends InputIntent {
  final String question;

  QuestionIntent({required this.question});
}
