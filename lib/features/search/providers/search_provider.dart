import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/note.dart';
import '../../notes/providers/notes_provider.dart';
import '../../processing/providers/pipeline_provider.dart';

enum SearchMode { keyword, semantic }

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchModeProvider = StateProvider<SearchMode>((ref) => SearchMode.keyword);

final searchResultsProvider = FutureProvider<List<Note>>((ref) async {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];

  final mode = ref.watch(searchModeProvider);
  final notes = ref.watch(notesProvider);

  return notes.when(
    loading: () => [],
    error: (_, _) => [],
    data: (allNotes) async {
      if (mode == SearchMode.keyword) {
        return allNotes
            .where((n) =>
                n.rewrittenText.toLowerCase().contains(query) ||
                n.originalText.toLowerCase().contains(query) ||
                n.tags.any((t) => t.toLowerCase().contains(query)))
            .toList();
      }

      // Semantic search using vector store
      final vectorStore = ref.read(vectorStoreProvider);
      final embeddingEngine = ref.read(embeddingEngineProvider);

      try {
        await embeddingEngine.loadModel('');
        final queryEmbedding = await embeddingEngine.embed(query);
        final results = await vectorStore.search(queryEmbedding, topK: 10);

        // Map search results back to notes
        final noteIds = results.map((r) => r.noteId).toSet();
        return allNotes.where((n) => noteIds.contains(n.id)).toList();
      } catch (_) {
        // Fallback to keyword search
        return allNotes
            .where((n) =>
                n.rewrittenText.toLowerCase().contains(query) ||
                n.originalText.toLowerCase().contains(query))
            .toList();
      }
    },
  );
});
