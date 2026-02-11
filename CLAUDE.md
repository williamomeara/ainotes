# CLAUDE.md — AiNotes

## Project Overview

AiNotes is a voice note organizer: record → transcribe → rewrite → classify → file. All processing happens fully on-device (STT + LLM) for privacy. Built with Flutter/Dart, targeting iOS + Android.

See `how_it_works.md` for the full product spec.

## Tech Stack

### On-device STT (Speech-to-Text)
- **Primary: Moonshine** (Useful Sensors) — 26MB tiny model, 5x faster than Whisper Tiny, state-of-the-art edge STT. Requires platform channels (no Flutter package yet).
- **Fallback: Sherpa-ONNX** (`sherpa_onnx` package) — best ready-to-use Flutter package for cross-platform STT, native Flutter integration.

### On-device LLM (note rewriting + classification)
- **Runtime: llama.cpp** via `fllama` package (most mature Flutter integration, GGUF format)
- **Default model: Qwen 2.5 1.5B Q4_K_M** (~900MB, 25-40 tok/s, best instruction-following in class)
- **Alternative models users can choose:**
  - Gemma 3 1B Q4 (~700MB, lighter)
  - SmolLM2 1.7B Q4 (~1.2GB, quality-focused)
  - Qwen 2.5 0.5B Q4 (~300MB, low-end devices)
- Pluggable architecture: Strategy pattern so users can download/switch models

### Local Storage
- Hive or Isar for structured note data

## Architecture

### Folder Structure
Feature-first organization under `lib/`:
```
lib/
  features/
    recording/
    notes/
    settings/
  core/
    stt/          # STTEngine abstraction
    llm/          # LLMInferenceEngine abstraction
    models/
    storage/
  app.dart
  main.dart
```

### Key Abstractions
- **`STTEngine`** — pluggable speech-to-text (strategy pattern + factory). Implementations: MoonshineSTT, SherpaOnnxSTT.
- **`LLMInferenceEngine`** — pluggable LLM inference (strategy pattern + factory). Implementations: FLlamaEngine (with swappable GGUF models).

### Data Model
```dart
class Note {
  String id;
  String originalText;      // raw transcript
  String rewrittenText;     // cleaned by LLM
  NoteCategory category;    // classified by LLM
  String? customCategory;
  double confidence;
  DateTime timestamp;
  List<String>? tags;
}
```
Categories: built-in (`shopping`, `todos`, `general`) + user-created custom categories.

## Design System (from Figma reference)
- **Dark theme:** `stone-900` background, `orange-100/200/300` text hierarchy, `orange-700 → amber-700` gradient accents
- Rounded corners, backdrop blur, subtle borders
- Mobile-first: safe areas, slide-up bottom sheets, tap feedback animations
- Figma Make file key: `8jLUJXi7fvC5PQs5c4DCE8`

## Build & Run Commands

```bash
# Run
flutter run

# Build
flutter build apk
flutter build ios

# Test
flutter test
flutter test test/path_to_test.dart

# Analyze
flutter analyze
```

## Key References
- `how_it_works.md` — full product spec
- Figma Make file (`8jLUJXi7fvC5PQs5c4DCE8`) — UI design reference
