abstract class STTEngine {
  Future<void> initialize(String modelPath);
  Stream<String> transcribeStream(Stream<List<int>> audioStream);
  Future<String> transcribe(String audioFilePath);
  Future<void> dispose();
}
