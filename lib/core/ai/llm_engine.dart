abstract class LLMEngine {
  Future<void> loadModel(String modelPath);
  Stream<String> generateStream(String prompt, {int? maxTokens, double? temperature});
  Future<String> generate(String prompt, {int? maxTokens, double? temperature});
  Future<void> dispose();
}
