import 'dart:async';

// import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'stt_engine.dart';

/// On-device Speech-to-Text engine using sherpa-onnx + Moonshine model
///
/// Moonshine is a ~26M parameter model optimized for edge devices:
/// - ~50ms latency on mobile
/// - ~200MB model size (quantized)
/// - Supports streaming (continuous recognition)
/// - 100+ languages via multilingual versions
///
/// TODO: Complete sherpa-onnx integration once API is verified
/// Currently using MockSTTEngine for Phase 2 development
class SherpaSTTEngine implements STTEngine {
  // late SherpaOnnx _recognizer;
  bool _initialized = false;

  @override
  Future<void> initialize(String modelPath) async {
    if (_initialized) return;
    // TODO: Implement sherpa-onnx initialization
    // final recognizer = SherpaOnnx.createOnlineRecognizer(
    //   modelPath: modelPath,
    //   useCtc: true,
    //   numThreads: 1,
    //   sampleRate: 16000,
    //   featureDim: 80,
    //   enableEndpoint: true,
    //   endpointThreshold: 5.0,
    // );
    _initialized = true;
  }

  @override
  Stream<String> transcribeStream(Stream<List<int>> audioStream) {
    if (!_initialized) {
      throw StateError('SherpaSTTEngine not initialized. Call initialize() first.');
    }

    // TODO: Implement sherpa-onnx streaming transcription
    return Stream<String>.empty();
  }

  @override
  Future<String> transcribe(String audioFilePath) async {
    if (!_initialized) {
      throw StateError('SherpaSTTEngine not initialized. Call initialize() first.');
    }

    // TODO: Implement sherpa-onnx file transcription
    return '';
  }

  @override
  Future<void> dispose() async {
    if (_initialized) {
      // TODO: Release sherpa-onnx resources
      _initialized = false;
    }
  }
}
