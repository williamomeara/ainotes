import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/embedding_engine.dart';
import '../../../core/ai/gemma_embedding_engine.dart';
import '../../../core/ai/llamadart_engine.dart';
import '../../../core/ai/llm_engine.dart';
import '../../../core/ai/mock_embedding_engine.dart';
import '../../../core/ai/mock_llm_engine.dart';
import '../../../core/storage/vector_store.dart';
import '../../models_manager/domain/download_state.dart';
import '../../models_manager/providers/model_manager_provider.dart';
import '../../notes/domain/note.dart';
import '../../notes/domain/note_category.dart';
import '../../notes/providers/notes_provider.dart';
import '../domain/processing_pipeline.dart';

/// Provides a singleton LLM engine.
/// Uses real LlamaDartEngine when model is downloaded, MockLLMEngine otherwise.
final llmEngineProvider = Provider<LLMEngine>((ref) {
  final modelState = ref.watch(modelManagerProvider);
  final llmState = modelState.getDownloadState('qwen-2.5-1.5b');
  if (llmState is Ready && llmState.localPath != 'mock://') {
    return LlamaDartEngine();
  }
  return MockLLMEngine();
});

/// Provides a singleton embedding engine.
/// Uses real GemmaEmbeddingEngine when model is installed, MockEmbeddingEngine otherwise.
final embeddingEngineProvider = Provider<EmbeddingEngine>((ref) {
  final modelState = ref.watch(modelManagerProvider);
  final embState = modelState.getDownloadState('embedding-gemma-300m');
  if (embState is Ready && embState.localPath != 'mock://') {
    return GemmaEmbeddingEngine();
  }
  return MockEmbeddingEngine();
});

/// Provides a singleton vector store.
final vectorStoreProvider = Provider<VectorStore>((ref) {
  return VectorStore();
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
    state = const ProcessingJobState(isProcessing: true);

    try {
      final pipeline = ref.read(processingPipelineProvider);
      final llmEngine = ref.read(llmEngineProvider);
      final embeddingEngine = ref.read(embeddingEngineProvider);

      // Load models with real paths when available
      final modelState = ref.read(modelManagerProvider);
      final llmState = modelState.getDownloadState('qwen-2.5-1.5b');
      final embState = modelState.getDownloadState('embedding-gemma-300m');

      // Load LLM model only if path is valid
      if (llmState is Ready && llmState.localPath.isNotEmpty) {
        if (llmEngine is! MockLLMEngine) {
          final modelFile = File(llmState.localPath);
          if (await modelFile.exists()) {
            try {
              await llmEngine.loadModel(llmState.localPath);
            } catch (e) {
              throw Exception('Failed to load LLM: $e');
            }
          } else {
            throw Exception(
                'LLM model file not found at ${llmState.localPath}');
          }
        }
      } else if (llmEngine is! MockLLMEngine) {
        throw Exception('LLM model not downloaded');
      }

      // Load embedding model (GemmaEmbeddingEngine uses internal path)
      if (embState is Ready && embState.localPath.isNotEmpty) {
        if (embeddingEngine is! MockEmbeddingEngine) {
          try {
            await embeddingEngine.loadModel(embState.localPath);
          } catch (e) {
            throw Exception('Failed to load embedder: $e');
          }
        }
      } else if (embeddingEngine is! MockEmbeddingEngine) {
        throw Exception('Embedding model not installed');
      }

      // Run processing pipeline
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
            category: result.category,
            confidence: result.confidence,
            source: source,
            tags: result.tags,
          );

      if (note != null) {
        // Embed the note
        await pipeline.embedNote(note.id, result.rewrittenText);
        state = ProcessingJobState(
          isProcessing: false,
          noteId: note.id,
        );
      }

      return note;
    } catch (e) {
      state = ProcessingJobState(
        isProcessing: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const ProcessingJobState();
  }
}
