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
final intentClassifierProvider = Provider<IntentClassifier>((ref) {
  final llmEngine = ref.watch(llmEngineProvider);
  if (llmEngine is LlamaDartEngine) {
    debugPrint('[AiNotes] Intent classifier: LLMIntentClassifier');
    return LLMIntentClassifier(llmEngine: llmEngine);
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
    debugPrint('[AiNotes] Background processing starting for note $noteId');
    state = ProcessingJobState(isProcessing: true, noteId: noteId);

    try {
      final pipeline = ref.read(processingPipelineProvider);
      final llmEngine = ref.read(llmEngineProvider);
      final embeddingEngine = ref.read(embeddingEngineProvider);

      // Load models
      final modelState = ref.read(modelManagerProvider);
      final llmState = modelState.getDownloadState('qwen-2.5-1.5b');
      final embState = modelState.getDownloadState('embedding-gemma-300m');

      if (llmState is Ready && llmState.localPath.isNotEmpty) {
        if (llmEngine is! MockLLMEngine) {
          await llmEngine.loadModel(llmState.localPath);
        } else {
          await llmEngine.loadModel('');
        }
      } else if (llmEngine is MockLLMEngine) {
        await llmEngine.loadModel('');
      } else {
        debugPrint('[AiNotes] Background: LLM not available, skipping');
        state = ProcessingJobState(isProcessing: false, noteId: noteId);
        return;
      }

      // Run pipeline
      final result = await pipeline.process(
        rawText,
        onStep: (step) {
          state = state.copyWith(currentStep: step);
        },
      );

      // Update the note with processed data
      final notesNotifier = ref.read(notesProvider.notifier);
      final notes = await ref.read(notesProvider.future);
      final existingNote = notes.where((n) => n.id == noteId).firstOrNull;

      if (existingNote != null) {
        // Resolve category name to ID
        final categoriesDao = CategoriesDao(ref.read(databaseProvider));
        final category =
            await categoriesDao.getOrCreateCategory(result.categoryName);

        await notesNotifier.updateNote(existingNote.copyWith(
          rewrittenText: result.rewrittenText,
          categoryId: category.id,
          categoryName: category.name,
          confidence: result.confidence,
          tags: result.tags,
          isDraft: false,
        ));
        debugPrint('[AiNotes] Background: note $noteId updated (${result.categoryName}, ${result.confidence})');
      }

      // Embed (non-fatal)
      var embeddingAvailable = false;
      if (embState is Ready && embState.localPath.isNotEmpty) {
        if (embeddingEngine is! MockEmbeddingEngine) {
          try {
            await embeddingEngine.loadModel(embState.localPath);
            embeddingAvailable = true;
          } catch (_) {}
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
          await pipeline.embedNote(noteId, result.rewrittenText);
          debugPrint('[AiNotes] Background: note $noteId embedded');
        } catch (e) {
          debugPrint('[AiNotes] Background: embedding failed (non-fatal): $e');
        }
      }

      state = ProcessingJobState(isProcessing: false, noteId: noteId);
    } catch (e) {
      debugPrint('[AiNotes] Background processing failed: $e');
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
