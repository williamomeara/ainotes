import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/storage/database.dart';
import 'package:ainotes/core/storage/daos/categories_dao.dart';
import 'package:ainotes/core/storage/daos/notes_dao.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_source.dart';
import 'package:ainotes/features/notes/providers/note_repository.dart';

void main() {
  group('Storage Persistence Integration', () {
    late AppDatabase db;
    late NoteRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = NoteRepository(
        notesDao: NotesDao(db),
        categoriesDao: CategoriesDao(db),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('create note → read back → verify data integrity', () async {
      final result = await repo.createNote(
        originalText: 'Buy milk and eggs',
        rewrittenText: '# Shopping List\n\n- Milk\n- Eggs',
        categoryName: 'shopping',
        confidence: 0.95,
        tags: ['groceries', 'weekly'],
        source: NoteSource.voice,
        audioDuration: const Duration(seconds: 5),
      );

      final note = result.when(ok: (n) => n, err: (_) => null);
      expect(note, isNotNull);
      expect(note!.id, isNotEmpty);
      expect(note.categoryName, 'shopping');
      expect(note.confidence, 0.95);
      expect(note.source, NoteSource.voice);
      expect(note.tags, ['groceries', 'weekly']);
      expect(note.audioDuration, const Duration(seconds: 5));
      expect(note.rewrittenText, contains('# Shopping List'));
      expect(note.originalText, 'Buy milk and eggs');
    });

    test('load note from database → verify data integrity', () async {
      final createResult = await repo.createNote(
        originalText: 'Call dentist tomorrow',
        rewrittenText: 'Todo: Call dentist',
        categoryName: 'todos',
        confidence: 0.88,
        tags: ['health', 'appointment'],
        source: NoteSource.text,
      );

      final originalNote = createResult.when(ok: (n) => n, err: (_) => null)!;

      // Load it back
      final loadResult = await repo.getNote(originalNote.id);
      final loadedNote = loadResult.when(ok: (n) => n, err: (_) => null);

      expect(loadedNote, isNotNull);
      expect(loadedNote!.id, originalNote.id);
      expect(loadedNote.originalText, originalNote.originalText);
      expect(loadedNote.rewrittenText, originalNote.rewrittenText);
      expect(loadedNote.categoryName, originalNote.categoryName);
      expect(loadedNote.confidence, originalNote.confidence);
      expect(loadedNote.tags, originalNote.tags);
      expect(loadedNote.source, originalNote.source);
    });

    test('update note → changes persist', () async {
      final createResult = await repo.createNote(
        originalText: 'Original text',
        rewrittenText: 'Original rewritten',
        categoryName: 'general',
        confidence: 0.75,
        source: NoteSource.text,
      );

      final note = createResult.when(ok: (n) => n, err: (_) => null)!;

      // Update the note
      final updated = note.copyWith(
        rewrittenText: 'Updated rewritten text',
      );
      await repo.updateNote(updated);

      // Load it back
      final loadResult = await repo.getNote(note.id);
      final loaded = loadResult.when(ok: (n) => n, err: (_) => null);

      expect(loaded, isNotNull);
      expect(loaded!.rewrittenText, 'Updated rewritten text');
      expect(loaded.updatedAt, isNotNull);
    });

    test('delete note → note is removed', () async {
      final createResult = await repo.createNote(
        originalText: 'To be deleted',
        rewrittenText: 'To be deleted',
        categoryName: 'general',
        confidence: 0.5,
        source: NoteSource.text,
      );

      final note = createResult.when(ok: (n) => n, err: (_) => null)!;

      await repo.deleteNote(note.id);

      final loadResult = await repo.getNote(note.id);
      final loaded = loadResult.when(ok: (n) => n, err: (_) => null);
      expect(loaded, isNull);
    });

    test('getAllNotes retrieves all saved notes', () async {
      // Create multiple notes
      await repo.createNote(
        originalText: 'Note 1',
        rewrittenText: 'Note 1',
        categoryName: 'general',
        confidence: 0.8,
        source: NoteSource.text,
      );
      await repo.createNote(
        originalText: 'Note 2',
        rewrittenText: 'Note 2',
        categoryName: 'shopping',
        confidence: 0.9,
        source: NoteSource.voice,
      );
      await repo.createNote(
        originalText: 'Note 3',
        rewrittenText: 'Note 3',
        categoryName: 'todos',
        confidence: 0.85,
        source: NoteSource.text,
      );

      final allResult = await repo.getAllNotes();
      final loaded = allResult.when(ok: (n) => n, err: (_) => <Note>[]);

      expect(loaded.length, 3);
    });

    test('special characters in text are properly handled', () async {
      final createResult = await repo.createNote(
        originalText: 'Text with "quotes" and \'apostrophes\' and #hashtags',
        rewrittenText: 'Text with **bold** and _italic_',
        categoryName: 'general',
        confidence: 0.9,
        source: NoteSource.text,
      );

      final note = createResult.when(ok: (n) => n, err: (_) => null)!;

      final loadResult = await repo.getNote(note.id);
      final loaded = loadResult.when(ok: (n) => n, err: (_) => null);

      expect(loaded, isNotNull);
      expect(loaded!.originalText, note.originalText);
      expect(loaded.rewrittenText, note.rewrittenText);
    });

    test('empty tags list is handled correctly', () async {
      final createResult = await repo.createNote(
        originalText: 'Note without tags',
        rewrittenText: 'Note without tags',
        categoryName: 'general',
        confidence: 0.7,
        tags: [],
        source: NoteSource.text,
      );

      final note = createResult.when(ok: (n) => n, err: (_) => null)!;

      final loadResult = await repo.getNote(note.id);
      final loaded = loadResult.when(ok: (n) => n, err: (_) => null);

      expect(loaded, isNotNull);
      expect(loaded!.tags, isEmpty);
    });

    test('multiline text preserves line breaks', () async {
      final createResult = await repo.createNote(
        originalText: 'Line 1\nLine 2\nLine 3',
        rewrittenText: '# Title\n\nParagraph 1\n\nParagraph 2',
        categoryName: 'general',
        confidence: 0.8,
        source: NoteSource.text,
      );

      final note = createResult.when(ok: (n) => n, err: (_) => null)!;

      final loadResult = await repo.getNote(note.id);
      final loaded = loadResult.when(ok: (n) => n, err: (_) => null);

      expect(loaded, isNotNull);
      expect(loaded!.originalText, 'Line 1\nLine 2\nLine 3');
      expect(loaded.rewrittenText, contains('\n\n'));
    });
  });
}
