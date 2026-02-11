import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/embedding_engine.dart';
import '../../../core/ai/llm_engine.dart';
import '../../../core/ai/mock_embedding_engine.dart';
import '../../../core/ai/mock_llm_engine.dart';
import '../../../core/storage/vector_store.dart';
import '../../notes/domain/note.dart';
import '../../notes/domain/note_category.dart';
import '../../notes/providers/notes_provider.dart';
import '../domain/processing_pipeline.dart';

/// Provides a singleton LLM engine.
final llmEngineProvider = Provider<LLMEngine>((ref) {
  return MockLLMEngine();
});

/// Provides a singleton embedding engine.
final embeddingEngineProvider = Provider<EmbeddingEngine>((ref) {
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

      // Ensure engines are loaded
      await ref.read(llmEngineProvider).loadModel('');
      await ref.read(embeddingEngineProvider).loadModel('');

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
