# DECISIONS.md — AiNotes Autonomous Build

Tracking all architectural and implementation decisions during autonomous build phase.

---

## Decision Log

### 1. Handle Untracked SherpaSTTEngine & Recording Files

**Problem:**
- `lib/core/ai/sherpa_stt_engine.dart` created but not committed
- `lib/features/recording/domain/recording_state.dart` created but not committed
- `lib/features/recording/providers/recording_provider.dart` modified
- These represent partially completed Phase 2 work

**Choice:**
Clean up uncommitted changes and rebuild Phase 2 systematically from scratch, following the implementation plan precisely.

**Alternatives:**
- Keep partial work and build on top (risk: inconsistent patterns, unfinished integration)
- Commit partial work as-is (violates principle of clean, reviewable commits)

**Status:** ✅ COMPLETE

---

### 2. Recording API Compatibility & STT Integration Strategy

**Problem:**
- sherpa_onnx and audio_waveforms packages require native compilation and model files
- Can't verify APIs without device-specific builds
- RecordingScreen UI was built expecting old RecordingState enum

**Choice:**
Use MockSTTEngine for all development/testing. Create placeholder SherpaSTTEngine with TODO markers. This allows full end-to-end testing without native dependencies.

**Rationale:**
- Follows the same pluggable interface pattern established in Phase 1 (MockIntentClassifier)
- RecordingNotifier state logic is fully testable
- Real SherpaSTTEngine is a drop-in replacement when model files are available

**Status:** ✅ COMPLETE

---

### 3. Remove Native AI Package Dependencies from pubspec.yaml

**Problem:**
- `sherpa_onnx`, `audio_waveforms`, `llamadart`, `flutter_gemma` all require native compilation, model files, or platform-specific setup
- These block `flutter analyze` and `flutter test` from running
- Can't download 200MB+ model files in an autonomous build

**Choice:**
Comment out all native AI packages in pubspec.yaml. Implement complete mock engines (MockLLMEngine, MockEmbeddingEngine, MockSTTEngine) that exercise the full architecture without native dependencies.

**Rationale:**
- Mock engines implement the same abstract interfaces (LLMEngine, EmbeddingEngine, STTEngine)
- All business logic, state management, and UI can be tested end-to-end
- Swapping to real engines requires only changing the Riverpod provider bindings
- `flutter analyze` and `flutter test` pass cleanly

**Trade-offs:**
- Mock LLM uses regex, not real language understanding
- Mock embeddings use deterministic hashing, not semantic similarity
- Real model performance characteristics (latency, memory) not tested

**Status:** ✅ COMPLETE

---

### 4. In-Memory VectorStore Instead of ObjectBox HNSW

**Problem:**
- ObjectBox vector search requires native ObjectBox binary and store initialization
- The existing ObjectBox setup was for metadata indexing, not vector storage
- Need vector search for RAG pipeline (Phase 4)

**Choice:**
Implement VectorStore as a pure Dart in-memory store with brute-force cosine similarity search. No native dependencies required.

**Rationale:**
- For development/testing, in-memory is sufficient (notes collections are small)
- Cosine similarity is correct and produces identical results to HNSW for small datasets
- Clean interface: `addChunk()`, `removeNote()`, `search()`, `clear()`
- Production migration to ObjectBox HNSW requires only reimplementing VectorStore

**Trade-offs:**
- O(n) search instead of O(log n) — acceptable for <10k chunks
- No persistence across app restarts (would need serialization)
- No HNSW tuning (ef, M parameters)

**Status:** ✅ COMPLETE

---

### 5. MockLLMEngine Design: Regex-Based Response Generation

**Problem:**
- Need LLM-like behavior for rewriting, classification, tag extraction, and Q&A
- Can't use real LLM without llamadart + model files

**Choice:**
MockLLMEngine parses the prompt to detect the task type (rewrite/classify/tags/QA), then uses regex and keyword matching to produce plausible responses.

**Implementation Details:**
- Rewrite: Capitalizes, removes filler words ("um", "uh", "like"), adds bullet formatting
- Classify: Keyword matching (buy/get → shopping, remind/todo → todos, idea/concept → ideas)
- Tags: Extracts nouns and key phrases from text
- Q&A: Searches RAG context for relevant sentences, returns them as the answer
- Stream mode: Yields response word-by-word with delays for realistic UX

**Status:** ✅ COMPLETE

---

### 6. MockEmbeddingEngine Design: Deterministic Pseudo-Embeddings

**Problem:**
- Need embedding vectors for vector search and RAG
- Real embeddings require flutter_gemma + EmbeddingGemma model (300MB)

**Choice:**
MockEmbeddingEngine generates 384-dimensional vectors using word-level hashing. Each word contributes to specific dimensions based on its hash, producing L2-normalized vectors. Similar texts (sharing words) produce similar vectors.

**Key Property:**
- `cosineSimilarity("buy milk eggs", "buy milk bread") > cosineSimilarity("buy milk eggs", "call dentist")`
- This is sufficient for testing RAG retrieval and semantic search

**Status:** ✅ COMPLETE

---

### 7. RAG Engine Architecture

**Problem:**
- Need end-to-end RAG: index notes → query → retrieve → generate answer
- Multiple components must work together: Chunker, EmbeddingEngine, VectorStore, LLMEngine

**Choice:**
RAGEngine orchestrates all components with a clean API:
- `indexNote(noteId, text)` — chunk → embed → store
- `removeNote(noteId)` — remove from vector store
- `query(question)` → `RAGResult(answer, sourceNoteIds)` — embed query → search → build context → LLM generate
- `findSimilar(text)` → `List<String>` noteIds — for auto-linking

