abstract class EmbeddingEngine {
  Future<void> loadModel(String modelPath);
  Future<List<double>> embed(String text);
  Future<List<List<double>>> embedBatch(List<String> texts);
  Future<void> dispose();
}
