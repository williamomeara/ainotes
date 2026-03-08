// Minimal smoke test for LlamaDart on a real Android device.
//
// Self-contained — no imports from existing test helpers.
// Proves the LLM loads and generates coherent output via ChatSession.
//
// Model detection order:
//   1. `${appDocDir}/models/qwen2.5-1.5b-instruct-q4_k_m.gguf`
//   2. `/sdcard/Download/qwen2.5-1.5b-instruct-q4_k_m.gguf` (auto-copies)
//
// Run:
//   flutter test integration_test/llamadart_smoke_test.dart
//
// If model is missing, push it first:
//   adb push qwen2.5-1.5b-instruct-q4_k_m.gguf /sdcard/Download/
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ainotes/core/ai/llamadart_engine.dart';
import 'package:ainotes/core/rag/prompt_templates.dart';

const _modelFileName = 'qwen2.5-1.5b-instruct-q4_k_m.gguf';

/// Search paths for the model file, in order of preference.
const _searchPaths = [
  '/data/local/tmp/$_modelFileName', // adb push target (world-readable)
];

/// Find the model file. Checks app models dir, then known locations.
Future<String?> _findModel() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final primaryPath = '${appDocDir.path}/models/$_modelFileName';

  // 1. Check app models directory
  if (await File(primaryPath).exists()) {
    debugPrint('[MODEL] Found at $primaryPath');
    return primaryPath;
  }

  // 2. Check fallback locations
  for (final path in _searchPaths) {
    if (await File(path).exists()) {
      debugPrint('[MODEL] Found at $path');
      return path;
    }
  }

  return null;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  LlamaDartEngine? engine;
  late String modelPath;

  setUpAll(() async {
    debugPrint('=== LlamaDart Smoke Test ===');

    final path = await _findModel();
    if (path == null) {
      fail(
        'Model file not found.\n'
        'Download and push to device:\n'
        '  wget -c https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/'
        'resolve/main/$_modelFileName\n'
        '  adb push $_modelFileName /data/local/tmp/',
      );
    }
    modelPath = path;

    final size = await File(modelPath).length();
    debugPrint(
        '[MODEL] Size: ${(size / 1024 / 1024).toStringAsFixed(1)} MB');

    final e = LlamaDartEngine();
    debugPrint('[MODEL] Loading...');
    final sw = Stopwatch()..start();
    await e.loadModel(modelPath);
    sw.stop();
    debugPrint('[MODEL] Loaded in ${sw.elapsedMilliseconds}ms');
    engine = e;
  });

  tearDownAll(() async {
    await engine?.dispose();
    debugPrint('=== Smoke test complete ===');
  });

  // --- Test 1: Simple generation ---
  testWidgets('generates any output', (tester) async {
    debugPrint('\n[TEST 1] Simple generation...');

    final output = await engine!.generate('Say hello in one sentence.');

    debugPrint('[TEST 1] Output: $output');
    expect(output, isNotEmpty, reason: 'Engine produced no output');
    expect(output.length, greaterThan(3),
        reason: 'Output too short: "$output"');
  }, timeout: const Timeout(Duration(seconds: 120)));

  // --- Test 2: Rewrite task ---
  testWidgets('rewrites messy transcript', (tester) async {
    debugPrint('\n[TEST 2] Rewrite task...');

    final prompt = PromptTemplates.rewrite(
      'um so like I need to uh get milk and eggs and bread you know',
    );
    debugPrint('[TEST 2] Prompt length: ${prompt.length} chars');

    final output = await engine!.generate(prompt);

    debugPrint('[TEST 2] Output: $output');
    expect(output, isNotEmpty);
    // Should mention the items
    final lower = output.toLowerCase();
    expect(lower, contains('milk'), reason: 'Missing "milk" in rewrite');
    expect(lower, contains('eggs'), reason: 'Missing "eggs" in rewrite');
  }, timeout: const Timeout(Duration(seconds: 120)));

  // --- Test 3: Classification (JSON) ---
  testWidgets('classifies text as JSON', (tester) async {
    debugPrint('\n[TEST 3] Classification...');

    final prompt = PromptTemplates.classify(
      'Buy milk and eggs from the store',
    );
    debugPrint('[TEST 3] Prompt length: ${prompt.length} chars');

    final output = await engine!.generate(prompt);

    debugPrint('[TEST 3] Output: $output');
    expect(output, isNotEmpty);
    // Should contain JSON with category
    expect(output, contains('"category"'),
        reason: 'Missing "category" key in: $output');
    // Accept any valid category from our enum
    final validCategories = ['shopping', 'todos', 'ideas', 'general'];
    final hasValidCategory =
        validCategories.any((c) => output.toLowerCase().contains(c));
    expect(hasValidCategory, isTrue,
        reason: 'No valid category found in: $output');
  }, timeout: const Timeout(Duration(seconds: 120)));

  // --- Test 4: Tag extraction ---
  testWidgets('extracts tags', (tester) async {
    debugPrint('\n[TEST 4] Tag extraction...');

    final prompt = PromptTemplates.extractTags(
      'Need to buy groceries for weekly meal prep on Sunday',
    );
    debugPrint('[TEST 4] Prompt length: ${prompt.length} chars');

    final output = await engine!.generate(prompt);

    debugPrint('[TEST 4] Output: $output');
    expect(output, isNotEmpty);
    // Should contain at least one relevant keyword
    final lower = output.toLowerCase();
    expect(
      lower.contains('groceries') ||
          lower.contains('meal') ||
          lower.contains('weekly') ||
          lower.contains('sunday'),
      isTrue,
      reason: 'No relevant tags found in: $output',
    );
  }, timeout: const Timeout(Duration(seconds: 120)));

  // --- Test 5: Streaming ---
  testWidgets('streaming yields tokens', (tester) async {
    debugPrint('\n[TEST 5] Streaming...');

    final tokens = <String>[];
    await for (final token in engine!.generateStream(
      'List five benefits of exercise. Be detailed.',
    )) {
      tokens.add(token);
      if (tokens.length >= 50) break; // cap for test speed
    }

    debugPrint('[TEST 5] Received ${tokens.length} tokens');
    debugPrint('[TEST 5] First 200 chars: ${tokens.join().substring(0, tokens.join().length.clamp(0, 200))}');
    expect(tokens.length, greaterThan(1),
        reason: 'Expected >1 tokens, got ${tokens.length}');
  }, timeout: const Timeout(Duration(seconds: 120)));
}
