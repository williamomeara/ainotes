import 'dart:async';

import 'llm_engine.dart';

/// Mock LLM engine for development and testing.
/// Simulates rewriting, classification, tag extraction, and Q&A.
class MockLLMEngine implements LLMEngine {
  bool _loaded = false;

  @override
  Future<void> loadModel(String modelPath) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _loaded = true;
  }

  @override
  Stream<String> generateStream(String prompt, {int? maxTokens, double? temperature}) async* {
    _checkLoaded();
    final response = await generate(prompt);
    // Simulate streaming token by token
    final words = response.split(' ');
    for (final word in words) {
      await Future.delayed(const Duration(milliseconds: 30));
      yield '$word ';
    }
  }

  @override
  Future<String> generate(String prompt, {int? maxTokens, double? temperature}) async {
    _checkLoaded();
    await Future.delayed(const Duration(milliseconds: 200));

    final lower = prompt.toLowerCase();

    // Rewrite prompt
    if (lower.contains('rewrite') || lower.contains('clean up')) {
      return _mockRewrite(prompt);
    }

    // Combined classify + tag prompt
    if (lower.contains('classify') && lower.contains('tags')) {
      return _mockClassifyAndTag(prompt);
    }

    // Classification prompt (legacy)
    if (lower.contains('classify') || lower.contains('category')) {
      return _mockClassify(prompt);
    }

    // Tag extraction prompt
    if (lower.contains('extract tags') || lower.contains('keywords')) {
      return _mockExtractTags(prompt);
    }

    // Q&A / RAG prompt
    if (lower.contains('answer') ||
        lower.contains('question') ||
        lower.contains('based on')) {
      return _mockQA(prompt);
    }

    // Default: echo back
    return 'Processed: $prompt';
  }

  @override
  Future<void> dispose() async {
    _loaded = false;
  }

  void _checkLoaded() {
    if (!_loaded) {
      throw StateError('MockLLMEngine not loaded. Call loadModel() first.');
    }
  }

  String _mockRewrite(String prompt) {
    // Extract the text to rewrite (after the last newline or colon)
    final lines = prompt.split('\n');
    final text = lines.last.trim();
    if (text.isEmpty) return prompt;

    // Simple cleanup: capitalize, remove filler words
    var cleaned = text
        .replaceAll(RegExp(r'\b(um|uh|like|you know|so|okay)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }
    if (!cleaned.endsWith('.') && !cleaned.endsWith('!') && !cleaned.endsWith('?')) {
      cleaned += '.';
    }
    return cleaned;
  }

  String _mockClassify(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('buy') ||
        lower.contains('grocery') ||
        lower.contains('shop') ||
        lower.contains('pick up')) {
      return '{"category": "shopping", "confidence": 0.92}';
    }
    if (lower.contains('remind') ||
        lower.contains('todo') ||
        lower.contains('task') ||
        lower.contains('need to')) {
      return '{"category": "todos", "confidence": 0.88}';
    }
    if (lower.contains('idea') ||
        lower.contains('concept') ||
        lower.contains('brainstorm')) {
      return '{"category": "ideas", "confidence": 0.85}';
    }
    return '{"category": "general", "confidence": 0.75}';
  }

  String _mockClassifyAndTag(String prompt) {
    // Extract just the user's text from the prompt (after last "Text:")
    final textMatch = RegExp(r'Text:\s*"?([^"]*)"?\s*$').firstMatch(prompt);
    final userText = (textMatch?.group(1) ?? prompt).toLowerCase();

    String category = 'general';
    double confidence = 0.75;
    List<String> tags = ['notes'];

    if (RegExp(r'\b(buy|grocery|groceries|shop|pick up|store)\b').hasMatch(userText)) {
      category = 'shopping';
      confidence = 0.92;
      tags = ['groceries', 'weekly'];
    } else if (RegExp(r'\b(remind|todo|task|need to|call|send|schedule)\b').hasMatch(userText)) {
      category = 'todos';
      confidence = 0.88;
      tags = ['tasks', 'reminder'];
    } else if (RegExp(r'\b(idea|concept|brainstorm|maybe|could)\b').hasMatch(userText)) {
      category = 'ideas';
      confidence = 0.85;
      tags = ['ideas', 'creative'];
    }

    if (RegExp(r'\b(milk|food|eggs|bread)\b').hasMatch(userText)) {
      tags = ['groceries', 'weekly'];
    }
    if (RegExp(r'\b(work|meeting|report)\b').hasMatch(userText)) {
      tags = ['work', 'professional'];
    }
    if (RegExp(r'\b(dentist|doctor|appointment)\b').hasMatch(userText)) {
      tags = ['health', 'appointment'];
    }

    return '{"category": "$category", "confidence": $confidence, "tags": ${tags.map((t) => '"$t"').toList()}}';
  }

  String _mockExtractTags(String prompt) {
    final lower = prompt.toLowerCase();
    final tags = <String>[];

    if (lower.contains('grocery') || lower.contains('food') || lower.contains('milk')) {
      tags.addAll(['groceries', 'weekly']);
    }
    if (lower.contains('work') || lower.contains('meeting')) {
      tags.addAll(['work', 'professional']);
    }
    if (lower.contains('idea') || lower.contains('project')) {
      tags.addAll(['ideas', 'creative']);
    }
    if (lower.contains('call') || lower.contains('phone')) {
      tags.add('calls');
    }
    if (tags.isEmpty) tags.add('notes');

    return tags.join(', ');
  }

  String _mockQA(String prompt) {
    return 'Based on your notes, I found relevant information. '
        'This is a mock response from the on-device LLM. '
        'In production, this will use RAG to search your notes '
        'and generate grounded answers with source citations.';
  }
}
