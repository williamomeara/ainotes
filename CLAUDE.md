# CLAUDE.md — AiNotes

## Project Overview

**AiNotes** is a personal AI knowledge base app with **voice as the primary input**. Users can also type, scan photos, and import documents. An on-device LLM + RAG engine powers everything: rewriting messy transcripts into clean notes, auto-classifying and filing them, finding related content, and answering questions about your own knowledge. **Fully on-device for privacy** — no data ever leaves the device.

**Phase 1 Status**: ✅ **COMPLETE** — Full foundation with unified smart input system

**Target**: Become the Notion/Mem.ai of voice-first knowledge apps. "My notes are perfectly organized without me doing anything."

---

## Product Vision

### What Users See
- "I just talk, and my thoughts are automatically organized"
- "I asked my notes something and got a detailed answer with sources"
- "My shopping list updated itself when I said 'also get bananas'"
- Everything is offline, no cloud, no account, complete privacy

### What Powers It
- **On-device STT** (sherpa_onnx): Moonshine model → ~50ms latency
- **On-device LLM** (llamadart): Qwen 2.5 1.5B → rewriting + classification + Q&A
- **On-device Embeddings** (flutter_gemma): EmbeddingGemma 300M → semantic search
- **Vector Store** (ObjectBox): HNSW algorithm → fast similarity search
- **RAG Engine**: Query → retrieve similar notes → LLM generates grounded answers
- **Storage**: Markdown files with YAML frontmatter → human-readable, portable, LLM-friendly

---

## Phase 1: Foundation + Unified Input ✅ COMPLETE

### What Was Built

**UI Foundation**
- ✅ Theme system with dark mode (orange accent, category colors)
- ✅ 4-tab navigation: Home (grid) | Folders (list) | Ask (chat) | Settings
- ✅ Home screen: masonry grid with smart grouping (Today, This Week, Earlier)
- ✅ Folders screen: hierarchical list view grouped by category with timestamps
- ✅ Ask screen: chat interface with enhanced message bubbles
- ✅ Note detail screen: view/edit notes

**Unified Input System** (NEW architectural layer)
- ✅ **UniversalInputBar**: Single input on Home, Folders, Ask tabs (not Settings)
  - Placeholder: "What's on your mind?" (intent-agnostic)
  - Red gradient mic button (48x48px) — separate from main input
  - Camera icon for photo capture
- ✅ **IntentClassifier** (pluggable abstraction)
  - MockIntentClassifier: Regex-based implementation for Phase 1
  - Questions: what/when/where/who/how/why/find/show me → Ask tab
  - Todos: remind me/need to/don't forget → Todos category
  - Shopping: buy/get/purchase → Shopping category
  - Ideas: idea/concept/brainstorm → Ideas category
  - Default: general notes
- ✅ **UnifiedInputProvider** (StateNotifier)
  - Routes all input (text/voice/photo) through intent detection
  - Smart routing: questions navigate to Ask tab, notes stay in place
  - Integrates with ChatProvider and NotesProvider

**Data & Storage**
- ✅ Note model with freezed: id, originalText, rewrittenText, category, confidence, createdAt, tags, source
- ✅ NoteFileStore: Read/write markdown with YAML frontmatter
- ✅ ObjectBox integration: Note metadata index + FTS
- ✅ NoteRepository: Orchestrates file store + index
- ✅ NoteCategory enum: shopping, todos, ideas, general
- ✅ NoteSource enum: voice, text, photo, document, webClip

**Input Integration**
- ✅ Text capture: Routes through UnifiedInputProvider for intent detection
- ✅ Voice recording: Transcripts route through UnifiedInputProvider
- ✅ Chat interface: Integrated with Ask tab

**Polish & Fixes**
- ✅ Enhanced chat bubbles: Larger (340px), better spacing (16px), improved typography
- ✅ Android 16 Edge-to-Edge fix: SafeArea + BottomNavigationBar (fixes Pixel 8 UI overlap)
- ✅ Filter chips on Home: All | Shopping | Todos | Ideas | General
- ✅ Note card styling: Color-coded by category, source badges, confidence indicators

