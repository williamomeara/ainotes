import 'package:drift/drift.dart';
import '../database.dart';

class NoteWithCategory {
  final NoteRow note;
  final String categoryName;
  final String categoryDisplayName;

  const NoteWithCategory({
    required this.note,
    required this.categoryName,
    required this.categoryDisplayName,
  });
}

class NotesDao {
  final AppDatabase _db;

  NotesDao(this._db);

  Future<List<NoteWithCategory>> getAll() async {
    final query = _db.select(_db.notes).join([
      innerJoin(
          _db.categories, _db.categories.id.equalsExp(_db.notes.categoryId)),
    ]);
    query.orderBy([OrderingTerm.desc(_db.notes.createdAt)]);

    final rows = await query.get();
    return rows.map((row) {
      return NoteWithCategory(
        note: row.readTable(_db.notes),
        categoryName: row.readTable(_db.categories).name,
        categoryDisplayName: row.readTable(_db.categories).displayName,
      );
    }).toList();
  }

  Stream<List<NoteWithCategory>> watchAll() {
    final query = _db.select(_db.notes).join([
      innerJoin(
          _db.categories, _db.categories.id.equalsExp(_db.notes.categoryId)),
    ]);
    query.orderBy([OrderingTerm.desc(_db.notes.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return NoteWithCategory(
          note: row.readTable(_db.notes),
          categoryName: row.readTable(_db.categories).name,
          categoryDisplayName: row.readTable(_db.categories).displayName,
        );
      }).toList();
    });
  }

  Future<NoteWithCategory?> getById(String id) async {
    final query = _db.select(_db.notes).join([
      innerJoin(
          _db.categories, _db.categories.id.equalsExp(_db.notes.categoryId)),
    ]);
    query.where(_db.notes.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return NoteWithCategory(
      note: row.readTable(_db.notes),
      categoryName: row.readTable(_db.categories).name,
      categoryDisplayName: row.readTable(_db.categories).displayName,
    );
  }

  Future<void> insert(NotesCompanion note) async {
    await _db.into(_db.notes).insert(note);
  }

  Future<void> update(NotesCompanion note) async {
    await (_db.update(_db.notes)..where((t) => t.id.equals(note.id.value)))
        .write(note);
  }

  Future<void> deleteById(String id) async {
    await (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }

  Future<List<String>> getTagsForNote(String noteId) async {
    final query = _db.select(_db.noteTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.noteTags.tagId)),
    ]);
    query.where(_db.noteTags.noteId.equals(noteId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.tags).name).toList();
  }

  Future<void> setTagsForNote(String noteId, List<String> tagNames) async {
    await (_db.delete(_db.noteTags)
          ..where((t) => t.noteId.equals(noteId)))
        .go();

    for (final name in tagNames) {
      // Try to insert the tag; if it already exists, look it up
      final tagRow = await _db.into(_db.tags).insertReturningOrNull(
            TagsCompanion.insert(name: name),
            mode: InsertMode.insertOrIgnore,
          );
      final resolvedId = tagRow?.id ??
          (await (_db.select(_db.tags)
                    ..where((t) => t.name.equals(name)))
                  .getSingle())
              .id;

      await _db.into(_db.noteTags).insert(
            NoteTagsCompanion.insert(noteId: noteId, tagId: resolvedId),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }
}
