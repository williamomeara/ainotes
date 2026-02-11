import 'dart:convert';

import '../../../core/ai/llm_engine.dart';
import '../../../core/ai/embedding_engine.dart';
import '../../../core/rag/chunker.dart';
import '../../../core/rag/prompt_templates.dart';
import '../../../core/storage/vector_store.dart';
import '../../notes/domain/note_category.dart';

/// Step in the processing pipeline.
enum ProcessingStep {
  transcribing,
  rewriting,
  classifying,
  embedding;

  String get label => switch (this) {
        transcribing => 'Transcribing',
        rewriting => 'Rewriting',
        classifying => 'Classifying',
        embedding => 'Embedding',
      };

  String get detail => switch (this) {
        transcribing => 'Cleaning up your transcript...',
        rewriting => 'Making it clear and concise...',
        classifying => 'Finding the right category...',
        embedding => 'Connecting to your knowledge...',
      };
}

/// Result of processing a raw input through the pipeline.
class ProcessingResult {
  final String originalText;
  final String rewrittenText;
  final NoteCategory category;
  final double confidence;
  final List<String> tags;

  const ProcessingResult({
    required this.originalText,
    required this.rewrittenText,
    required this.category,
    required this.confidence,
    required this.tags,
  });
}

/// Callback for pipeline progress updates.
typedef OnStepChanged = void Function(ProcessingStep step);

/// Orchestrates the full processing pipeline:
/// input text -> rewrite -> classify -> extract tags -> embed -> save
class ProcessingPipeline {
  final LLMEngine llmEngine;
  final EmbeddingEngine embeddingEngine;
  final VectorStore vectorStore;
  final Chunker chunker;

  ProcessingPipeline({
    required this.llmEngine,
    required this.embeddingEngine,
    required this.vectorStore,
    this.chunker = const Chunker(),
  });

  /// Process raw input text through the full pipeline.
  Future<ProcessingResult> process(
    String rawText, {
    OnStepChanged? onStep,
  }) async {
    // Step 1: Transcription (already done - text is input)
    onStep?.call(ProcessingStep.transcribing);
    await Future.delayed(const Duration(milliseconds: 300));

    // Step 2: Rewrite
    onStep?.call(ProcessingStep.rewriting);
    final rewritePrompt = PromptTemplates.rewrite(rawText);
    final rewrittenText = await llmEngine.generate(rewritePrompt);

    // Step 3: Classify
    onStep?.call(ProcessingStep.classifying);
    final classifyPrompt = PromptTemplates.classify(rewrittenText);
    final classifyResponse = await llmEngine.generate(classifyPrompt);

    NoteCategory category;
    double confidence;
    try {
      final json = jsonDecode(classifyResponse) as Map<String, dynamic>;
      category = NoteCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => NoteCategory.general,
      );
      confidence = (json['confidence'] as num?)?.toDouble() ?? 0.7;
    } catch (_) {
      category = NoteCategory.general;
      confidence = 0.5;
    }

    // Extract tags
    final tagPrompt = PromptTemplates.extractTags(rewrittenText);
    final tagResponse = await llmEngine.generate(tagPrompt);
    final tags = tagResponse
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();

    // Step 4: Embed
    onStep?.call(ProcessingStep.embedding);
    // Embedding happens after note is saved (needs note ID)

    return ProcessingResult(
      originalText: rawText,
      rewrittenText: rewrittenText,
      category: category,
      confidence: confidence,
      tags: tags,
    );
  }

  /// Embed a note's text and store in vector store.
  Future<void> embedNote(String noteId, String text) async {
    final chunks = chunker.chunk(text);
    if (chunks.isEmpty) return;

    final embeddings = await embeddingEngine.embedBatch(chunks);
    for (var i = 0; i < chunks.length; i++) {
      await vectorStore.addChunk(
        noteId: noteId,
        chunkIndex: i,
        text: chunks[i],
        embedding: embeddings[i],
      );
    }
  }
}
