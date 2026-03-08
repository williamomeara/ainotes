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
  /// Accepts a list of existing categories so the LLM can reuse them.
  static String classify(String text, {List<String>? existingCategories}) {
    final cats = existingCategories?.join(', ') ?? 'shopping, todos, ideas, general';
    return '''
Classify this text into exactly one category. Respond with JSON only.
Categories: $cats
You may also suggest a new category if none of the above fit well.

Text: $text

Respond in this exact format:
{"category": "<category>", "confidence": <0.0-1.0>}''';
  }

  /// Extract relevant tags/keywords from a note.
  static String extractTags(String text) => '''
Extract 2-5 relevant tags/keywords from this text.
Return only comma-separated lowercase tags, nothing else.

Text: $text''';

  /// Classify a note AND extract tags in a single LLM call.
  /// Uses few-shot examples for better accuracy.
  /// Accepts existing categories so the LLM prefers reusing them.
  static String classifyAndTag(String text, {List<String>? existingCategories}) {
    final cats = existingCategories?.join(', ') ?? 'shopping, todos, ideas, general';
    return '''
Classify this text into exactly one category and extract 2-5 relevant tags.
Existing categories: $cats
Pick one of the existing categories if it fits, or suggest a new short category name.

Examples:

Text: "I need to buy milk, eggs, and bread from the store"
{"category": "shopping", "confidence": 0.95, "tags": ["milk", "eggs", "bread"]}

Text: "Pick up screws and wood glue from the hardware store"
{"category": "shopping", "confidence": 0.90, "tags": ["screws", "wood glue", "hardware"]}

Text: "Remind me to call the dentist tomorrow"
{"category": "todos", "confidence": 0.92, "tags": ["dentist", "appointment", "call"]}

Text: "I need to send the report to Sarah by Friday"
{"category": "todos", "confidence": 0.88, "tags": ["report", "email", "deadline"]}

Text: "Idea: add a feature that converts photos to notes"
{"category": "ideas", "confidence": 0.90, "tags": ["photo", "feature", "conversion"]}

Text: "Team standup notes: John on API, Maria on login redesign"
{"category": "general", "confidence": 0.85, "tags": ["meeting", "standup", "team"]}

Text: "Recipe for pasta: boil water, add salt, cook 8 minutes, drain, add butter and cheese"
{"category": "recipes", "confidence": 0.88, "tags": ["recipe", "pasta", "cooking"]}

Now classify this text. Respond with ONLY a JSON object. Do NOT wrap it in markdown code fences.

Text: "$text"''';
  }

  /// Classify user input as a question or a note with category.
  static String classifyIntent(String text, {List<String>? existingCategories}) {
    final cats = existingCategories?.join(', ') ?? 'shopping, todos, ideas, general';
    return '''
Determine if this input is a question or a note. If it's a note, also classify its category.
Existing categories: $cats

Examples:

Input: "What groceries do I need?"
{"type": "question"}

Input: "When is my next appointment?"
{"type": "question"}

Input: "How do I make pasta?"
{"type": "question"}

Input: "I need to buy milk and bread"
{"type": "note", "category": "shopping"}

Input: "Remind me to call the dentist"
{"type": "note", "category": "todos"}

Input: "Idea: add dark mode to the app"
{"type": "note", "category": "ideas"}

Input: "Meeting notes from the team standup"
{"type": "note", "category": "general"}

Now classify this input. Respond with ONLY a JSON object. Do NOT wrap it in markdown code fences.

Input: "$text"''';
  }

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