---

## Tech Stack (Phase 1 Implementation)

### Phase 1: Foundation (✅ COMPLETE)
```yaml
# State Management
flutter_riverpod: ^3.0.0         # Reactive provider pattern, built-in DI
riverpod_annotation: ^3.0.0      # Code generation support

# Navigation
go_router: ^latest               # Declarative routing, deep linking

# Data Models
freezed: ^latest                 # Immutable models, pattern matching
json_serializable: ^latest       # JSON (de)serialization

# Storage
objectbox: ^latest               # Vector search + metadata index (HNSW)
path_provider: ^latest           # App-local file storage
yaml: ^latest                    # Parse YAML frontmatter

# UI
flutter_staggered_grid_view: ^latest # Masonry grid for home screen
flutter_animate: ^latest         # Smooth animations

# Utilities
uuid: ^latest                    # Unique IDs
shared_preferences: ^latest      # Simple preferences
```

### Phase 2: STT (Recording + Transcription)
```yaml
sherpa_onnx: ^1.12.24            # On-device STT (Moonshine model)
record: ^6.2.0                   # Audio recording with streaming
audio_waveforms: ^latest         # Real-time waveform visualization
pulsator: ^latest                # Pulse animation for mic button
permission_handler: ^latest      # Microphone permissions
```

### Phase 3: LLM Pipeline
```yaml
llamadart: ^0.4.0                # On-device LLM inference (GGUF models)
                                 # Default: Qwen 2.5 1.5B Q4_K_M
```

### Phase 4: RAG + Semantic Search
```yaml
flutter_gemma: ^latest           # On-device embeddings (EmbeddingGemma)
                                 # 768D embeddings, <200MB RAM
```

### Phase 5: Multi-Input Capture
```yaml
google_mlkit_text_recognition: ^latest # OCR for photos/receipts
pdfrx: ^latest                   # PDF text extraction
image_picker: ^latest            # Camera/gallery access
```

---

## Architecture

