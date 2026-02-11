# CLAUDE.md — AiNotes

## Project Overview

AiNotes is a **personal AI knowledge base** — voice is the primary input, but users can also paste text, scan photos, and import documents. An on-device LLM + RAG engine powers everything: rewriting messy transcripts into clean notes, auto-classifying and filing them, finding related content, and answering questions about your own knowledge. Fully on-device for privacy.

See `how_it_works.md` for the original product spec.
See `~/.claude/plans/sharded-jumping-flask.md` for the full implementation plan.

## Tech Stack

### On-device STT — `sherpa_onnx` (Moonshine model)
### On-device LLM — `llamadart` (Qwen 2.5 1.5B Q4_K_M default, pluggable GGUF models)
### On-device Embeddings — EmbeddingGemma via `flutter_gemma`
### Vector Search — ObjectBox (HNSW)
### Storage — Markdown files w/ YAML frontmatter + ObjectBox index
### State Management — Riverpod
### Navigation — go_router
### Data Models — freezed + json_serializable

## Architecture

Feature-first under `lib/`:
```
lib/
├── main.dart / app.dart
├── core/
│   ├── theme/          # AppColors, AppTypography, design tokens
│   ├── routing/        # GoRouter config
│   ├── error/          # Result<T> sealed class
│   ├── ai/             # LLMEngine, STTEngine, EmbeddingEngine abstractions
│   ├── rag/            # RAG engine, chunker, prompt templates
│   └── storage/        # NoteFileStore, ObjectBox index, vector store
├── features/
│   ├── home/           # Card grid with smart grouping + filter chips
│   ├── notes/          # Note model, detail screen, providers, repository
│   ├── recording/      # Recording UI, waveform, STT integration
│   ├── search/         # Hybrid keyword + semantic search
│   ├── ask/            # RAG-powered Q&A chat
│   ├── capture/        # Multi-input: text, photo/OCR, document
│   ├── processing/     # Pipeline: transcribe → rewrite → classify → embed → save
│   ├── models_manager/ # ML model download/management
│   ├── settings/
│   └── onboarding/
└── shared/widgets/     # GradientButton, AppShell
```

### Key Abstractions (Strategy Pattern)
- **`LLMEngine`** — pluggable LLM inference
- **`STTEngine`** — pluggable speech-to-text
- **`EmbeddingEngine`** — pluggable embeddings for RAG

### Data Model (freezed)
```dart
Note { id, originalText, rewrittenText, category, confidence, createdAt, tags, source, ... }
NoteCategory { shopping, todos, ideas, general }
NoteSource { voice, text, photo, document, webClip }
```

### Storage: Markdown + YAML frontmatter
Notes stored as `.md` files (LLM-friendly, human-readable, portable). ObjectBox indexes metadata + embeddings.

## Build & Run Commands

```bash
flutter run
flutter test
flutter analyze
dart run build_runner build --delete-conflicting-outputs  # freezed/objectbox codegen
```

## Implementation Phases

1. **Foundation + Notes UI** ✅ — Theme, router, Note model, file store, home grid, search, detail screen
2. **Recording + STT** — Audio recording, waveform, live transcription
3. **LLM Pipeline** — Rewrite, classify, processing animation, model manager
4. **Embeddings + RAG** — Semantic search, "ask your notes", smart merging
5. **Multi-Input + Polish** — Text/photo/document capture, onboarding, settings
6. **Intelligence Layer** — Auto-linking, clustering, weekly digest

## Key References
- `how_it_works.md` — original product spec
- `~/.claude/plans/sharded-jumping-flask.md` — full implementation plan
