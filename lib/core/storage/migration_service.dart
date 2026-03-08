import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daos/categories_dao.dart';
import 'daos/notes_dao.dart';
import 'database.dart';
import 'note_file_store.dart';

class MigrationService {
  final AppDatabase _db;
  final NoteFileStore _fileStore;

  MigrationService(this._db) : _fileStore = NoteFileStore();

  static const _migrationKey = 'storage_migrated_v2';

  static Future<bool> needsMigration() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_migrationKey) ?? false);
  }

  Future<void> migrate() async {
    debugPrint('[AiNotes] Migration: starting .md -> SQLite migration');

    final categoriesDao = CategoriesDao(_db);
    final notesDao = NotesDao(_db);

    final result = await _fileStore.loadAll();
    final notes = result.when(
      ok: (notes) => notes,
      err: (msg) {
        debugPrint('[AiNotes] Migration: failed to load notes: $msg');
        return <dynamic>[];
      },
    );

    if (notes.isEmpty) {
      debugPrint('[AiNotes] Migration: no notes to migrate');
      await _markComplete();
      return;
    }

    debugPrint('[AiNotes] Migration: migrating ${notes.length} notes');
    var migrated = 0;

    for (final note in notes) {
      try {
        final category =
            await categoriesDao.getOrCreateCategory(note.categoryName);

        await notesDao.insert(NotesCompanion.insert(
          id: note.id,
          originalText: note.originalText,
          rewrittenText: note.rewrittenText,
          categoryId: category.id,
          confidence: Value(note.confidence),
          source: Value(note.source.name),
          createdAt: Value(note.createdAt),
          updatedAt: note.updatedAt != null
              ? Value(note.updatedAt!)
              : const Value.absent(),
          audioDurationSeconds: note.audioDuration != null
              ? Value(note.audioDuration!.inSeconds)
              : const Value.absent(),
        ));

        if (note.tags.isNotEmpty) {
          await notesDao.setTagsForNote(note.id, note.tags);
        }

        migrated++;
      } catch (e) {
        debugPrint('[AiNotes] Migration: failed to migrate note ${note.id}: $e');
      }
    }

    debugPrint('[AiNotes] Migration: migrated $migrated/${notes.length} notes');

    // Rename old notes directory as backup
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final notesDir = Directory('${appDir.path}/notes');
      if (await notesDir.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await notesDir.rename('${appDir.path}/notes_backup_$timestamp');
        debugPrint('[AiNotes] Migration: old notes directory renamed');
      }
    } catch (e) {
      debugPrint('[AiNotes] Migration: failed to rename notes dir: $e');
    }

    await _markComplete();
    debugPrint('[AiNotes] Migration: complete');
  }

  Future<void> _markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationKey, true);
  }
}
