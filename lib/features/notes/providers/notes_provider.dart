import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note.dart';
import '../domain/note_category.dart';
import 'note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NoteRepository get _repo => ref.read(noteRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    final result = await _repo.getAllNotes();
    return result.when(ok: (notes) => notes, err: (_) => []);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.getAllNotes();
      return result.when(ok: (notes) => notes, err: (_) => []);
    });
  }

  Future<Note?> createNote({
    required String originalText,
    required String rewrittenText,
    required NoteCategory category,
    double confidence = 0.0,
    NoteSource source = NoteSource.text,
    List<String> tags = const [],
  }) async {
    final result = await _repo.createNote(
      originalText: originalText,
      rewrittenText: rewrittenText,
      category: category,
      confidence: confidence,
      source: source,
      tags: tags,
    );
    return result.when(
      ok: (note) {
        refresh();
        return note;
      },
      err: (_) => null,
    );
  }

  Future<bool> updateNote(Note note) async {
    final result = await _repo.updateNote(note);
    return result.when(
      ok: (_) {
        refresh();
        return true;
      },
      err: (_) => false,
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

final selectedCategoryProvider = StateProvider<NoteCategory?>((ref) => null);

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final notes = ref.watch(notesProvider);
  if (category == null) return notes;
  return notes.whenData(
    (list) => list.where((n) => n.category == category).toList(),
  );
});
