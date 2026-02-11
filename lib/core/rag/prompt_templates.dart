/// All LLM prompt templates for AiNotes.
/// Centralized here for easy tuning and consistency.
abstract final class PromptTemplates {
  /// Rewrite a messy transcript into a clean, organized note.
  static String rewrite(String originalText) => '''
Rewrite the following text into a clean, well-organized note.
Fix grammar, remove filler words (um, uh, like), and structure the content clearly.
Keep all important information. Use markdown formatting if helpful.

Text:
$originalText''';

  /// Classify a note into a category with confidence.
  static String classify(String text) => '''
Classify this text into exactly one category. Respond with JSON only.
Categories: shopping, todos, ideas, general

Text: $text

Respond in this exact format:
{"category": "<category>", "confidence": <0.0-1.0>}''';

  /// Extract relevant tags/keywords from a note.
  static String extractTags(String text) => '''
Extract 2-5 relevant tags/keywords from this text.
Return only comma-separated lowercase tags, nothing else.

Text: $text''';

  /// Answer a question using retrieved note context (RAG).
  static String ragAnswer({
    required String question,
    required List<String> contextChunks,
  }) {
    final context = contextChunks.asMap().entries.map((e) {
      return '[Note ${e.key + 1}]: ${e.value}';
    }).join('\n\n');

    return '''
Answer the user's question based ONLY on the following notes.
If the notes don't contain relevant information, say "I couldn't find information about that in your notes."
Cite which notes you used by number.

Notes:
$context

Question: $question

Answer:''';
  }

  /// Determine if a new note should be merged with an existing one.
  static String shouldMerge({
    required String newText,
    required String existingText,
  }) => '''
Should this new text be appended to the existing note?
Only say "yes" if they are clearly about the same topic/list.
Respond with only "yes" or "no".

Existing note: $existingText
New text: $newText''';

  /// Generate a weekly digest summary.
  static String weeklyDigest(List<String> noteSummaries) {
    final notes = noteSummaries.asMap().entries.map((e) {
      return '${e.key + 1}. ${e.value}';
    }).join('\n');

    return '''
Summarize this week's notes into a brief digest.
Group by theme, highlight key ideas, and note any pending tasks.

This week's notes:
$notes

Weekly digest:''';
  }
}
