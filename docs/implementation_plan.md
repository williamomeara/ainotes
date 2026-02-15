# AiNotes — Comprehensive Implementation Plan

## Context & Vision

AiNotes is a **personal AI knowledge base** disguised as a beautifully organized notes app. Voice is the primary input, but users can also paste text, scan photos/receipts, and import documents. An on-device LLM + RAG engine powers everything: rewriting messy transcripts into clean notes, auto-classifying and filing them, finding related content, and answering questions about your own knowledge.

**What users see**: "Wow, my notes are perfectly organized — clean, categorized, tagged, and I can find anything instantly."

**What powers it**: Fully on-device RAG — every piece of content is embedded, indexed, and available to the LLM for intelligent organization and retrieval. No data ever leaves the device.

The key insight: **organization IS intelligence**. The app doesn't just store notes — it *understands* them. "Add this to my shopping list" works because the LLM semantically searched your notes and found the right one. New ideas auto-link to related notes. The more you use it, the smarter it gets.

See `how_it_works.md` for the original product spec.

---

## Phase 1 Architecture: Key Decisions (Updated from Original Plan)

The implementation diverged from the original plan in several key ways, all justified by real-world design and usability:

### 1. Navigation: 4 Tabs Instead of 5
**Original**: Home | Search | Record FAB | Ask | Organize
**Actual**: Home | Folders | Ask | Settings

**Rationale:**
- Search functionality now lives in Folders (list view is more browsable than search)
- Semantic search will be added later in Phase 4 (for now regex classification is sufficient)
- Organize (category management) deferred to Phase 3+ when LLM confidence scoring is ready
- Settings tab more useful than second-tier Organize UI
- **Net effect**: Cleaner, more focused navigation; less overwhelming for users

### 2. Microphone as Separate Button (Not Center FAB)
**Original**: Center FAB with Record button
**Actual**: Separate 48x48px red gradient button in input bar

**Rationale:**
- Separate button is always visible + reachable from any tab (Home, Folders, Ask)
- Red gradient makes it prominent and discoverable without center FAB visual weight
- More consistent with modern voice UI patterns (ChatGPT, Perplexity mobile)
- Easier one-handed operation
- Cleaner bottom nav without FAB cutout

### 3. Unified Input Bar Instead of Tab-Specific Inputs
**Original**: Each tab (Home, Search, Ask) had separate input methods
**Actual**: Single UniversalInputBar on Home, Folders, Ask

**Rationale:**
- Reduces UI cognitive load (user learns one pattern, not three)
- Enables smart routing (questions vs notes → different destinations)
- Placeholder "What's on your mind?" is intent-agnostic (no tab switcher needed)
- UnifiedInputProvider handles all intent classification centrally
- Enables future: custom intent types (reminders, web clips) route automatically

### 4. Intent Classification Layer (New, Not in Original Plan)
**NEW**: IntentClassifier + MockIntentClassifier + UnifiedInputProvider

**Rationale:**
- Bridges UI and AI layers (enables smart routing before LLM integration)
- Regex-based mock allows immediate testing of routing logic
- Easy to swap with LLM-based classifier later (pluggable architecture)
- User gets magic routing immediately (question → Ask tab, note stays in place)
- Defers LLM complexity while keeping UX smart

### 5. Simplified Recording Flow
**Original**: Complex bottom sheet with waveform + live transcription + processing animation
**Actual**: Full-screen RecordingScreen → transcript → UnifiedInputProvider routing

**Rationale:**
- Full-screen recording is proven UX (Otter.ai, Mem.ai)
- Simplifies Phase 1 implementation
- Processing animations deferred to Phase 3 (when LLM pipeline is ready)
- Transcript still gets smart intent routing (questions/notes/todos)
- Can enhance UI later without changing architecture

### 6. Folders View (New Feature, Not in Original Plan)
**NEW**: FoldersScreen with hierarchical list grouped by category

**Rationale:**
- Provides alternative browse mode to grid (some users prefer lists)
- Shows category icons + note counts (great for Todos/Shopping overview)
- Timestamps (2m ago, 1h ago) let users quickly find recent notes
- Less CPU/RAM than masonry grid on large note collections
- Enables future: collapsible categories, tag-based organization

### 7. Chat Bubbles Enhancement
**Updated**: Larger (340px vs 280px), better spacing (16px padding), improved typography

