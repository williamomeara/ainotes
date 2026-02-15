import '../ai/llm_engine.dart';
import '../rag/prompt_templates.dart';
import '../../features/notes/domain/note.dart';

/// Result of a weekly digest generation.
class DigestResult {
  final String summary;
  final int totalNotes;
  final Map<String, int> categoryCounts;
  final List<String> topTags;

  const DigestResult({
    required this.summary,
    required this.totalNotes,
    required this.categoryCounts,
    required this.topTags,
  });
}

/// Generates weekly summaries of notes using the LLM.
class WeeklyDigest {
  final LLMEngine llmEngine;

  WeeklyDigest({required this.llmEngine});

  /// Generate a digest for the given notes.
  Future<DigestResult> generate(List<Note> notes) async {
    if (notes.isEmpty) {
      return const DigestResult(
        summary: 'No notes this week. Start recording to build your knowledge base!',
        totalNotes: 0,
        categoryCounts: {},
        topTags: [],
      );
    }

    // Count categories
    final categoryCounts = <String, int>{};
    final allTags = <String>[];
    final summaries = <String>[];

    for (final note in notes) {
      categoryCounts[note.category.name] =
          (categoryCounts[note.category.name] ?? 0) + 1;
      allTags.addAll(note.tags);
      summaries.add(note.rewrittenText.length > 100
          ? '${note.rewrittenText.substring(0, 100)}...'
          : note.rewrittenText);
    }

    // Find top tags
    final tagCounts = <String, int>{};
    for (final tag in allTags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }
    final topTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Generate summary using LLM
    String summary;
    try {
      await llmEngine.loadModel('');
      final prompt = PromptTemplates.weeklyDigest(summaries);
      summary = await llmEngine.generate(prompt);
    } catch (_) {
      summary = 'You created ${notes.length} notes this week across '
          '${categoryCounts.length} categories.';
    }

    return DigestResult(
      summary: summary,
      totalNotes: notes.length,
      categoryCounts: categoryCounts,
      topTags: topTags.take(5).map((e) => e.key).toList(),
    );
  }
}
