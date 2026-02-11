import 'package:uuid/uuid.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/note_file_store.dart';
import '../domain/note.dart';
import '../domain/note_category.dart';

class NoteRepository {
  NoteRepository({NoteFileStore? fileStore})
      : _fileStore = fileStore ?? NoteFileStore();

  final NoteFileStore _fileStore;
  static const _uuid = Uuid();

  Future<Result<List<Note>>> getAllNotes() => _fileStore.loadAll();

  Future<Result<Note>> getNote(String id) => _fileStore.load(id);

  Future<Result<Note>> createNote({
    required String originalText,
    required String rewrittenText,
    required NoteCategory category,
    double confidence = 0.0,
    NoteSource source = NoteSource.text,
    List<String> tags = const [],
    String? customCategory,
    Duration? audioDuration,
  }) async {
    final note = Note(
      id: _uuid.v4(),
      originalText: originalText,
      rewrittenText: rewrittenText,
      category: category,
      confidence: confidence,
      createdAt: DateTime.now(),
      source: source,
      tags: tags,
      customCategory: customCategory,
      audioDuration: audioDuration,
    );
    final result = await _fileStore.save(note);
    return result.when(
      ok: (_) => Ok(note),
      err: (msg) => Err(msg),
    );
  }

  Future<Result<Note>> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    final result = await _fileStore.save(updated);
    return result.when(
      ok: (_) => Ok(updated),
      err: (msg) => Err(msg),
    );
  }

  Future<Result<void>> deleteNote(String id) => _fileStore.delete(id);
}
