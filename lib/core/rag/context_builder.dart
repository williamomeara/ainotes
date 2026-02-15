import 'prompt_templates.dart';

/// Builds LLM context from retrieved chunks for RAG queries.
class ContextBuilder {
  const ContextBuilder();

  /// Build a RAG prompt from a question and retrieved note chunks.
  String buildRAGPrompt({
    required String question,
    required List<String> retrievedChunks,
    int maxChunks = 5,
  }) {
    final chunks = retrievedChunks.take(maxChunks).toList();
    return PromptTemplates.ragAnswer(
      question: question,
      contextChunks: chunks,
    );
  }

  /// Build context string from chunks (without the full prompt).
  String buildContextString(List<String> chunks) {
    return chunks.asMap().entries.map((e) {
      return '[${e.key + 1}] ${e.value}';
    }).join('\n\n');
  }
}
