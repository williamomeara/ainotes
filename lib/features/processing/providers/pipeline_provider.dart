import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/embedding_engine.dart';
import '../../../core/ai/gemma_embedding_engine.dart';
import '../../../core/ai/intent_classifier.dart';
import '../../../core/ai/llamadart_engine.dart';
import '../../../core/ai/llm_engine.dart';
import '../../../core/ai/llm_intent_classifier.dart';
import '../../../core/ai/mock_embedding_engine.dart';
import '../../../core/ai/mock_intent_classifier.dart';
import '../../../core/ai/mock_llm_engine.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/daos/categories_dao.dart';
import '../../../core/storage/daos/chunks_dao.dart';
import '../../../core/storage/drift_vector_store.dart';
import '../../../core/storage/vector_store.dart';
import '../../models_manager/domain/download_state.dart';
import '../../models_manager/providers/model_manager_provider.dart';
import '../../notes/domain/note.dart';
import '../../notes/domain/note_source.dart';
import '../../notes/providers/notes_provider.dart';
import '../domain/processing_pipeline.dart';

/// Provides a singleton LLM engine.
final llmEngineProvider = Provider<LLMEngine>((ref) {
  final modelState = ref.watch(modelManagerProvider);
  final llmState = modelState.getDownloadState('qwen-2.5-1.5b');
  if (llmState is Ready && llmState.localPath != 'mock://') {
    debugPrint('[AiNotes] LLM engine: LlamaDartEngine');
    return LlamaDartEngine();
  }
  debugPrint('[AiNotes] LLM engine: MockLLMEngine');
  return MockLLMEngine();
});

/// Provides a singleton embedding engine.
final embeddingEngineProvider = Provider<EmbeddingEngine>((ref) {
  final modelState = ref.watch(modelManagerProvider);
  final embState = modelState.getDownloadState('embedding-gemma-300m');
  if (embState is Ready && embState.localPath != 'mock://') {
    debugPrint('[AiNotes] Embedding engine: GemmaEmbeddingEngine');
    return GemmaEmbeddingEngine();
  }
  debugPrint('[AiNotes] Embedding engine: MockEmbeddingEngine');
  return MockEmbeddingEngine();
});

/// Provides a persistent vector store backed by SQLite.
final vectorStoreProvider = Provider<VectorStore>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftVectorStore(ChunksDao(db));
});

/// Provides the intent classifier.
/// Falls back to MockIntentClassifier if the LLM engine isn't ready,
/// since the intent classifier runs before model loading in processAndUpdate.
final intentClassifierProvider = Provider<IntentClassifier>((ref) {
  final llmEngine = ref.watch(llmEngineProvider);
  if (llmEngine is LlamaDartEngine) {
    final modelState = ref.watch(modelManagerProvider);
    final llmState = modelState.getDownloadState('qwen-2.5-1.5b');
    if (llmState is Ready && llmState.localPath.isNotEmpty) {
      debugPrint('[AiNotes] Intent classifier: LLMIntentClassifier (model: ${llmState.localPath})');
      return LLMIntentClassifier(llmEngine: llmEngine);
    }
    debugPrint('[AiNotes] Intent classifier: MockIntentClassifier (LlamaDart available but model not ready)');
    return MockIntentClassifier();
  }
  debugPrint('[AiNotes] Intent classifier: MockIntentClassifier');
  return MockIntentClassifier();
});

/// Provides the processing pipeline.
final processingPipelineProvider = Provider<ProcessingPipeline>((ref) {
  return ProcessingPipeline(
    llmEngine: ref.watch(llmEngineProvider),
    embeddingEngine: ref.watch(embeddingEngineProvider),
    vectorStore: ref.watch(vectorStoreProvider),
  );
});

/// Holds streaming rewrite text for notes being actively processed.
/// Key: noteId, Value: accumulated text so far.
class RewriteStreamState {
  final Map<String, String> streams;
  const RewriteStreamState({this.streams = const {}});

  RewriteStreamState withText(String noteId, String text) {
    return RewriteStreamState(streams: {...streams, noteId: text});
  }

