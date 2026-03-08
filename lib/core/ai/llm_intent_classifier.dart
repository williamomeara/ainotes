import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/unified_input/domain/input_intent.dart';
import '../rag/prompt_templates.dart';
import 'intent_classifier.dart';
import 'llm_engine.dart';

/// Intent classifier powered by an on-device LLM.
/// Auto-loads the model on first use via [modelPath].
class LLMIntentClassifier implements IntentClassifier {
  final LLMEngine llmEngine;
  final String modelPath;
  bool _modelLoaded = false;

  LLMIntentClassifier({required this.llmEngine, required this.modelPath});

  @override
  Future<InputIntent> classify(String text) async {
    debugPrint('[AiNotes] LLMIntentClassifier.classify("${text.length > 40 ? '${text.substring(0, 40)}...' : text}")');
    debugPrint('[AiNotes] LLM engine type: ${llmEngine.runtimeType}, modelLoaded=$_modelLoaded');

    try {
      if (!_modelLoaded) {
        debugPrint('[AiNotes] LLMIntentClassifier: loading model $modelPath');
        await llmEngine.loadModel(modelPath);
        _modelLoaded = true;
        debugPrint('[AiNotes] LLMIntentClassifier: model loaded OK');
      }

      final prompt = PromptTemplates.classifyIntent(text);
      final response = await llmEngine.generate(
        prompt,
        maxTokens: 64,
        temperature: 0.1,
      );
      debugPrint('[AiNotes] LLM intent response: "$response"');

      final cleaned = _extractJson(response);
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final type = json['type'] as String?;
      debugPrint('[AiNotes] Parsed intent type: $type');

      if (type == 'question') {
        return QuestionIntent(question: text);
      }

      final categoryName = (json['category'] as String?)?.toLowerCase() ?? 'general';
      return NoteIntent(suggestedCategoryName: categoryName, cleanedText: text);
    } catch (e, st) {
      debugPrint('[AiNotes] LLMIntentClassifier FAILED: $e');
      debugPrint('[AiNotes] Stack trace: $st');
      debugPrint('[AiNotes] Falling back to regex classification');
      final lower = text.toLowerCase().trim();
      if (RegExp(r'^(what|when|where|who|how|why|find|show me)\b')
          .hasMatch(lower)) {
        return QuestionIntent(question: text);
      }
      return NoteIntent(
        suggestedCategoryName: 'general',
        cleanedText: text,
      );
    }
  }
}

String _extractJson(String raw) {
  final fenceMatch =
      RegExp(r'```(?:json)?\s*\n?(.*?)\n?\s*```', dotAll: true)
          .firstMatch(raw);
  if (fenceMatch != null) return fenceMatch.group(1)!.trim();
  final braceMatch = RegExp(r'\{[^}]+\}').firstMatch(raw);
  if (braceMatch != null) return braceMatch.group(0)!;
  return raw.trim();
}