### Folder Structure (Feature-First)
```
lib/
├── main.dart                     # App entry point
├── app.dart                      # MaterialApp.router, theme, ProviderScope
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart        # ThemeData configuration
│   │   ├── app_colors.dart       # ColorScheme extension (dark theme, orange accent)
│   │   ├── app_typography.dart   # Text styles (heading1-3, body, caption, etc)
│   │   └── design_tokens.dart    # Spacing, radius, elevation constants
│   │
│   ├── routing/
│   │   └── app_router.dart       # GoRouter configuration (4 tabs + routes)
│   │
│   ├── error/
│   │   └── result.dart           # Result<T> sealed class (Failure/Success)
│   │
│   ├── ai/ (Phase 2+ features marked)
│   │   ├── intent_classifier.dart        # ✅ Phase 1: Abstract interface
│   │   ├── mock_intent_classifier.dart   # ✅ Phase 1: Regex-based implementation
│   │   ├── llm_engine.dart               # Phase 3: Abstract LLM interface
│   │   ├── llamadart_engine.dart         # Phase 3: LLM implementation
│   │   ├── stt_engine.dart               # Phase 2: Abstract STT interface
│   │   ├── sherpa_stt_engine.dart        # Phase 2: STT implementation
│   │   ├── embedding_engine.dart         # Phase 4: Abstract embedding interface
│   │   └── gemma_embedding_engine.dart   # Phase 4: Embedding implementation
│   │
│   ├── rag/ (Phase 4+ features)
│   │   ├── rag_engine.dart       # Query → retrieve → augment → generate
│   │   ├── chunker.dart          # Split into 400-512 token chunks
│   │   ├── context_builder.dart  # Build LLM context from retrieved chunks
│   │   └── prompt_templates.dart # Rewrite, classify, Q&A, merge prompts
│   │
│   ├── storage/
│   │   ├── note_file_store.dart  # ✅ Phase 1: Read/write markdown + YAML
│   │   ├── vector_store.dart     # Phase 4: ObjectBox vector embeddings
│   │   └── note_index.dart       # ✅ Phase 1: ObjectBox metadata + FTS
│   │
│   └── constants.dart            # App-wide constants
│
├── features/
│   ├── unified_input/            # ✅ Phase 1: NEW architectural layer
│   │   ├── domain/
│   │   │   └── input_intent.dart # sealed class: NoteIntent | QuestionIntent
│   │   └── providers/
│   │       └── unified_input_provider.dart # StateNotifier: classify + route
│   │
│   ├── folders/                  # ✅ Phase 1: NEW browse mode
│   │   └── presentation/
│   │       └── folders_screen.dart # Hierarchical list grouped by category
│   │
│   ├── notes/
│   │   ├── domain/
│   │   │   ├── note.dart              # ✅ Phase 1: Note model (freezed)
│   │   │   ├── note_category.dart     # ✅ Phase 1: Category enum + colors
│   │   │   └── note_source.dart       # ✅ Phase 1: Source enum (voice/text/photo/doc)
│   │   ├── presentation/
│   │   │   ├── note_detail_screen.dart # ✅ Phase 1: View/edit
│   │   │   └── note_card.dart         # ✅ Phase 1: Note card widget
│   │   └── providers/
│   │       ├── notes_provider.dart     # ✅ Phase 1: Main notes provider
│   │       └── notes_repository.dart   # ✅ Phase 1: File store + index
│   │
│   ├── home/
│   │   └── presentation/
│   │       ├── home_screen.dart    # ✅ Phase 1: Masonry grid view
│   │       ├── note_card.dart      # ✅ Phase 1: Card with category color
│   │       └── filter_chips.dart   # ✅ Phase 1: Category filter row
│   │
│   ├── ask/
│   │   ├── domain/
│   │   │   └── chat_message.dart   # ✅ Phase 1: UserMessage | AiMessage
│   │   ├── presentation/
│   │   │   ├── ask_screen.dart     # ✅ Phase 1: Chat interface
│   │   │   └── message_bubble.dart # ✅ Phase 1: Enhanced message bubbles
│   │   └── providers/
│   │       └── chat_provider.dart  # ✅ Phase 1: Chat message state
│   │
│   ├── recording/                 # Phase 2: STT integration
│   │   ├── domain/
│   │   │   └── recording_state.dart
│   │   ├── presentation/
│   │   │   ├── recording_screen.dart
│   │   │   ├── waveform_widget.dart
│   │   │   └── record_button.dart
│   │   └── providers/
│   │       └── recording_provider.dart
│   │
│   ├── capture/                   # Phase 5: Multi-input
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── text_capture_screen.dart
│   │   │   └── photo_capture_screen.dart
│   │   └── providers/
│   │
│   ├── processing/                # Phase 3: LLM pipeline
│   │   ├── domain/
│   │   │   ├── processing_pipeline.dart
│   │   │   └── classification.dart
│   │   └── providers/
│   │       └── pipeline_provider.dart
│   │
│   ├── search/                    # Phase 4: Hybrid search
│   │   ├── presentation/
│   │   │   └── search_screen.dart
│   │   └── providers/
│   │       └── search_provider.dart
│   │
│   ├── models_manager/            # Phase 3+: Download/manage ML models
│   │   ├── domain/
│   │   │   ├── ml_model.dart
│   │   │   └── download_state.dart
│   │   ├── presentation/
│   │   │   └── model_manager_screen.dart
│   │   └── providers/
│   │       └── model_manager_provider.dart
│   │
│   ├── settings/                  # Phase 5: App settings
│   │   └── presentation/
│   │       └── settings_screen.dart
│   │
│   └── onboarding/                # Phase 5: First-run experience
│       └── presentation/
│           ├── onboarding_screen.dart
│           ├── privacy_page.dart
│           ├── permission_page.dart
│           └── model_download_page.dart
│
└── shared/
    └── widgets/
        ├── app_shell.dart              # ✅ Phase 1: Bottom nav + tab scaffold
        ├── universal_input_bar.dart    # ✅ Phase 1: Unified input on 3 tabs
        ├── gradient_button.dart        # ✅ Phase 1: Orange gradient button
        └── app_bottom_sheet.dart       # Phase 2+: Reusable bottom sheet
```