**Rationale:**
- Makes conversations more readable
- Reduces visual clutter with better spacing
- Sets visual bar for ASK responses (feels premium)
- Easy to further enhance with animations later

---

### UI Design Approach
Since the original Figma was for the simpler voice-notes scope, we'll build the UI directly in code using researched patterns + visual inspiration from polished production apps. The approach: code-first iteration with strong design references.

### Design Inspirations (browse these for visual direction)
**Primary references (dark theme, notes/organizer, closest to our vision):**
- [Nulis - Notes Mobile App Dark](https://dribbble.com/shots/19692409-Nulis-Notes-Mobile-App-Dark) — beautiful minimal dark note cards
- [Notes App Dark Mode](https://dribbble.com/shots/14995291--Notes-App-Dark-Mode) — excellent contrast and spacing
- [Dark Theme Mobile Notes](https://dribbble.com/shots/15310333-Mobile-Notes-App-UI-Design-Exploration-Dark-Theme-2) — organized card layouts
- [Bento Grids Gallery](https://bentogrids.com/) — filter to dark mode for grid layout patterns

**Production apps to study (install and use for feel):**
- **Bear Notes** — minimal, beautiful typography, OLED dark mode (Dieci theme)
- **Craft** — Apple Design Award winner, clean workspace, embedded media
- **Things 3** — two Apple Design Awards, tasteful dark mode, animations
- **Capacities.io** — object-based organization, bottom nav, quick capture
- **Otter.ai** — voice recording UX, real-time transcription, waveforms

**Voice recording UI patterns:**
- [Dribbble: Voice Notes App UI](https://dribbble.com/tags/voice_notes_app_ui)
- [Mobbin: Audio/Video Recorder Screens](https://mobbin.com/explore/mobile/screens/audio-video-recorder)

**Dark theme + orange accent guidelines:**
- Use desaturated orange (tonal value ~200) for actions/highlights
- Dark gray (#1C1917) not pure black for better readability
- Reserve brighter orange for CTAs and the record button
- Category colors should be muted on dark backgrounds

---

## Part 1: Tech Stack

### On-Device LLM (rewriting, classification, Q&A)
- **Runtime**: `llamadart` (v0.4.0) — Metal/Vulkan GPU, all platforms, resumable model downloads, 80%+ test coverage
- **Default model**: Qwen 2.5 1.5B Q4_K_M (~900MB, 25-40 tok/s)
- **Alternatives**: Gemma 3 1B (~700MB), SmolLM2 1.7B (~1.2GB), Qwen 2.5 0.5B (~300MB)
- **Why not fllama**: Stagnant (v0.0.1, 15 months old, broken with newer models)

### On-Device STT (Speech-to-Text)
- **Package**: `sherpa_onnx` (v1.12.24, 7,490 downloads/week) — already supports Moonshine models natively
- Also provides: voice activity detection, speaker ID, audio tagging

### On-Device Embeddings (RAG)
- **Primary**: EmbeddingGemma 300M via `flutter_gemma` — 768D embeddings, <200MB RAM, 100+ languages, built for on-device RAG
- **Fallback**: all-MiniLM-L6-v2 via ONNX Runtime (~33MB, 384D, blazing fast)

### Vector Search
- **Primary**: ObjectBox (v5.2.0, 1,538 likes) — HNSW algorithm, native Dart/Flutter, purpose-built for mobile vector search
- **Why not sqlite-vec**: sqlite-vec is brute-force KNN; ObjectBox uses HNSW which is faster for large collections

### Audio Recording
- `record` (v6.2.0) — streaming + file recording, pause/resume, amplitude monitoring

### State Management
- Riverpod 3.0 — AsyncNotifier for streams, Mutations API for lifecycles, built-in DI

### Navigation
- go_router — official Flutter team recommendation, declarative, deep linking

### Data Storage: Hybrid Markdown + Index
- **Primary**: Markdown files with YAML frontmatter (Obsidian-style) — LLM-friendly, human-readable, future-proof
- **Search index**: ObjectBox — stores note metadata + vector embeddings for semantic search + FTS for keyword search
- **Why markdown**: LLM reads .md files directly (most token-efficient format, 60.7% accuracy vs CSV). Notes survive the app, sync via cloud, editable in any text editor.

### Data Classes
- freezed + json_serializable — immutable models, copyWith, pattern matching

### Error Handling
- Result<T> sealed class — Dart 3.0+ exhaustive switch, no exceptions for expected errors

### UI/Animations
- `flutter_animate` — general UI animations
- `audio_waveforms` — real-time waveform during recording
- `pulsator` — pulse animation for record button

### Additional Input
- `google_mlkit_text_recognition` — OCR for photos/receipts
- `pdfrx` — PDF text extraction

---

## Part 2: Architecture

### Folder Structure
```
lib/
├── main.dart
├── app.dart                           # MaterialApp.router, theme, ProviderScope
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData + ColorScheme
│   │   ├── app_colors.dart            # CustomColors ThemeExtension
│   │   ├── app_typography.dart        # Text styles
│   │   └── design_tokens.dart         # Spacing, radius, elevation tokens
│   ├── routing/
│   │   └── app_router.dart            # GoRouter config
│   ├── error/
│   │   └── result.dart                # Result<T> sealed class
│   ├── ai/
│   │   ├── intent_classifier.dart     # Abstract interface (NEW: Phase 1)
│   │   ├── mock_intent_classifier.dart # Regex-based implementation (NEW: Phase 1)
│   │   ├── llm_engine.dart            # Abstract LLM interface (Phase 3+)
│   │   ├── llamadart_engine.dart      # llamadart implementation (Phase 3+)
│   │   ├── stt_engine.dart            # Abstract STT interface (Phase 2+)
│   │   ├── sherpa_stt_engine.dart     # sherpa_onnx implementation (Phase 2+)
│   │   ├── embedding_engine.dart      # Abstract embedding interface (Phase 4+)
│   │   └── gemma_embedding_engine.dart # EmbeddingGemma implementation (Phase 4+)
│   ├── rag/
│   │   ├── rag_engine.dart            # Orchestrates: query → retrieve → augment → generate
│   │   ├── chunker.dart               # Split content into 400-512 token chunks
│   │   ├── context_builder.dart       # Build LLM context from retrieved chunks
│   │   └── prompt_templates.dart      # All LLM prompts (rewrite, classify, Q&A, merge)
│   ├── storage/
│   │   ├── note_file_store.dart       # Read/write markdown files with YAML frontmatter
│   │   ├── vector_store.dart          # ObjectBox: embeddings + HNSW search
│   │   └── note_index.dart            # ObjectBox: note metadata + FTS
│   └── constants.dart
├── features/
│   ├── unified_input/                 # NEW: Intent detection + smart routing
│   │   ├── domain/
│   │   │   └── input_intent.dart      # sealed class: NoteIntent | QuestionIntent
│   │   └── providers/
│   │       └── unified_input_provider.dart  # StateNotifier: classify + route
│   ├── recording/
│   │   ├── domain/
│   │   │   └── recording_state.dart   # freezed: Idle|Recording|Paused|Processing|Done|Error
│   │   ├── presentation/
│   │   │   ├── recording_screen.dart
│   │   │   ├── recording_sheet.dart   # Persistent bottom sheet
│   │   │   ├── waveform_widget.dart
│   │   │   └── record_button.dart     # Pulse animation
│   │   └── providers/
│   │       └── recording_provider.dart
│   ├── folders/                       # NEW: Hierarchical list view
│   │   └── presentation/
│   │       └── folders_screen.dart    # Notes grouped by category with timestamps
│   ├── notes/
│   │   ├── domain/
│   │   │   ├── note.dart              # freezed Note model
│   │   │   └── note_category.dart     # Enum + custom categories
│   │   ├── presentation/
│   │   │   ├── notes_screen.dart      # Main list with category tabs
│   │   │   ├── note_detail_screen.dart
│   │   │   ├── note_card.dart
│   │   │   └── category_chip.dart
│   │   └── providers/
│   │       ├── notes_provider.dart
│   │       └── note_repository.dart   # Orchestrates file store + index
│   ├── home/
│   │   └── presentation/
│   │       ├── home_screen.dart       # Card grid with smart grouping
│   │       ├── note_card.dart         # Color-coded card with badges
│   │       └── filter_chips.dart      # Category filter row
│   ├── search/
│   │   ├── presentation/
│   │   │   └── search_screen.dart     # Hybrid keyword + semantic search
│   │   └── providers/
│   │       └── search_provider.dart
│   ├── processing/
│   │   ├── domain/
│   │   │   ├── processing_pipeline.dart # transcribe → rewrite → classify → embed → save
│   │   │   └── classification.dart
│   │   └── providers/
│   │       └── pipeline_provider.dart
│   ├── ask/                           # "Ask your notes" — RAG-powered Q&A
│   │   ├── presentation/
│   │   │   └── ask_screen.dart        # Chat interface to query your knowledge
│   │   └── providers/
│   │       └── ask_provider.dart
│   ├── capture/                       # Multi-input capture (beyond voice)
│   │   ├── presentation/
│   │   │   ├── capture_menu.dart      # Choose: voice, text, photo, document
│   │   │   ├── text_capture.dart
│   │   │   └── photo_capture.dart     # Camera → OCR → note
│   │   └── providers/
│   │       └── capture_provider.dart
│   ├── models_manager/
│   │   ├── domain/
│   │   │   ├── ml_model.dart          # Model metadata (name, size, url, type: llm|stt|embedding)
│   │   │   └── download_state.dart    # freezed: NotStarted|Downloading(progress)|Ready|Error
│   │   ├── presentation/
│   │   │   ├── model_manager_screen.dart
│   │   │   └── download_progress_widget.dart
│   │   └── providers/
│   │       └── model_manager_provider.dart
│   ├── settings/
│   │   └── presentation/
│   │       └── settings_screen.dart
│   └── onboarding/
│       └── presentation/
│           ├── onboarding_screen.dart
│           ├── privacy_page.dart
│           ├── permission_page.dart
│           └── model_download_page.dart
└── shared/
    └── widgets/
        ├── app_shell.dart              # Bottom nav + app structure (updated)
        ├── universal_input_bar.dart    # NEW: Unified input on Home/Folders/Ask
        ├── gradient_button.dart
        └── app_bottom_sheet.dart
```

### Data Model (freezed)
```dart
@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String originalText,      // raw transcript / OCR / input
    required String rewrittenText,     // cleaned by LLM
    required NoteCategory category,
    String? customCategory,
    required double confidence,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> tags,
    @Default(NoteSource.voice) NoteSource source,
    Duration? audioDuration,
    String? filePath,                  // path to .md file
  }) = _Note;
}

enum NoteCategory { shopping, todos, ideas, general }
enum NoteSource { voice, text, photo, document, webClip }
```

### Markdown File Format
```markdown
---
id: a1b2c3d4
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

### Processing Pipeline
```
Input (voice/text/photo/doc)
  → Normalize to text (STT / OCR / direct)
  → LLM rewrite (clean, structure)
  → LLM classify (category + confidence + tags)
  → if confidence < threshold → disambiguation UI
  → Chunk text (400-512 tokens)
  → Generate embeddings (EmbeddingGemma)
  → Save: .md file + ObjectBox index + vector embeddings
```

### RAG Query Flow
```
User asks "What did I say about the wedding?"
  → Embed the query
  → Vector search: find top-K similar chunks (ObjectBox HNSW)
  → Load full .md files for those chunks
  → Build context: query + relevant note contents
  → LLM generates answer grounded in your notes
```

### Smart Organization (LLM-powered)
```
New note arrives: "Also get bananas"
  → Embed + search for similar recent notes
  → Finds "Groceries" shopping list from 2 hours ago
  → LLM: "Should this be appended to the existing grocery list?"
  → If yes: append to .md file, re-embed, re-index
  → User sees: their grocery list just got updated
```

### Key Abstractions (Strategy Pattern)
```dart
abstract class LLMEngine {
  Future<void> loadModel(String modelPath);
  Stream<String> generateStream(String prompt);
  Future<String> generate(String prompt);
  Future<void> dispose();
}

abstract class STTEngine {
  Future<void> initialize(String modelPath);
  Stream<String> transcribeStream(Stream<List<int>> audioStream);
  Future<String> transcribe(String audioFilePath);
  Future<void> dispose();
}

abstract class EmbeddingEngine {
  Future<void> loadModel(String modelPath);
  Future<List<double>> embed(String text);
  Future<List<List<double>>> embedBatch(List<String> texts);
  Future<void> dispose();
}
```

---

## Part 3: UI/UX Architecture

### Navigation Structure (Updated Phase 1)
```
┌─────────────────────────────────┐
│  Title + Filter Chips           │
├─────────────────────────────────┤
│                                 │
│         MAIN CONTENT            │  ← Swappable based on active tab
│    (cards, list, chat, etc)     │
│                                 │
│                                 │
├─────────────────────────────────┤  ← UniversalInputBar
│ What's on your mind?  🎤  📷    │  (shows on Home, Folders, Ask)
├─────────────────────────────────┤
│ [Home] [Folders] [Ask] [Settings]│  ← Bottom tabs (4 items)
└─────────────────────────────────┘
```

**Bottom tabs (4 items):**
1. **Home** — Card grid of notes, grouped by "Today", "This Week", category
2. **Folders** — Hierarchical list view grouped by category with timestamps
3. **Ask** — "Ask your notes" RAG-powered chat interface (same input bar as Home)
4. **Settings** — App settings, model management, preferences

**Key changes from original plan:**
- Removed Search tab (functionality integrated into Folders + semantic search later)
- Removed Organize tab (category management deferred to Phase 3+)
- Replaced Search tab with Folders (new list view for browsing)
- **Unified input bar** on Home, Folders, Ask (not Search)
- **Microphone as separate red button** (not center FAB) — 48x48px gradient button
- Input bar shows on 3 tabs, not on Settings
- All input routes through **UnifiedInputProvider** for smart intent detection

### Home Screen: Card-Based Bento Grid
- Notes displayed as **color-coded cards** — category determines accent color
- **Visual badges** on each card: voice icon, text icon, photo icon (source type)
- **Confidence dot** — subtle indicator of AI classification certainty
- **Smart grouping**: "Today", "This Week", "Earlier" sections
- **Filter chips** at top: All | Ideas | Shopping | Todos | Custom...
- **Long-press** → quick actions (re-categorize, delete, share)
- **Density toggle**: comfortable (large cards) / compact (list view)

### Unified Input Flow (Phase 1 Implementation)
```
User Input (any method)
├─ Text capture (tap input bar)
├─ Voice recording (tap mic button)
└─ Photo capture (tap camera icon)
   └─ All convert to text

Text → UnifiedInputProvider
├─ IntentClassifier.classify(text)
├─ Question detected (regex: what/when/where/who/how/why/find/show me)
│  └─ ChatProvider.sendMessage(text)
│  └─ Navigate to Ask tab
└─ Note detected (statement/observation/reminder)
   ├─ Suggest category (regex patterns: shopping/todos/ideas/general)
   └─ NotesProvider.createNote()
   └─ Stay on current tab

Intent Classifier (regex-based mock, replaced later with LLM)
├─ Questions: ^(what|when|where|who|how|why|find|show me)\b
├─ Todos: (remind me|need to|don't forget|todo|task)
├─ Shopping: (buy|get|purchase|pick up|grocery)
├─ Ideas: (idea|concept|maybe|could|brainstorm)
└─ Default: General note

Recording Flow (Phase 1 simplified)
├─ Tap red mic button
├─ Full-screen RecordingScreen opens
├─ Live transcription displayed
├─ Tap "Send" (not "Save & Process")
└─ Transcript routes through UnifiedInputProvider
   └─ Intent detection determines note vs question
   └─ Route accordingly (Ask tab or stay on Home)

Note: Complex processing pipeline animations (✓ Transcribed → ◎ Rewriting → ○ Filing) deferred to Phase 3 after LLM integration
```

### "Ask Your Notes" (RAG Chat)
- Dedicated tab with chat interface
- **Voice input** option (consistent with voice-first app)
- Each AI response shows **source panel**: "Based on 3 notes" → tap to expand → see which notes
- **Suggested questions**: "What did I say about...", "Summarize my ideas from this week"
- **Context-aware**: knows current time, recent notes, frequently accessed categories

### AI Transparency (Critical for trust)
- **Category badge with "why"**: Tap category label → "Filed as Shopping because it mentions items to buy"
- **Confidence dot**: Green (>85%), yellow (60-85%), orange (<60% → prompted to confirm)
- **One-tap override**: Wrong category? Tap → choose correct one → "Got it, I'll learn from this"
- **Related notes explanation**: "Related because both mention 'wedding planning'"
- **Processing steps visible**: User sees transcribe → rewrite → classify → file in real-time

### Onboarding Flow (5 screens, PageView)
1. **Welcome**: "Your private thinking partner" — value proposition
2. **Privacy**: "Everything stays on your device" — trust building, no cloud logos
3. **Microphone permission**: "I need to hear you" — friendly, explains why
4. **Model download**: Progress bar for STT + LLM + embedding models (~1.2GB total) — "Setting up your brain"
5. **Quick tutorial**: Animated demo of record → process → organized note

### Design System

#### Color Palette (ThemeExtension)
```dart
background:     Color(0xFF1C1917)  // stone-900
surface:        Color(0xFF292524)  // stone-800
surfaceVariant: Color(0xFF44403C)  // stone-700
textPrimary:    Color(0xFFFFF7ED)  // orange-100
textSecondary:  Color(0xFFFED7AA)  // orange-200
textTertiary:   Color(0xFFFDBA74)  // orange-300
accent:         Color(0xFFC2410C)  // orange-700
accentAlt:      Color(0xFFB45309)  // amber-700
// Gradient: orange-700 → amber-700

// Category colors (for card accents)
shopping:  Color(0xFF22C55E)  // green-500
todos:     Color(0xFF3B82F6)  // blue-500
ideas:     Color(0xFFA855F7)  // purple-500
general:   Color(0xFF6B7280)  // gray-500
```

#### Design Tokens
- **Spacing**: 4, 8, 12, 16, 24, 32, 48, 64
- **Radius**: sm=8, md=12, lg=16, xl=24
- **Typography**: Inter or system font, sizes 12/14/16/20/24/32
- **Card elevation**: 0 (flat with border) for notes, 2 for floating elements
- **Animation durations**: fast=150ms, medium=300ms, slow=500ms

---

## Part 4: Implementation Phases

### Phase 1: Foundation + Notes UI + Unified Input ✅ COMPLETE
*Goal: Beautiful notes app shell with storage layer + unified smart input*

**COMPLETED in this session:**
1. ✅ Theme system (ThemeExtension, design tokens, colors, typography, category colors)
2. ✅ go_router: 4-tab navigation (Home, Folders, Ask, Settings)
3. ✅ freezed Note model + NoteCategory + NoteSource enums + repositories
4. ✅ NoteFileStore — read/write markdown with YAML frontmatter
5. ✅ ObjectBox note index (metadata + FTS)
6. ✅ NoteRepository — orchestrates file store + index
7. ✅ Home screen: card-based Bento grid with smart grouping + filter chips
8. ✅ Note card widget: color-coded by category, source badge, confidence dot
9. ✅ Note detail screen (view + edit)
10. ✅ Folders screen: hierarchical list view grouped by category (NEW feature)
11. ✅ Ask screen: chat interface with message bubbles
12. ✅ **UniversalInputBar** widget (replaces fragmented input methods)
   - Shows on Home, Folders, Ask tabs (not Settings)
   - "What's on your mind?" placeholder (intent-agnostic)
   - Prominent red gradient mic button (separate from main input)
   - Camera icon for photo capture
13. ✅ **IntentClassifier** abstraction + MockIntentClassifier (regex-based)
   - Questions: what/when/where/who/how/why/find/show me
   - Todos: remind me/need to/don't forget
   - Shopping: buy/get/purchase
   - Ideas: idea/concept/brainstorm
   - Default: general notes
14. ✅ **UnifiedInputProvider** (StateNotifier)
   - Routes input through intent classification
   - Questions → ChatProvider → Ask tab
   - Notes → NotesProvider → stay on current tab
15. ✅ Enhanced message bubbles (larger, better spacing)
16. ✅ Android 16 Edge-to-Edge fix (SafeArea + BottomNavigationBar)
17. ✅ Text capture integration with UnifiedInputProvider
18. ✅ Voice recording integration with UnifiedInputProvider

**To be completed in Phase 2:**
- LLM-powered STT (sherpa_onnx)
- Processing pipeline animations
- Real-time transcription UI
- Confidence scoring + disambiguation

**Deferred to Phase 3+:**
- LLM rewriting (llamadart)
- Auto-classification with confidence
- Embeddings + semantic search

### Phase 2: Recording + STT
*Goal: Tap record → see waveform + live transcription → get transcript*
1. Add packages: record, audio_waveforms, pulsator, sherpa_onnx, permission_handler
2. Center FAB record button with idle pulse animation
3. Audio recording with streaming + pause/resume
4. Expandable bottom sheet recording UI:
   - Live waveform visualization
   - Real-time transcription (streaming STT)
   - Timer, pause/stop controls (thumb-reachable)
   - Swipe up to expand to full screen
5. RecordingState (Idle → Recording → Paused → Stopped)
6. STTEngine abstraction + SherpaSTTEngine (Moonshine model)
7. Wire: recording audio stream → STT stream → live transcription display

### Phase 3: LLM Pipeline + Auto-Organization
*Goal: Voice note → clean, classified, filed note — with visible AI processing*
1. Add packages: llamadart
2. LLMEngine abstraction + LlamadartEngine
3. Model manager: registry, download with progress UI, storage
4. Prompt templates: rewrite, classify, tag extraction
5. Processing pipeline: transcribe → rewrite → classify → save
6. **Processing animation**: Bottom sheet morphs into step-by-step progress (✓ Transcribed → ◎ Rewriting → ○ Classifying → ○ Filing)
7. **Done state**: Card shows category + confidence + related notes count → auto-dismisses into grid
8. Confidence threshold + disambiguation chips ("What kind of note is this?")
9. Before/after toggle (original transcript vs rewritten)
10. AI transparency: tap category → see "why" explanation
11. One-tap override for wrong category + learning feedback
12. Undo button (30s timeout after filing)

### Phase 4: Embeddings + RAG Core
*Goal: Semantic search + "ask your notes" + smart merging*
1. Add packages: flutter_gemma (EmbeddingGemma)
2. EmbeddingEngine abstraction + GemmaEmbeddingEngine
3. ObjectBox vector store (HNSW index for embeddings)
4. Chunker (400-512 tokens, 20% overlap)
5. Embed all notes on save (background processing)
6. RAG engine: query → retrieve → augment → generate
7. Search screen: hybrid keyword + semantic search
8. "Ask your notes" screen (chat interface, RAG-powered Q&A)
9. Smart merging: "Also get bananas" → finds + appends to grocery list

### Phase 5: Multi-Input + Polish
*Goal: Beyond voice — capture anything, polished UX*
1. Add packages: google_mlkit_text_recognition, pdfrx
2. Text capture (paste/type → process through pipeline)
3. Photo capture (camera → OCR → process through pipeline)
4. Document import (PDF text extraction → process through pipeline)
5. Capture menu (choose input type)
6. Onboarding flow (privacy, permissions, model downloads)
7. Settings screen (model selection, confidence threshold)
8. Animations + transitions (flutter_animate)
9. Haptic feedback, error states, edge cases
10. Accessibility pass (48px targets, contrast, screen reader labels)

### Phase 6: Intelligence Layer (post-MVP)
*Goal: The app gets smarter over time*
1. Auto-linking: new notes show "Related notes" based on embedding similarity
2. Smart tagging: LLM extracts tags, suggests connections
3. Note clustering: group related ideas automatically
4. Weekly digest: LLM summarizes your ideas, completed todos, patterns
5. Contextual recall: "What did I say about the wedding?" → precise answer
6. Custom categories (user-created, become new folders)
7. Quick capture Android widget (one-tap record from home screen)
8. Cloud sync (iCloud/Google Drive — just sync the notes folder)
9. Export (notes are already .md — share directly)

---

## Part 5: Differentiators & Extra Ideas

### "Wow" Features
- **Before/after toggle**: See the messy transcript vs the clean note — shows the AI's value
- **Confidence indicator**: Subtle badge showing how sure the AI was
- **Processing animation**: Show transcribe → rewrite → classify steps happening in real-time
- **"All on your device" badge**: Trust signal in settings, shows zero network calls
- **Related notes sidebar**: Open any note → see semantically similar ones
- **Knowledge graph view**: Visual map of how your notes connect (future)

### Smart Behaviors
- **Append detection**: "Also..." or "One more thing..." → finds and updates recent note
- **Recurring patterns**: "Buy milk" every week → suggest template
- **Context carry-over**: Recording references a previous note → LLM links them
- **Smart search**: "that recipe idea from last month" → semantic search finds it
- **Category learning**: Over time, learns user's custom categories from corrections

---

## Part 6: Packages Summary

```yaml
dependencies:
  # State management + DI
  flutter_riverpod: ^3.0.0
  riverpod_annotation: ^3.0.0

  # Navigation
  go_router: ^latest

  # Data models
  freezed_annotation: ^latest
  json_annotation: ^latest

  # Storage
  objectbox: ^latest              # Note index + vector embeddings (HNSW)
  objectbox_flutter_libs: ^latest
  path_provider: ^latest
  yaml: ^latest                   # Parse YAML frontmatter

  # On-device AI
  llamadart: ^0.4.0               # LLM inference (GGUF models)
  sherpa_onnx: ^1.12.24           # STT (Moonshine model)
  flutter_gemma: ^latest          # EmbeddingGemma (on-device embeddings)

  # Audio
  record: ^6.2.0
  audio_waveforms: ^latest

  # UI
  flutter_animate: ^latest
  pulsator: ^latest

  # Input capture
  google_mlkit_text_recognition: ^latest  # OCR
  pdfrx: ^latest                          # PDF text extraction

  # Utilities
  shared_preferences: ^latest
  uuid: ^latest
  permission_handler: ^latest

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^3.0.0
  build_runner: ^latest
  freezed: ^latest
  json_serializable: ^latest
  objectbox_generator: ^latest
  mocktail: ^latest
  flutter_lints: ^latest
```

---

## Part 7: Testing Strategy

- **70% unit tests**: Providers, repositories, pipeline logic, RAG engine, prompt templates, chunker, Result handling
- **20% widget tests**: Notes list, note detail, recording UI, search, category tabs
- **10% integration tests**: Full voice → processed note flow, search finds note, RAG Q&A returns answer
- Mock STTEngine, LLMEngine, EmbeddingEngine via Riverpod overrides
- Use `mocktail` for mock implementations

---

## Part 8: Immediate Next Steps

**Phase 1 ✅ COMPLETE** — All foundation + unified input fully implemented

**Phase 2 (Next): Recording + STT Integration**
1. Add packages: sherpa_onnx, record, audio_waveforms, pulsator
2. STTEngine abstraction + SherpaSTTEngine implementation
3. Wire recording UI to STT engine for live transcription
4. Test: Record audio → see live transcript on device
5. Integration test: End-to-end voice → text → classification

**Phase 3 (After Phase 2): LLM Pipeline + Auto-Organization**
1. Add packages: llamadart
2. LLMEngine abstraction + LlamadartEngine
3. Model manager + download UI
4. Prompt templates (rewrite, classify, extract tags)
5. Processing pipeline: transcribe → rewrite → classify → embed → save
6. Processing animation: Show ✓ Transcribed → ◎ Rewriting → ○ Classifying
7. Replace MockIntentClassifier with LLM-based classifier for better accuracy
8. Confidence scoring + disambiguation flow

**Phase 4 (After Phase 3): Embeddings + RAG Core**
1. Add packages: flutter_gemma
2. EmbeddingEngine abstraction + GemmaEmbeddingEngine
3. ObjectBox vector store (HNSW indexing)
4. Chunker (400-512 tokens, 20% overlap)
5. RAG engine: query → retrieve → augment → generate
6. Update search screen: hybrid keyword + semantic search
7. Smart merging: "Also get bananas" → append to grocery list

**Phase 5+ (Polish & Intelligence)**
- Multi-input (text, photo, document) via capture menu
- Onboarding flow (privacy, permissions, model downloads)
- Settings screen (model selection, confidence thresholds)
- Animations + haptic feedback
- Auto-linking, clustering, weekly digest

---

## Verification

**Phase 1 ✅ COMPLETE:**
- ✅ `flutter analyze` passes (no issues)
- ✅ `flutter build apk` passes (all architectures)
- ✅ Can create notes via text input
- ✅ Can view, edit, categorize notes (stored as .md files)
- ✅ Notes appear in Home grid with smart grouping (Today, This Week, Earlier)
- ✅ Notes appear in Folders view grouped by category
- ✅ Filter chips work on Home tab
- ✅ Ask tab displays with message bubbles (larger, enhanced)
- ✅ UniversalInputBar shows on Home, Folders, Ask (not Settings)
- ✅ Text input routes through UnifiedInputProvider
- ✅ Voice input transcripts route through UnifiedInputProvider
- ✅ Questions detected via intent classifier navigate to Ask tab
- ✅ Notes created via intent classifier stay on current tab
- ✅ UI works without overlap on Android 16 (Pixel 8)
- ✅ App ready for STT integration in Phase 2

**Phase 2 (Next):**
- Can record audio + see waveform
- Live transcription displayed during recording
- Transcript fed to UnifiedInputProvider for intent detection
- End-to-end voice → text → classification flow

**Phase 3 (After Phase 2):**
- Full voice → rewrite → classify → save pipeline with animations
- LLM-powered intent detection (not just regex)
- Confidence scoring with disambiguation UI

**Phase 4 (After Phase 3):**
- Semantic search finds related notes
- "Ask your notes" returns grounded answers via RAG
- Smart merging of similar notes

**Phase 5 (Polish & Intelligence):**
- Can capture via voice, text, photo, document
- Auto-linking, clustering, weekly digest
- Onboarding flow, settings, accessibility
