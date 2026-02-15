# Manual Native Engine Tests

These tests require actual AI model files (~1.1GB total) and cannot run in automated CI/CD pipelines.

## Prerequisites

### 1. Download Model Files

**Qwen 2.5 1.5B (900MB)**
```bash
curl -L -o test/manual_native/fixtures/qwen2.5-1.5b-instruct-q4_k_m.gguf \
  https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf
```

**EmbeddingGemma 300M (200MB)**

Install via flutter_gemma plugin:
```dart
await FlutterGemma.initialize();
await FlutterGemma.installEmbedder()
  .modelFromNetwork('https://huggingface.co/litert-community/embeddinggemma-300m/resolve/main/embeddinggemma-300M_seq1024_mixed-precision.tflite')
  .tokenizerFromNetwork('https://huggingface.co/litert-community/embeddinggemma-300m/resolve/main/sentencepiece.model')
  .install();
```

### 2. Verify Model Files

```bash
# Qwen model should be ~900MB
ls -lh test/manual_native/fixtures/qwen2.5-1.5b-instruct-q4_k_m.gguf

# EmbeddingGemma installed via flutter_gemma (check app storage)
```

## Running Manual Tests

### Run All Manual Tests

```bash
flutter test test/manual_native/
```

### Run Individual Test Files

**LlamaDart Engine Test**
```bash
flutter test test/manual_native/llamadart_engine_test.dart
```

**Gemma Embedding Engine Test**
```bash
flutter test test/manual_native/gemma_embedding_engine_test.dart
```

**Native RAG Integration Test**
```bash
flutter test test/manual_native/native_rag_integration_test.dart
```

## Expected Results

### LlamaDart Engine Test
- ✅ Model loads successfully from GGUF file
- ✅ Rewriting removes filler words (um, uh, like)
- ✅ Classification returns valid category with confidence
- ✅ Tag extraction finds relevant keywords

### Gemma Embedding Engine Test
- ✅ Model loads successfully
- ✅ Embedding produces 768-dimensional vectors
- ✅ Similar texts have higher cosine similarity (>0.7)
- ✅ Dissimilar texts have lower cosine similarity (<0.5)

### Native RAG Integration Test
- ✅ End-to-end flow: create note → embed → query → answer
- ✅ Answer cites correct source notes
- ✅ Answer quality is coherent and relevant
- ✅ Multiple sources are synthesized correctly

## Performance Benchmarks

| Operation | Expected Time | Memory Usage |
|-----------|---------------|--------------|
| Load Qwen model | <5s | ~400MB |
| LLM rewrite (50 tokens) | <3s | ~500MB |
| Load EmbeddingGemma | <2s | ~200MB |
| Generate embedding | <500ms | ~250MB |
| RAG query (3 sources) | <5s | ~600MB |

## Troubleshooting

### "Model file not found"
- Ensure models are in `test/manual_native/fixtures/`
- Check file permissions

### "Out of memory"
- Close other apps
- Use release build: `flutter test --release`

### "LlamaDart failed to load"
- Verify GGUF format (not GPTQ/AWQ)
- Check file isn't corrupted: `md5sum model.gguf`

### "FlutterGemma not initialized"
- Run `FlutterGemma.initialize()` first
- Check Android/iOS native dependencies

## CI/CD Integration

These tests are **excluded from CI** via `@Tags(['manual'])` annotations.

To run in CI (not recommended due to size):
1. Add model download step to CI pipeline
2. Cache model files between runs
3. Use self-hosted runners with sufficient RAM (>8GB)

## Contact

For issues with manual tests, see:
- LlamaDart: https://github.com/flutter/flutter_gemma
- FlutterGemma: https://github.com/flutter/flutter_gemma
- Sherpa ONNX: https://github.com/k2-fsa/sherpa-onnx