### Key Architectural Decisions (Phase 1)

**1. Navigation: 4 Tabs (not 5)**
- Home (grid) | Folders (list) | Ask (chat) | Settings
- Removed Search tab → functionality in Folders + semantic search (Phase 4)
- Removed Organize tab → deferred to Phase 3+ with LLM confidence
- Rationale: Cleaner, less overwhelming, Settings more useful

**2. Unified Input Bar (not tab-specific inputs)**
- Single UniversalInputBar on Home, Folders, Ask (not Settings)
- Reduces cognitive load, enables smart routing
- Placeholder "What's on your mind?" is intent-agnostic

**3. Microphone as Separate Red Button (not center FAB)**
- 48x48px gradient button always visible on all input tabs
- More accessible one-handed, consistent with modern apps (ChatGPT, Perplexity)
- Cleaner nav without FAB cutout

**4. Intent Classification Layer (new, Phase 1)**
- MockIntentClassifier: Regex patterns for immediate smart routing
- Easy to swap with LLM-based classifier in Phase 3
- Questions → Ask tab, Notes → stay in place (magic!)
- Bridges UI and AI layers before LLM is ready

**5. Simplified Recording Flow**
- Full-screen RecordingScreen (proven UX from Otter.ai)
- Processing animations deferred to Phase 3 (when LLM ready)
- Transcript still routes through UnifiedInputProvider

**6. Folders View (new, Phase 1)**
- Alternative browse mode to grid (some users prefer lists)
- Shows category icons, note counts, timestamps
- Less CPU/RAM than masonry for large collections
- Enables future: collapsible categories, tags

### Data Model

```dart
@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String originalText,           // Raw input (transcript/OCR/text)
    required String rewrittenText,          // Cleaned by LLM (Phase 3+)
    required NoteCategory category,
    String? customCategory,
    required double confidence,             // 0.0-1.0, filled by LLM (Phase 3+)
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> tags,        // Extracted by LLM (Phase 3+)
    @Default(NoteSource.text) NoteSource source,
    Duration? audioDuration,                // For voice notes
    String? filePath,                       // Path to .md file
  }) = _Note;
}

enum NoteCategory { shopping, todos, ideas, general }
enum NoteSource { voice, text, photo, document, webClip }
```

### Storage: Markdown + YAML Frontmatter

Notes are stored as human-readable `.md` files with YAML frontmatter:

```markdown
---
id: abc123def456
category: shopping
confidence: 0.92
source: voice
created: 2026-02-11T10:30:00Z
updated: 2026-02-11T10:30:00Z
tags: [groceries, weekly]
audio_duration: 45s
---

# Groceries

- Milk
- Bread
- Eggs
- Coffee
- Oat milk

---
<!-- original -->
okay so um I need to get milk and bread and eggs oh and also coffee and oat milk
```

**Why markdown?**
- LLM-friendly: Most token-efficient format, 60.7% accuracy vs CSV
- Human-readable: Edit in any text editor, version control friendly
- Portable: Notes survive the app, sync via cloud (iCloud, Google Drive, etc)
- Future-proof: Open format, not locked to any platform

### Unified Input Flow (Phase 1)