  RewriteStreamState without(String noteId) {
    return RewriteStreamState(
      streams: Map.fromEntries(streams.entries.where((e) => e.key != noteId)),
    );
  }
}

class RewriteStreamNotifier extends StateNotifier<RewriteStreamState> {
  RewriteStreamNotifier() : super(const RewriteStreamState());

  void updateText(String noteId, String text) {
    state = state.withText(noteId, text);
  }

  void clear(String noteId) {
    state = state.without(noteId);
  }
}

final rewriteStreamProvider =
    StateNotifierProvider<RewriteStreamNotifier, RewriteStreamState>((ref) {
  return RewriteStreamNotifier();
});

/// State for an active processing job.
class ProcessingJobState {
  final ProcessingStep? currentStep;
  final bool isProcessing;
  final String? noteId;
  final String? error;

  const ProcessingJobState({
    this.currentStep,
    this.isProcessing = false,
    this.noteId,
    this.error,
  });

  ProcessingJobState copyWith({
    ProcessingStep? currentStep,
    bool? isProcessing,
    String? noteId,
    String? error,
  }) {
    return ProcessingJobState(
      currentStep: currentStep ?? this.currentStep,
      isProcessing: isProcessing ?? this.isProcessing,
      noteId: noteId ?? this.noteId,
      error: error,
    );
  }
}

/// Provider for processing jobs.
final processingJobProvider =
    StateNotifierProvider<ProcessingJobNotifier, ProcessingJobState>((ref) {
  return ProcessingJobNotifier(ref);
});

class ProcessingJobNotifier extends StateNotifier<ProcessingJobState> {
  final Ref ref;

  ProcessingJobNotifier(this.ref) : super(const ProcessingJobState());

