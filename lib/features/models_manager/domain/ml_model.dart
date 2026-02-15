import 'package:freezed_annotation/freezed_annotation.dart';

part 'ml_model.freezed.dart';
part 'ml_model.g.dart';

/// Type of ML model.
enum MLModelType {
  stt,
  llm,
  embedding;

  String get label => switch (this) {
        stt => 'Speech-to-Text',
        llm => 'Language Model',
        embedding => 'Embeddings',
      };
}

/// Metadata for an ML model.
@freezed
class MLModel with _$MLModel {
  const factory MLModel({
    required String id,
    required String name,
    required String description,
    required MLModelType type,
    required int sizeBytes,
    String? downloadUrl,
    String? localPath,
    @Default(false) bool isDownloaded,
    @Default(false) bool isActive,
  }) = _MLModel;

  factory MLModel.fromJson(Map<String, dynamic> json) =>
      _$MLModelFromJson(json);
}

/// Predefined model registry.
abstract final class ModelRegistry {
  static const List<MLModel> availableModels = [
    // Moonshine commented out until sherpa_onnx integration complete
    // Will use MockSTTEngine for voice transcription (works fine)
    // MLModel(
    //   id: 'moonshine-tiny',
    //   name: 'Moonshine Tiny',
    //   description: 'Fast speech-to-text, ~50ms latency',
    //   type: MLModelType.stt,
    //   sizeBytes: 200 * 1024 * 1024, // 200MB
    //   downloadUrl:
    //       'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-moonshine-tiny-en-int8.tar.bz2',
    // ),
    MLModel(
      id: 'qwen-2.5-1.5b',
      name: 'Qwen 2.5 1.5B',
      description: 'General-purpose LLM for rewriting & classification',
      type: MLModelType.llm,
      sizeBytes: 900 * 1024 * 1024, // 900MB
      downloadUrl:
          'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
    ),
    MLModel(
      id: 'embedding-gemma-300m',
      name: 'EmbeddingGemma 300M',
      description: 'Semantic embeddings for RAG & search',
      type: MLModelType.embedding,
      sizeBytes: 200 * 1024 * 1024, // 200MB
      downloadUrl:
          'https://huggingface.co/litert-community/embeddinggemma-300m/resolve/main/embeddinggemma-300M_seq1024_mixed-precision.tflite',
    ),
  ];
}