```
User Input (Text, Voice, or Photo)
    ↓
UniversalInputBar (Home, Folders, Ask tabs)
    ├─ Text: Tap input field
    ├─ Voice: Tap red mic button → RecordingScreen → transcript
    └─ Photo: Tap camera icon → future OCR (Phase 5)
    ↓
Text Normalized (from STT/OCR/typing)
    ↓
UnifiedInputProvider
    ├─ IntentClassifier.classify(text)
    │
    ├─ Question detected? (regex: what/when/where/who/how/why)
    │  └─ ChatProvider.sendMessage(text)
    │  └─ Navigate to Ask tab
    │
    └─ Note detected? (statement/reminder/observation)
       ├─ SuggestCategory (regex: shopping/todos/ideas/general)
       └─ NotesProvider.createNote()
       └─ Stay on current tab
    ↓
Note saved as .md file + ObjectBox index
```

---

## Current Feature Status

### ✅ Phase 1: Complete
- [x] Full theme system with dark mode + orange accent
- [x] 4-tab navigation with bottom nav bar
- [x] Home screen: masonry grid with smart grouping
- [x] Folders screen: hierarchical list view
- [x] Ask screen: chat interface
- [x] UniversalInputBar on 3 tabs
- [x] Intent classification (regex-based mock)
- [x] Text/voice input routing through UnifiedInputProvider
- [x] Note storage (markdown + YAML)
- [x] ObjectBox indexing
- [x] Enhanced chat bubbles
- [x] Android 16 Edge-to-Edge fix

### 🔮 Phase 2: Recording + STT (Next)
- [ ] sherpa_onnx integration
- [ ] Live transcription during recording
- [ ] Waveform visualization
- [ ] Timestamp markers for transcribed text

### 🔮 Phase 3: LLM Pipeline + Auto-Organization
- [ ] llamadart integration
- [ ] LLM rewriting (clean messy transcripts)
- [ ] LLM classification (category + confidence)
- [ ] Processing animation (✓ Transcribed → ◎ Rewriting → ○ Classifying)
- [ ] Replace MockIntentClassifier with LLM-based

### 🔮 Phase 4: Embeddings + RAG Core
- [ ] flutter_gemma integration (EmbeddingGemma)
- [ ] Vector embeddings for all notes
- [ ] Semantic search (find related notes)
- [ ] "Ask your notes" RAG-powered Q&A
- [ ] Smart note merging ("Also get bananas" → updates grocery list)

### 🔮 Phase 5: Multi-Input + Polish
- [ ] Text capture (type/paste)
- [ ] Photo capture with OCR (google_mlkit_text_recognition)
- [ ] PDF import (pdfrx)
- [ ] Onboarding flow (5 screens)
- [ ] Settings screen (model selection, confidence thresholds)

### 🔮 Phase 6: Intelligence Layer
- [ ] Auto-linking (new notes show related ones)
- [ ] Smart tagging (LLM extracts tags)
- [ ] Note clustering (group similar ideas)
- [ ] Weekly digest (LLM summarizes ideas, todos, patterns)
- [ ] Custom categories

---

## Key Patterns & Principles

### Riverpod Providers
- **StateNotifier** for mutable state (UnifiedInputProvider, ChatProvider)
- **FutureProvider** for async data (notesProvider, searchProvider)
- **Provider** for computed/derived state (filteredNotesProvider)
- **NotifierProvider** for complex state management
- Riverpod overrides for testing (mock STTEngine, LLMEngine, etc)

### Error Handling
- **Result<T> sealed class**: Failure (message) | Success (data)
- No exceptions for expected errors
- Dart 3.0+ exhaustive switch for pattern matching

### Intent Detection Architecture
```dart
// Abstract interface (pluggable)
abstract class IntentClassifier {
  Future<InputIntent> classify(String text);
}

// Phase 1: Regex-based mock
class MockIntentClassifier implements IntentClassifier {
  // Pattern matching for questions, todos, shopping, ideas
}

// Phase 3: LLM-based (to be implemented)
class LLMIntentClassifier implements IntentClassifier {
  // Few-shot prompt to llamadart for high-accuracy classification
}
```

