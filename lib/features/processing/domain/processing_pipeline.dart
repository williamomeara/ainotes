import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/ai/llm_engine.dart';
import '../../../core/ai/embedding_engine.dart';
import '../../../core/rag/chunker.dart';
import '../../../core/rag/prompt_templates.dart';
import '../../../core/storage/vector_store.dart';

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
  final String categoryName;
  final double confidence;
  final List<String> tags;

  const ProcessingResult({
    required this.originalText,
    required this.rewrittenText,
    required this.categoryName,
    required this.confidence,
    required this.tags,
  });
}

/// Callback for pipeline progress updates.
typedef OnStepChanged = void Function(ProcessingStep step);

/// Orchestrates the full processing pipeline:
/// input text -> rewrite -> classify+tag -> embed -> save
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
  /// [existingCategories] is passed to the prompt so the LLM prefers reusing them.
  Future<ProcessingResult> process(
    String rawText, {
    OnStepChanged? onStep,
    List<String>? existingCategories,
  }) async {
    debugPrint('[AiNotes] Pipeline.process() starting (${rawText.length} chars)');

    // Step 1: Transcription (already done - text is input)
    onStep?.call(ProcessingStep.transcribing);
    await Future.delayed(const Duration(milliseconds: 300));

    // Step 2: Rewrite (maxTokens=512, temp=0.3)
    onStep?.call(ProcessingStep.rewriting);
    final rewritePrompt = PromptTemplates.rewrite(rawText);
    final rewrittenText = await llmEngine.generate(
      rewritePrompt,
      maxTokens: 512,
      temperature: 0.3,
    );
    debugPrint('[AiNotes] Rewrite complete: ${rewrittenText.length} chars');

    // Step 3: Classify + Tag in a single LLM call (maxTokens=128, temp=0.1)
    onStep?.call(ProcessingStep.classifying);
    final classifyPrompt = PromptTemplates.classifyAndTag(
      rewrittenText,
      existingCategories: existingCategories,
    );
    final classifyResponse = await llmEngine.generate(
      classifyPrompt,
      maxTokens: 128,
      temperature: 0.1,
    );

    String categoryName;
    double confidence;
    List<String> tags;
    try {
      final cleaned = _extractJson(classifyResponse);
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      categoryName = (json['category'] as String?)?.toLowerCase() ?? 'general';
      confidence = (json['confidence'] as num?)?.toDouble() ?? 0.7;
      final rawTags = json['tags'];
      if (rawTags is List) {
        tags = rawTags
            .map((t) => t.toString().trim().toLowerCase())
            .where((t) => t.isNotEmpty)
            .toList();
      } else {
        tags = _fallbackTags(rewrittenText);
      }
    } catch (e) {
      debugPrint('[AiNotes] Classify+tag JSON parse failed, defaulting: $e');
      categoryName = 'general';
      confidence = 0.5;
      tags = _fallbackTags(rewrittenText);
    }
    debugPrint('[AiNotes] Classified as: $categoryName ($confidence)');
    debugPrint('[AiNotes] Tags extracted: $tags');

    // Step 4: Embed
    onStep?.call(ProcessingStep.embedding);

    return ProcessingResult(
      originalText: rawText,
      rewrittenText: rewrittenText,
      categoryName: categoryName,
      confidence: confidence,
      tags: tags,
    );
  }

  /// Embed a note's text and store in vector store.
  Future<void> embedNote(String noteId, String text) async {
    final chunks = chunker.chunk(text);
    if (chunks.isEmpty) {
      debugPrint('[AiNotes] embedNote: no chunks for note $noteId');
      return;
    }

    debugPrint('[AiNotes] embedNote: ${chunks.length} chunks for note $noteId');
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

/// Extract a JSON object from LLM output that may be wrapped in
/// markdown code fences.
String _extractJson(String raw) {
  final fenceMatch =
      RegExp(r'```(?:json)?\s*\n?(.*?)\n?\s*```', dotAll: true)
          .firstMatch(raw);
  if (fenceMatch != null) return fenceMatch.group(1)!.trim();
  final braceMatch = RegExp(r'\{[^}]+\}').firstMatch(raw);
  if (braceMatch != null) return braceMatch.group(0)!;
  return raw.trim();
}

/// Simple fallback tag extraction when JSON parsing fails.
List<String> _fallbackTags(String text) {
  return text
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 3)
      .take(5)
      .map((w) => w.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''))
      .where((w) => w.isNotEmpty)
      .toList();
}
