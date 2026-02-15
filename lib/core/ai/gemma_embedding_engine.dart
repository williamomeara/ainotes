import 'package:flutter_gemma/flutter_gemma.dart';

import 'embedding_engine.dart';

/// Real on-device embedding engine using flutter_gemma (EmbeddingGemma 300M).
/// Produces 768-dimensional vectors for semantic search and RAG.
class GemmaEmbeddingEngine implements EmbeddingEngine {
  EmbeddingModel? _embedder;
  bool _loaded = false;

  /// Model and tokenizer URLs for EmbeddingGemma 300M.
  static const modelUrl =
      'https://huggingface.co/litert-community/embeddinggemma-300m/resolve/main/embeddinggemma-300M_seq1024_mixed-precision.tflite';
  static const tokenizerUrl =
      'https://huggingface.co/litert-community/embeddinggemma-300m/resolve/main/sentencepiece.model';

  @override
  Future<void> loadModel(String modelPath) async {
    if (_loaded && _embedder != null) return;

    try {
      _embedder = await FlutterGemma.getActiveEmbedder(
        preferredBackend: PreferredBackend.gpu,
      );

      if (_embedder == null) {
        throw StateError(
            'No active embedder found. Model may not be installed.');
      }

      _loaded = true;
    } catch (e) {
      _embedder = null;
      _loaded = false;

      if (e.toString().contains('not installed')) {
        throw StateError(
          'EmbeddingGemma model not installed. Download it from AI Models settings.',
        );
      }
      throw Exception('Failed to load embedder: $e');
    }
  }

  @override
  Future<List<double>> embed(String text) async {
    _checkLoaded();
    return await _embedder!.generateEmbedding(text);
  }

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    _checkLoaded();
    return await _embedder!.generateEmbeddings(texts);
  }

  @override
  Future<void> dispose() async {
    if (_embedder != null) {
      await _embedder!.close();
      _embedder = null;
    }
    _loaded = false;
  }

  void _checkLoaded() {
    if (!_loaded || _embedder == null) {
      throw StateError(
          'GemmaEmbeddingEngine not loaded. Call loadModel() first.');
    }
  }

  /// Install the embedding model and tokenizer (call once before loadModel).
  /// [onModelProgress] and [onTokenizerProgress] report download progress 0.0-1.0.
  static Future<void> installModel({
    String? huggingFaceToken,
    void Function(double)? onModelProgress,
    void Function(double)? onTokenizerProgress,
  }) async {
    var installer = FlutterGemma.installEmbedder()
        .modelFromNetwork(modelUrl, token: huggingFaceToken)
        .tokenizerFromNetwork(tokenizerUrl);

    if (onModelProgress != null) {
      installer = installer.withModelProgress(
          (progress) => onModelProgress(progress / 100.0));
    }
    if (onTokenizerProgress != null) {
      installer = installer.withTokenizerProgress(
          (progress) => onTokenizerProgress(progress / 100.0));
    }

    await installer.install();
  }
}
