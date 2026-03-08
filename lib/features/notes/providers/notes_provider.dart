import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/daos/categories_dao.dart';
import '../../../core/storage/daos/notes_dao.dart';
import '../domain/note.dart';
import '../domain/note_source.dart';
import 'note_repository.dart';

final notesDaoProvider = Provider<NotesDao>((ref) {
  return NotesDao(ref.watch(databaseProvider));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(
    notesDao: ref.watch(notesDaoProvider),
    categoriesDao: CategoriesDao(ref.watch(databaseProvider)),
  );
});

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NoteRepository get _repo => ref.read(noteRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    final result = await _repo.getAllNotes();
    return result.when(
      ok: (notes) {
        debugPrint('[AiNotes] Loaded ${notes.length} notes');
        return notes;
      },
      err: (msg) {
        debugPrint('[AiNotes] Failed to load notes: $msg');
        return [];
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.getAllNotes();
      return result.when(
        ok: (notes) => notes,
        err: (msg) {
          debugPrint('[AiNotes] Failed to load notes: $msg');
          return [];
        },
      );
    });
  }

  Future<Note?> createNote({
    required String originalText,
    required String rewrittenText,
    required String categoryName,
    double confidence = 0.0,
    NoteSource source = NoteSource.text,
    List<String> tags = const [],
    bool isDraft = false,
  }) async {
    debugPrint('[AiNotes] createNote(category=$categoryName, isDraft=$isDraft, source=${source.name})');
    final result = await _repo.createNote(
      originalText: originalText,
      rewrittenText: rewrittenText,
      categoryName: categoryName,
      confidence: confidence,
      source: source,
      tags: tags,
      isDraft: isDraft,
    );
    return result.when(
      ok: (note) {
        debugPrint('[AiNotes] Note created OK: ${note.id} (${note.categoryName}, isDraft=${note.isDraft})');
        refresh();
        return note;
      },
      err: (msg) {
        debugPrint('[AiNotes] Note creation FAILED: $msg');
        return null;
      },
    );
  }

  Future<bool> updateNote(Note note) async {
    debugPrint('[AiNotes] updateNote(${note.id}, isDraft=${note.isDraft}, category=${note.categoryName}, rewrite=${note.rewrittenText.length}ch)');
    final result = await _repo.updateNote(note);
    return result.when(
      ok: (_) async {
        debugPrint('[AiNotes] updateNote OK, refreshing provider...');
        await refresh();
        debugPrint('[AiNotes] Provider refreshed after updateNote');
        return true;
      },
      err: (msg) {
        debugPrint('[AiNotes] updateNote FAILED: $msg');
        return false;
      },
    );
  }

  Future<bool> deleteNote(String id) async {
    final result = await _repo.deleteNote(id);
    return result.when(
      ok: (_) {
        refresh();
        return true;
      },
      err: (_) => false,
    );
  }
}

final selectedCategoryProvider = StateProvider<int?>((ref) => null);

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  final notes = ref.watch(notesProvider);
  if (categoryId == null) return notes;
  return notes.whenData(
    (list) => list.where((n) => n.categoryId == categoryId).toList(),
  );
});