### Storage Abstraction
```dart
// Markdown file store (notes are portable .md files)
class NoteFileStore {
  Future<void> saveNote(Note note);  // Write .md file with YAML frontmatter
  Future<Note?> loadNote(String id); // Parse .md + YAML
  Future<List<Note>> loadAllNotes(); // Read all notes directory
}

// ObjectBox indexing (fast queries)
class NoteIndex {
  // Metadata index (id, category, createdAt, tags)
  // Full-text search (rewrittenText search)
  // Phase 4: Vector embeddings (semantic search)
}
```

---

## How to Run

### Prerequisites
- Flutter 3.0+ (stable channel)
- Dart 3.0+
- Android Studio (for emulator) or physical device

### Build & Run
```bash
# Get dependencies
flutter pub get

# Code generation (freezed + objectbox)
dart run build_runner build --delete-conflicting-outputs

# Run on device
flutter run

# Run in release mode (optimized)
flutter run --release

# Build APK
flutter build apk --split-per-abi
```

### Run Tests
```bash
flutter test

# With coverage
flutter test --coverage
lcov --list coverage/lcov.info
```

### Analyze Code
```bash
# Lint check
flutter analyze

# Format code
dart format .

# Run formatter + analyzer + tests
flutter run pre-commit hook
```

---

## Key Files to Know

### Theme & Design
- `lib/core/theme/app_colors.dart` — Color palette (dark mode, orange, categories)
- `lib/core/theme/app_typography.dart` — Text styles
- `lib/core/theme/design_tokens.dart` — Spacing, radius, elevation

### Navigation
- `lib/core/routing/app_router.dart` — Route definitions (Home, Folders, Ask, Settings)
- `lib/shared/widgets/app_shell.dart` — Bottom nav bar + tab scaffold

### Core Features
- `lib/features/unified_input/providers/unified_input_provider.dart` — Smart input routing
- `lib/core/ai/mock_intent_classifier.dart` — Question vs note detection
- `lib/shared/widgets/universal_input_bar.dart` — Input bar widget

### Data & Storage
- `lib/features/notes/domain/note.dart` — Note data model
- `lib/core/storage/note_file_store.dart` — Markdown file read/write
- `lib/core/storage/note_index.dart` — ObjectBox indexing

### UI Screens
- `lib/features/home/presentation/home_screen.dart` — Masonry grid
- `lib/features/folders/presentation/folders_screen.dart` — List view
- `lib/features/ask/presentation/ask_screen.dart` — Chat interface

---

## Immediate Next Steps (Phase 2)

1. **Add sherpa_onnx package** for on-device STT
2. **Create STTEngine abstraction** (like LLMEngine, EmbeddingEngine)
3. **Implement SherpaSTTEngine** with Moonshine model
4. **Wire recording → STT → live transcription** in RecordingScreen
5. **Test end-to-end**: Record audio → see live transcript on device
6. **Integrate with UnifiedInputProvider**: Transcript → intent detection → routing

---

## References

- **Product Spec**: `docs/how_it_works.md`
- **Implementation Plan**: `docs/implementation_plan.md` (detailed architecture + phases)
- **Tech Stack Details**: See `Part 1: Tech Stack` in implementation_plan.md
- **UI/UX Architecture**: See `Part 3: UI/UX Architecture` in implementation_plan.md

---

## Design Philosophy

1. **Voice-first, but text-friendly** — Voice is primary, but typing should feel native
2. **Organize = Understand** — The app understands your thoughts by organizing them
3. **Zero friction** — Smart routing (no "is this a note or a question?" prompt)
4. **All on-device** — Privacy by default, no cloud accounts, no tracking
5. **Beautiful dark mode** — Reduces eye strain, orange accent for warmth
6. **Pluggable AI** — Easy to swap STT/LLM/embedding implementations for better models

---

Last Updated: February 2026
Phase 1 Completion: ✅ Complete
Next Phase: Phase 2 - Recording + STT Integration