  /// Process raw text through the full pipeline and create a note.
  Future<Note?> processInput(
    String rawText, {
    NoteSource source = NoteSource.text,
  }) async {
    debugPrint('[AiNotes] Processing pipeline starting for ${rawText.length} chars');
    state = const ProcessingJobState(isProcessing: true);

    try {
      final pipeline = ref.read(processingPipelineProvider);
      final llmEngine = ref.read(llmEngineProvider);
      final embeddingEngine = ref.read(embeddingEngineProvider);

      // Load models with real paths when available
      final modelState = ref.read(modelManagerProvider);
      final llmState = modelState.getDownloadState('qwen-2.5-1.5b');
      final embState = modelState.getDownloadState('embedding-gemma-300m');

      // Load LLM model (required for processing)
      if (llmState is Ready && llmState.localPath.isNotEmpty) {
        if (llmEngine is! MockLLMEngine) {
          final modelFile = File(llmState.localPath);
          if (await modelFile.exists()) {
            try {
              await llmEngine.loadModel(llmState.localPath);
              debugPrint('[AiNotes] LLM loaded (real): ${llmState.localPath}');
            } catch (e) {
              debugPrint('[AiNotes] LLM load failed: $e');
              throw Exception('Failed to load LLM: $e');
            }
          } else {
            throw Exception(
                'LLM model file not found at ${llmState.localPath}');
          }
        } else {
          await llmEngine.loadModel('');
          debugPrint('[AiNotes] LLM loaded (mock)');
        }
      } else if (llmEngine is MockLLMEngine) {
        await llmEngine.loadModel('');
        debugPrint('[AiNotes] LLM loaded (mock)');
      } else {
        throw Exception('LLM model not downloaded');
      }

      // Load embedding model (non-fatal)
      var embeddingAvailable = false;
      if (embState is Ready && embState.localPath.isNotEmpty) {
        if (embeddingEngine is! MockEmbeddingEngine) {
          try {
            await embeddingEngine.loadModel(embState.localPath);
            embeddingAvailable = true;
            debugPrint('[AiNotes] Embedding loaded (real): ${embState.localPath}');
          } catch (e) {
            debugPrint('[AiNotes] Embedding load failed (non-fatal): $e');
          }
        } else {
          await embeddingEngine.loadModel('');
          embeddingAvailable = true;
          debugPrint('[AiNotes] Embedding loaded (mock)');
        }
      } else if (embeddingEngine is MockEmbeddingEngine) {
        await embeddingEngine.loadModel('');
        embeddingAvailable = true;
        debugPrint('[AiNotes] Embedding loaded (mock)');
      } else {
        debugPrint('[AiNotes] Embedding model not installed (non-fatal)');
      }

      // Run processing pipeline
      debugPrint('[AiNotes] Running LLM pipeline (rewrite -> classify+tag)');
      final result = await pipeline.process(
        rawText,
        onStep: (step) {
          state = state.copyWith(currentStep: step);
        },
      );

      // Create the note
      final note = await ref.read(notesProvider.notifier).createNote(
            originalText: result.originalText,
            rewrittenText: result.rewrittenText,
            categoryName: result.categoryName,
            confidence: result.confidence,
            source: source,
            tags: result.tags,
          );

      if (note != null) {
        debugPrint('[AiNotes] Note created: ${note.id} (category: ${result.categoryName}, confidence: ${result.confidence})');

        // Embed the note (non-fatal)
        if (embeddingAvailable) {
          try {
            await pipeline.embedNote(note.id, result.rewrittenText);
            debugPrint('[AiNotes] Note embedded: ${note.id}');
          } catch (e) {
            debugPrint('[AiNotes] Note embedding failed (non-fatal): $e');
          }
        } else {
          debugPrint('[AiNotes] Skipping embedding - engine not available');
        }

        state = ProcessingJobState(
          isProcessing: false,
          noteId: note.id,
        );
      }

      return note;
    } catch (e) {
      debugPrint('[AiNotes] Processing pipeline failed: $e');
      state = ProcessingJobState(
        isProcessing: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Process a note in the background and update it in-place.
  Future<void> processAndUpdate({
    required String noteId,
    required String rawText,
    required NoteSource source,
  }) async {
    debugPrint('[AiNotes] ┌── processAndUpdate START ──');
    debugPrint('[AiNotes] │ noteId: $noteId');
    debugPrint('[AiNotes] │ rawText: ${rawText.length} chars');
    debugPrint('[AiNotes] │ source: ${source.name}');
    state = ProcessingJobState(isProcessing: true, noteId: noteId);

    try {
      final pipeline = ref.read(processingPipelineProvider);
      final llmEngine = ref.read(llmEngineProvider);
      final embeddingEngine = ref.read(embeddingEngineProvider);
      debugPrint('[AiNotes] │ LLM engine: ${llmEngine.runtimeType}');
      debugPrint('[AiNotes] │ Embedding engine: ${embeddingEngine.runtimeType}');

      // Load models
      final modelState = ref.read(modelManagerProvider);
      final llmState = modelState.getDownloadState('qwen-2.5-1.5b');
      final embState = modelState.getDownloadState('embedding-gemma-300m');
      debugPrint('[AiNotes] │ LLM state: ${llmState.runtimeType}');
      debugPrint('[AiNotes] │ Embedding state: ${embState.runtimeType}');

      if (llmState is Ready && llmState.localPath.isNotEmpty) {
        if (llmEngine is! MockLLMEngine) {
          debugPrint('[AiNotes] │ Loading real LLM model: ${llmState.localPath}');
          await llmEngine.loadModel(llmState.localPath);
          debugPrint('[AiNotes] │ Real LLM model loaded OK');
        } else {
          await llmEngine.loadModel('');
          debugPrint('[AiNotes] │ Mock LLM loaded');
        }
      } else if (llmEngine is MockLLMEngine) {
        await llmEngine.loadModel('');
        debugPrint('[AiNotes] │ Mock LLM loaded');
      } else {
        debugPrint('[AiNotes] └── ABORT: LLM not available');
        state = ProcessingJobState(isProcessing: false, noteId: noteId);
        return;
      }

      // Run streaming pipeline
      final streamNotifier = ref.read(rewriteStreamProvider.notifier);
      debugPrint('[AiNotes] │ Starting streaming pipeline...');
      var tokenCount = 0;

      final result = await pipeline.processStreaming(
        rawText,
        onStep: (step) {
          debugPrint('[AiNotes] │ Step: ${step.label}');
          state = state.copyWith(currentStep: step);
        },
        onRewriteToken: (accumulated) {
          tokenCount++;
          streamNotifier.updateText(noteId, accumulated);
        },
      );

      debugPrint('[AiNotes] │ Streaming done: $tokenCount tokens, rewrite="${result.rewrittenText}"');
      debugPrint('[AiNotes] │ Classification: ${result.categoryName} (${result.confidence}), tags=${result.tags}');

      // Rewrite complete — write to DB and clear stream
      final notesNotifier = ref.read(notesProvider.notifier);
      final notes = await ref.read(notesProvider.future);
      final existingNote = notes.where((n) => n.id == noteId).firstOrNull;

      if (existingNote != null) {
        debugPrint('[AiNotes] │ DB update 1/2: writing rewrittenText');
        await notesNotifier.updateNote(existingNote.copyWith(
          rewrittenText: result.rewrittenText,
        ));
        streamNotifier.clear(noteId);
        debugPrint('[AiNotes] │ Stream cleared, rewrittenText persisted');

        // Now resolve category and write classification
        final categoriesDao = CategoriesDao(ref.read(databaseProvider));
        final category =
            await categoriesDao.getOrCreateCategory(result.categoryName);
        debugPrint('[AiNotes] │ Category resolved: "${category.name}" (id=${category.id})');

        // Re-read note after rewrite update
        final updatedNotes = await ref.read(notesProvider.future);
        final updatedNote = updatedNotes.where((n) => n.id == noteId).firstOrNull;

        if (updatedNote != null) {
          debugPrint('[AiNotes] │ DB update 2/2: writing classification + isDraft=false');
          await notesNotifier.updateNote(updatedNote.copyWith(
            categoryId: category.id,
            categoryName: category.name,
            confidence: result.confidence,
            tags: result.tags,
            isDraft: false,
          ));
          debugPrint('[AiNotes] │ Note finalized (isDraft=false)');
        } else {
          debugPrint('[AiNotes] │ WARNING: note $noteId not found after rewrite update');
        }
      } else {
        debugPrint('[AiNotes] │ WARNING: note $noteId not found in provider state');
      }

      // Embed (non-fatal)
      var embeddingAvailable = false;
      if (embState is Ready && embState.localPath.isNotEmpty) {
        if (embeddingEngine is! MockEmbeddingEngine) {
          try {
            debugPrint('[AiNotes] │ Loading real embedding model: ${embState.localPath}');
            await embeddingEngine.loadModel(embState.localPath);
            embeddingAvailable = true;
          } catch (e) {
            debugPrint('[AiNotes] │ Embedding load failed (non-fatal): $e');
          }
        } else {
          await embeddingEngine.loadModel('');
          embeddingAvailable = true;
        }
      } else if (embeddingEngine is MockEmbeddingEngine) {
        await embeddingEngine.loadModel('');
        embeddingAvailable = true;
      }

      if (embeddingAvailable) {
        try {
          debugPrint('[AiNotes] │ Embedding note $noteId...');
          await pipeline.embedNote(noteId, result.rewrittenText);
          debugPrint('[AiNotes] │ Embedding complete');
        } catch (e) {
          debugPrint('[AiNotes] │ Embedding failed (non-fatal): $e');
        }
      } else {
        debugPrint('[AiNotes] │ Skipping embedding - not available');
      }

      state = ProcessingJobState(isProcessing: false, noteId: noteId);
      debugPrint('[AiNotes] └── processAndUpdate DONE ──');
    } catch (e, st) {
      debugPrint('[AiNotes] └── processAndUpdate FAILED: $e');
      debugPrint('[AiNotes]     Stack trace: $st');
      state = ProcessingJobState(
        isProcessing: false,
        noteId: noteId,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const ProcessingJobState();
  }
}
