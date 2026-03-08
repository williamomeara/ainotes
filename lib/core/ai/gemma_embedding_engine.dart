import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

import 'embedding_engine.dart';

/// Real on-device embedding engine using flutter_gemma (EmbeddingGemma 300M).
/// Produces 768-dimensional vectors for semantic search and RAG.
class GemmaEmbeddingEngine implements EmbeddingEngine {
  EmbeddingModel? _embedder;
  bool _loaded = false;

  /// Model and tokenizer URLs for EmbeddingGemma 300M (public, no auth required).
  static const modelUrl =
      'https://huggingface.co/kontextdev/embeddinggemma-300m-litertlm/resolve/main/embeddinggemma-300M_seq512_mixed-precision.tflite';
  static const tokenizerUrl =
      'https://huggingface.co/sentence-transformers/embeddinggemma-300m-medical/resolve/main/tokenizer.model';

  /// Filenames derived from the download URLs.
  static const modelFilename =
      'embeddinggemma-300M_seq512_mixed-precision.tflite';
  static const tokenizerFilename = 'tokenizer.model';

  @override
  Future<void> loadModel(String modelPath) async {
    if (_loaded && _embedder != null) return;

    try {
      _embedder = await FlutterGemma.getActiveEmbedder(
        preferredBackend: PreferredBackend.cpu,
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

  /// Get the local file paths for the embedding model and tokenizer.
  static Future<({String modelPath, String tokenizerPath})>
      localFilePaths() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return (
      modelPath: '${appDocDir.path}/$modelFilename',
      tokenizerPath: '${appDocDir.path}/$tokenizerFilename',
    );
  }

  /// Check if both model and tokenizer files exist locally.
  static Future<bool> isInstalled() async {
    final paths = await localFilePaths();
    return await File(paths.modelPath).exists() &&
        await File(paths.tokenizerPath).exists();
  }

  /// Install the embedding model and tokenizer by downloading directly with
  /// FileDownloader, then registering with flutter_gemma via file paths.
  ///
  /// This bypasses flutter_gemma's SmartDownloader (which has a broadcast
  /// stream bug in v0.12.3 that kills the cached stream after first use).
  ///
  /// [onModelProgress] and [onTokenizerProgress] report download progress 0.0-1.0.
  static Future<void> installModel({
    void Function(double)? onModelProgress,
    void Function(double)? onTokenizerProgress,
  }) async {
    final paths = await localFilePaths();

    // Phase 1: Download model .tflite (~179MB)
    final modelTask = DownloadTask(
      url: modelUrl,
      filename: modelFilename,
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      retries: 3,
    );

    final modelResult = await FileDownloader().download(
      modelTask,
      onProgress: (progress) {
        if (progress >= 0) onModelProgress?.call(progress);
      },
    );

    if (modelResult.status != TaskStatus.complete) {
      throw Exception(
        'Model download failed: ${modelResult.exception?.description ?? 'unknown error'}',
      );
    }

    // Phase 2: Download tokenizer .model (~5MB)
    final tokenizerTask = DownloadTask(
      url: tokenizerUrl,
      filename: tokenizerFilename,
      baseDirectory: BaseDirectory.applicationDocuments,
      updates: Updates.statusAndProgress,
      retries: 3,
    );

    final tokenizerResult = await FileDownloader().download(
      tokenizerTask,
      onProgress: (progress) {
        if (progress >= 0) onTokenizerProgress?.call(progress);
      },
    );

    if (tokenizerResult.status != TaskStatus.complete) {
      // Cleanup: delete model file if tokenizer download failed
      final modelFile = File(paths.modelPath);
      if (await modelFile.exists()) {
        await modelFile.delete();
      }
      throw Exception(
        'Tokenizer download failed: ${tokenizerResult.exception?.description ?? 'unknown error'}',
      );
    }

    // Phase 3: Register with flutter_gemma via file paths (uses FileSourceHandler,
    // completely bypasses SmartDownloader)
    await FlutterGemma.installEmbedder()
        .modelFromFile(paths.modelPath)
        .tokenizerFromFile(paths.tokenizerPath)
        .install();
  }
}