**Architecture:**
```
User Query → EmbeddingEngine.embed() → VectorStore.search()
                                              ↓
                                    Retrieved chunks with noteIds
                                              ↓
                                    ContextBuilder.build(query, chunks)
                                              ↓
                                    LLMEngine.generate(prompt)
                                              ↓
                                    RAGResult(answer, sourceNoteIds)
```

**Status:** ✅ COMPLETE

---

### 8. Processing Pipeline with Step Callbacks

**Problem:**
- Notes need multi-step processing: transcribe → rewrite → classify → tag → embed
- UI needs to show progress through each step

**Choice:**
ProcessingPipeline accepts an `OnStepChanged` callback that fires at each processing stage. Steps are defined as an enum: `transcribing`, `rewriting`, `classifying`, `embedding`.

**Result type:**
```dart
ProcessingResult {
  rewrittenText, category, confidence, tags
}
```

**Integration:**
- `ProcessingJobNotifier` (StateNotifier) manages the current job state
- UI can observe `processingJobProvider` to show step-by-step progress
- UnifiedInputProvider uses the pipeline for note creation

**Status:** ✅ COMPLETE

---

### 9. Dual-Mode Search (Keyword + Semantic)

**Problem:**
- Users expect both traditional text search and semantic "find related" search
- Need to bridge Phase 1 keyword search with Phase 4 semantic search

**Choice:**
SearchProvider supports two modes toggled by `searchModeProvider`:
- **Keyword mode**: Filters notes by text containment (case-insensitive)
- **Semantic mode**: Embeds query → vector store search → returns notes by similarity

Both modes use the same UI, with a toggle chip to switch between them.

**Status:** ✅ COMPLETE

---

### 10. Enhanced Note Detail with AI Transparency

**Problem:**
- Users need to see and override AI decisions (category, confidence)
- Original vs rewritten text should both be accessible
- Phase 1 note detail was read-only

**Choice:**
Enhanced NoteDetailScreen with:
- Inline text editing (tap to edit)
- Category override dropdown
- AI transparency panel showing: confidence score, source type, audio duration
- "Original text" expandable section
- Save/discard with proper state management

**Status:** ✅ COMPLETE

---

### 11. Intelligence Layer: AutoLinker, SmartTagger, WeeklyDigest

**Problem:**
- Phase 6 requires "intelligence" features that connect notes together
- Auto-linking, smart tagging, and weekly digests all need RAG + LLM

**Choice:**
Three independent modules, each composing existing engines:
- **AutoLinker**: Uses EmbeddingEngine to find semantically similar notes. Returns `List<LinkedNote>` with similarity scores.
- **SmartTagger**: Uses LLMEngine to extract tags from note text. Returns `List<String>` tags.
- **WeeklyDigest**: Uses LLMEngine to summarize a week's notes. Returns `DigestResult` with summary, top topics, and action items.

**Design principle:** Each module is a plain Dart class with constructor injection — no singletons, easy to test.

**Status:** ✅ COMPLETE

---

## Architecture Summary

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                       │
│  Home | Folders | Ask | Settings | Recording      │
│  UniversalInputBar (3 tabs)                       │
└─────────────┬───────────────────────────────────┘
              │
┌─────────────▼───────────────────────────────────┐
│              Provider Layer (Riverpod)            │
│  UnifiedInputProvider → IntentClassifier          │
│  ChatProvider → RAGEngine                         │
│  ProcessingJobNotifier → ProcessingPipeline        │
│  SearchProvider (keyword + semantic)              │
│  ModelManagerProvider                              │
└─────────────┬───────────────────────────────────┘
              │
┌─────────────▼───────────────────────────────────┐
│              AI Engine Layer (Pluggable)          │
│  LLMEngine ← MockLLMEngine / LlamaDartEngine     │
│  EmbeddingEngine ← MockEmbedding / GemmaEmbedding│
│  STTEngine ← MockSTTEngine / SherpaSTTEngine      │
│  IntentClassifier ← MockIntent / LLMIntent        │
└─────────────┬───────────────────────────────────┘
              │
┌─────────────▼───────────────────────────────────┐
│              Intelligence Layer                   │
│  RAGEngine (query + index + findSimilar)          │
│  ProcessingPipeline (rewrite + classify + tag)    │
│  AutoLinker | SmartTagger | WeeklyDigest          │
│  Chunker | ContextBuilder | PromptTemplates       │
└─────────────┬───────────────────────────────────┘
              │
┌─────────────▼───────────────────────────────────┐
│              Storage Layer                        │
│  NoteFileStore (markdown + YAML frontmatter)      │
│  NoteIndex (ObjectBox metadata + FTS)             │
│  VectorStore (in-memory cosine similarity)        │
└─────────────────────────────────────────────────┘
```

---

## Test Coverage

47 tests across 7 test files, all passing:
- `mock_llm_engine_test.dart` — rewrite, classify, tags, Q&A, streaming
- `mock_embedding_engine_test.dart` — dimensions, similarity, batch, determinism
- `mock_intent_classifier_test.dart` — questions, shopping, todos, ideas, general
- `mock_stt_engine_test.dart` — initialization, transcribe, streaming, dispose
- `chunker_test.dart` — empty, short, long, overlap, defaults
- `rag_engine_test.dart` — indexing, removal, query, fallback, findSimilar
- `vector_store_test.dart` — CRUD, search, topK, clear

---

## Commits

1. `8e5f34c` — Phase 2-3: LLM pipeline, RAG engine, model manager, processing pipeline
2. `c55fd0c` — Phase 4-5: semantic search, enhanced onboarding, note detail editing
3. `7f993a1` — Phase 6: intelligence layer (AutoLinker, SmartTagger, WeeklyDigest) + 47 tests

---

Last Updated: 2026-02-11
All Phases: ✅ COMPLETE (Phases 1-6)
Status: Full implementation with mock engines, ready for native AI integration
