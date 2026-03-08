import 'dart:io';

import 'package:llamadart/llamadart.dart';

import 'llm_engine.dart';

/// Real on-device LLM engine using llamadart (llama.cpp bindings).
/// Runs GGUF models locally for rewriting, classification, and Q&A.
///
/// Uses [ChatSession] to apply the model's chat template automatically
/// (e.g. Qwen's `<|im_start|>` format), which is required for
/// instruction-tuned models to produce coherent output.
class LlamaDartEngine implements LLMEngine {
  LlamaEngine? _engine;
  bool _loaded = false;

  static const _defaultParams = GenerationParams(
    maxTokens: 512,
    temp: 0.3,
    topP: 0.9,
    penalty: 1.1,
  );

  static const _systemPrompt =
      'You are a helpful assistant that processes notes. '
      'Follow instructions precisely and respond concisely.';

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
      await _engine!.loadModel(
        modelPath,
        modelParams: const ModelParams(gpuLayers: 0, contextSize: 2048),
      );
      _loaded = true;
    } catch (e) {
      _engine = null;
      _loaded = false;
      throw Exception('Failed to load GGUF model: $e');
    }
  }

  @override
  Stream<String> generateStream(String prompt, {int? maxTokens, double? temperature}) {
    _checkLoaded();
    return ChatSession.singleTurnStream(
      _engine!,
      _buildMessages(prompt),
      params: _makeParams(maxTokens: maxTokens, temperature: temperature),
    );
  }

  @override
  Future<String> generate(String prompt, {int? maxTokens, double? temperature}) async {
    _checkLoaded();
    return ChatSession.singleTurn(
      _engine!,
      _buildMessages(prompt),
      params: _makeParams(maxTokens: maxTokens, temperature: temperature),
    );
  }

  GenerationParams _makeParams({int? maxTokens, double? temperature}) {
    return GenerationParams(
      maxTokens: maxTokens ?? _defaultParams.maxTokens,
      temp: temperature ?? _defaultParams.temp,
      topP: _defaultParams.topP,
      penalty: _defaultParams.penalty,
    );
  }

  @override
  Future<void> dispose() async {
    if (_engine != null) {
      await _engine!.dispose();
      _engine = null;
    }
    _loaded = false;
  }

  List<LlamaChatMessage> _buildMessages(String prompt) {
    return [
      LlamaChatMessage.text(
        role: LlamaChatRole.system,
        content: _systemPrompt,
      ),
      LlamaChatMessage.text(
        role: LlamaChatRole.user,
        content: prompt,
      ),
    ];
  }

  void _checkLoaded() {
    if (!_loaded || _engine == null) {
      throw StateError(
          'LlamaDartEngine not loaded. Call loadModel() first.');
    }
  }
}
