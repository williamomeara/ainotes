import '../ai/llm_engine.dart';
import '../rag/prompt_templates.dart';

/// Extracts tags from note text using the LLM engine.
class SmartTagger {
  final LLMEngine llmEngine;

  SmartTagger({required this.llmEngine});

  /// Extract tags from text using the LLM.
  Future<List<String>> extractTags(String text) async {
    try {
      await llmEngine.loadModel('');
      final prompt = PromptTemplates.extractTags(text);
      final response = await llmEngine.generate(prompt);

      return response
          .split(',')
          .map((t) => t.trim().toLowerCase())
          .where((t) => t.isNotEmpty && t.length < 30)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
