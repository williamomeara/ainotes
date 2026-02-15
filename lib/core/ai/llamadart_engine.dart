import 'dart:async';
import 'dart:io';

import 'package:llamadart/llamadart.dart';

import 'llm_engine.dart';

/// Real on-device LLM engine using llamadart (llama.cpp bindings).
/// Runs GGUF models locally for rewriting, classification, and Q&A.
class LlamaDartEngine implements LLMEngine {
  LlamaEngine? _engine;
  bool _loaded = false;

  @override
  Future<void> loadModel(String modelPath) async {
    if (_loaded && _engine != null) return;

    if (modelPath.isEmpty) {
      throw ArgumentError('Model path cannot be empty');
    }

    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      throw ArgumentError('Model file not found: $modelPath');
    }

    if (!modelPath.toLowerCase().endsWith('.gguf')) {
      throw ArgumentError('Invalid model format (expected .gguf): $modelPath');
    }

    _engine = LlamaEngine(LlamaBackend());

    try {
      await _engine!.loadModel(modelPath);
      _loaded = true;
    } catch (e) {
      _engine = null;
      _loaded = false;
      throw Exception('Failed to load GGUF model: $e');
    }
  }

  @override
  Stream<String> generateStream(String prompt) async* {
    _checkLoaded();
    await for (final token in _engine!.generate(prompt)) {
      yield token;
    }
  }

  @override
  Future<String> generate(String prompt) async {
    _checkLoaded();
    final buffer = StringBuffer();
    await for (final token in _engine!.generate(prompt)) {
      buffer.write(token);
    }
    return buffer.toString().trim();
  }

  @override
  Future<void> dispose() async {
    if (_engine != null) {
      await _engine!.dispose();
      _engine = null;
    }
    _loaded = false;
  }

  void _checkLoaded() {
    if (!_loaded || _engine == null) {
      throw StateError(
          'LlamaDartEngine not loaded. Call loadModel() first.');
    }
  }
}
