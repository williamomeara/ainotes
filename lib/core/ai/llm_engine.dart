abstract class LLMEngine {
  Future<void> loadModel(String modelPath);
  Stream<String> generateStream(String prompt);
  Future<String> generate(String prompt);
  Future<void> dispose();
}
