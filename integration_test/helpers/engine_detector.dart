import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ainotes/core/ai/gemma_embedding_engine.dart';

/// What engines are available on this device.
class EngineAvailability {
  final bool llmAvailable;
  final String? llmModelPath;
  final bool embeddingAvailable;

  const EngineAvailability({
    required this.llmAvailable,
    this.llmModelPath,
    required this.embeddingAvailable,
  });

  @override
  String toString() =>
      'EngineAvailability(llm: $llmAvailable, embedding: $embeddingAvailable)';
}

/// Probes the device to determine which real AI engines are available.
class EngineDetector {
  static const _llmFileName = 'qwen2.5-1.5b-instruct-q4_k_m.gguf';

  /// Search paths for the model file, in order of preference.
  static const _fallbackPaths = [
    '/data/local/tmp/$_llmFileName',
  ];

  /// Detect which engines are available on the current device.
  static Future<EngineAvailability> detect() async {
    debugPrint('[ENGINE] Starting engine detection...');

    // --- LLM ---
    final appDocDir = await getApplicationDocumentsDirectory();
    final searchPaths = [
      '${appDocDir.path}/models/$_llmFileName',
      ..._fallbackPaths,
    ];

    String? foundLlmPath;
    for (final path in searchPaths) {
      final file = File(path);
      if (await file.exists()) {
        final size = await file.length();
        debugPrint(
            '[ENGINE] LLM model FOUND: $path (${(size / 1024 / 1024).toStringAsFixed(1)} MB)');
        foundLlmPath = path;
        break;
      } else {
        debugPrint('[ENGINE] LLM model not at $path');
      }
    }

    final llmAvailable = foundLlmPath != null;
    if (!llmAvailable) {
      debugPrint('[ENGINE] LLM model NOT FOUND in any search path');
    }

    // --- Embedding ---
    bool embeddingAvailable = false;
    try {
      embeddingAvailable = await GemmaEmbeddingEngine.isInstalled();
      if (embeddingAvailable) {
        debugPrint('[ENGINE] Embedding model FOUND (GemmaEmbeddingEngine installed)');
      } else {
        debugPrint('[ENGINE] Embedding model NOT FOUND (files missing)');
      }
    } catch (e) {
      debugPrint('[ENGINE] Embedding detection failed: $e');
    }

    final result = EngineAvailability(
      llmAvailable: llmAvailable,
      llmModelPath: foundLlmPath,
      embeddingAvailable: embeddingAvailable,
    );

    debugPrint('[ENGINE] Detection complete: $result');
    return result;
  }
}
