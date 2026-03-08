import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/error/result.dart';
import '../../../core/storage/daos/categories_dao.dart';
import '../../../core/storage/daos/notes_dao.dart';
import '../../../core/storage/database.dart';
import '../domain/note.dart';
import '../domain/note_source.dart';

class NoteRepository {
  NoteRepository({required NotesDao notesDao, required CategoriesDao categoriesDao})
      : _notesDao = notesDao,
        _categoriesDao = categoriesDao;

  final NotesDao _notesDao;
  final CategoriesDao _categoriesDao;
  static const _uuid = Uuid();

  Future<Result<List<Note>>> getAllNotes() async {
    try {
      final rows = await _notesDao.getAll();
      final notes = <Note>[];
      for (final row in rows) {
        final tags = await _notesDao.getTagsForNote(row.note.id);
        notes.add(_toNote(row, tags));
      }
      return Ok(notes);
    } catch (e) {
      return Err('Failed to load notes: $e');
    }
  }

  Future<Result<Note>> getNote(String id) async {
    try {
      final row = await _notesDao.getById(id);
      if (row == null) return Err('Note not found: $id');
      final tags = await _notesDao.getTagsForNote(id);
      return Ok(_toNote(row, tags));
    } catch (e) {
      return Err('Failed to load note: $e');
    }
  }

  Future<Result<Note>> createNote({
    required String originalText,
    required String rewrittenText,
    required String categoryName,
    double confidence = 0.0,
    NoteSource source = NoteSource.text,
    List<String> tags = const [],
    Duration? audioDuration,
    bool isDraft = false,
  }) async {
    try {
      final category = await _categoriesDao.getOrCreateCategory(categoryName);
      final id = _uuid.v4();
      final now = DateTime.now();

      await _notesDao.insert(NotesCompanion.insert(
        id: id,
        originalText: originalText,
        rewrittenText: rewrittenText,
        categoryId: category.id,
        confidence: Value(confidence),
        source: Value(source.name),
        createdAt: Value(now),
        isDraft: Value(isDraft),
        audioDurationSeconds: audioDuration != null
            ? Value(audioDuration.inSeconds)
            : const Value.absent(),
      ));

      if (tags.isNotEmpty) {
        await _notesDao.setTagsForNote(id, tags);
      }

      final note = Note(
        id: id,
        originalText: originalText,
        rewrittenText: rewrittenText,
        categoryId: category.id,
        categoryName: category.name,
        confidence: confidence,
        createdAt: now,
        source: source,
        tags: tags,
        audioDuration: audioDuration,
        isDraft: isDraft,
      );
      return Ok(note);
    } catch (e) {
      return Err('Failed to create note: $e');
    }
  }

  Future<Result<Note>> updateNote(Note note) async {
    try {
      final now = DateTime.now();
      await _notesDao.update(NotesCompanion(
        id: Value(note.id),
        originalText: Value(note.originalText),
        rewrittenText: Value(note.rewrittenText),
        categoryId: Value(note.categoryId),
        confidence: Value(note.confidence),
        source: Value(note.source.name),
        updatedAt: Value(now),
        isDraft: Value(note.isDraft),
        audioDurationSeconds: note.audioDuration != null
            ? Value(note.audioDuration!.inSeconds)
            : const Value.absent(),
      ));

      if (note.tags.isNotEmpty) {
        await _notesDao.setTagsForNote(note.id, note.tags);
      }

      final updated = note.copyWith(updatedAt: now);
      return Ok(updated);
    } catch (e) {
      return Err('Failed to update note: $e');
    }
  }

  Future<Result<void>> deleteNote(String id) async {
    try {
      await _notesDao.deleteById(id);
      return const Ok(null);
    } catch (e) {
      return Err('Failed to delete note: $e');
    }
  }

  Note _toNote(NoteWithCategory row, List<String> tags) {
    return Note(
      id: row.note.id,
      originalText: row.note.originalText,
      rewrittenText: row.note.rewrittenText,
      categoryId: row.note.categoryId,
      categoryName: row.categoryName,
      confidence: row.note.confidence,
      createdAt: row.note.createdAt,
      updatedAt: row.note.updatedAt,
      tags: tags,
      source: NoteSource.values.firstWhere(
        (s) => s.name == row.note.source,
        orElse: () => NoteSource.text,
      ),
      audioDuration: row.note.audioDurationSeconds != null
          ? Duration(seconds: row.note.audioDurationSeconds!)
          : null,
      isDraft: row.note.isDraft,
    );
  }
}
