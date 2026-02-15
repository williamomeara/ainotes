import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:ainotes/core/storage/note_file_store.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_category.dart';

void main() {
  group('Storage Persistence Integration', () {
    late NoteFileStore store;
    late Directory testDir;

    setUp(() async {
      // Set up temporary test directory
      testDir = await Directory.systemTemp.createTemp('ainotes_test_');
      store = NoteFileStore(notesDirectory: testDir.path);
    });

    tearDown(() async {
      // Clean up test directory
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    test('save note → read .md file → verify YAML frontmatter + markdown content',
        () async {
      final note = Note(
        id: 'test-note-123',
        originalText: 'Buy milk and eggs',
        rewrittenText: '# Shopping List\n\n- Milk\n- Eggs',
        category: NoteCategory.shopping,
        confidence: 0.95,
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 30),
        tags: ['groceries', 'weekly'],
        source: NoteSource.voice,
        audioDuration: const Duration(seconds: 5),
      );

      await store.saveNote(note);

      // Read the .md file
      final file = File('${testDir.path}/${note.id}.md');
      expect(await file.exists(), true);

      final content = await file.readAsString();

      // Verify YAML frontmatter
      expect(content, contains('---'));
      expect(content, contains('id: test-note-123'));
      expect(content, contains('category: shopping'));
      expect(content, contains('confidence: 0.95'));
      expect(content, contains('source: voice'));
      expect(content, contains('tags:'));
      expect(content, contains('- groceries'));
      expect(content, contains('- weekly'));
      expect(content, contains('audio_duration: 5'));

      // Verify markdown content
      expect(content, contains('# Shopping List'));
      expect(content, contains('- Milk'));
      expect(content, contains('- Eggs'));

      // Verify original text section
      expect(content, contains('<!-- original -->'));
      expect(content, contains('Buy milk and eggs'));
    });

    test('load note from disk → verify data integrity', () async {
      final originalNote = Note(
        id: 'test-note-456',
        originalText: 'Call dentist tomorrow',
        rewrittenText: 'Todo: Call dentist',
        category: NoteCategory.todos,
        confidence: 0.88,
        createdAt: DateTime(2024, 1, 15, 14, 0),
        tags: ['health', 'appointment'],
        source: NoteSource.text,
      );

      await store.saveNote(originalNote);

      // Load it back
      final loadedNote = await store.loadNote(originalNote.id);

      expect(loadedNote, isNotNull);
      expect(loadedNote!.id, originalNote.id);
      expect(loadedNote.originalText, originalNote.originalText);
      expect(loadedNote.rewrittenText, originalNote.rewrittenText);
      expect(loadedNote.category, originalNote.category);
      expect(loadedNote.confidence, originalNote.confidence);
      expect(loadedNote.tags, originalNote.tags);
      expect(loadedNote.source, originalNote.source);
    });

    test('update note → changes persist to disk', () async {
      final note = Note(
        id: 'test-note-789',
        originalText: 'Original text',
        rewrittenText: 'Original rewritten',
        category: NoteCategory.general,
        confidence: 0.75,
        createdAt: DateTime.now(),
        source: NoteSource.text,
      );

      await store.saveNote(note);

      // Update the note
      final updated = note.copyWith(
        rewrittenText: 'Updated rewritten text',
        updatedAt: DateTime.now(),
      );
      await store.saveNote(updated);

      // Load it back
      final loaded = await store.loadNote(note.id);

      expect(loaded, isNotNull);
      expect(loaded!.rewrittenText, 'Updated rewritten text');
      expect(loaded.updatedAt, isNotNull);
    });

    test('delete note → .md file is removed', () async {
      final note = Note(
        id: 'test-note-delete',
        originalText: 'To be deleted',
        rewrittenText: 'To be deleted',
        category: NoteCategory.general,
        confidence: 0.5,
        createdAt: DateTime.now(),
        source: NoteSource.text,
      );

      await store.saveNote(note);

      final file = File('${testDir.path}/${note.id}.md');
      expect(await file.exists(), true);

      await store.deleteNote(note.id);

      expect(await file.exists(), false);
    });

    test('loadAllNotes retrieves all saved notes', () async {
      // Create multiple notes
      final notes = [
        Note(
          id: 'note-1',
          originalText: 'Note 1',
          rewrittenText: 'Note 1',
          category: NoteCategory.general,
          confidence: 0.8,
          createdAt: DateTime.now(),
          source: NoteSource.text,
        ),
        Note(
          id: 'note-2',
          originalText: 'Note 2',
          rewrittenText: 'Note 2',
          category: NoteCategory.shopping,
          confidence: 0.9,
          createdAt: DateTime.now(),
          source: NoteSource.voice,
        ),
        Note(
          id: 'note-3',
          originalText: 'Note 3',
          rewrittenText: 'Note 3',
          category: NoteCategory.todos,
          confidence: 0.85,
          createdAt: DateTime.now(),
          source: NoteSource.text,
        ),
      ];

      for (final note in notes) {
        await store.saveNote(note);
      }

      final loaded = await store.loadAllNotes();

      expect(loaded.length, 3);
      expect(loaded.map((n) => n.id).toSet(), {'note-1', 'note-2', 'note-3'});
    });

    test('special characters in text are properly escaped', () async {
      final note = Note(
        id: 'special-chars',
        originalText: 'Text with "quotes" and \'apostrophes\' and #hashtags',
        rewrittenText: 'Text with **bold** and _italic_',
        category: NoteCategory.general,
        confidence: 0.9,
        createdAt: DateTime.now(),
        source: NoteSource.text,
      );

      await store.saveNote(note);

      final loaded = await store.loadNote(note.id);

      expect(loaded, isNotNull);
      expect(loaded!.originalText, note.originalText);
      expect(loaded.rewrittenText, note.rewrittenText);
    });

    test('empty tags list is handled correctly', () async {
      final note = Note(
        id: 'no-tags',
        originalText: 'Note without tags',
        rewrittenText: 'Note without tags',
        category: NoteCategory.general,
        confidence: 0.7,
        createdAt: DateTime.now(),
        tags: [],
        source: NoteSource.text,
      );

      await store.saveNote(note);

      final loaded = await store.loadNote(note.id);

      expect(loaded, isNotNull);
      expect(loaded!.tags, isEmpty);
    });

    test('multiline text preserves line breaks', () async {
      final note = Note(
        id: 'multiline',
        originalText: 'Line 1\nLine 2\nLine 3',
        rewrittenText: '# Title\n\nParagraph 1\n\nParagraph 2',
        category: NoteCategory.general,
        confidence: 0.8,
        createdAt: DateTime.now(),
        source: NoteSource.text,
      );

      await store.saveNote(note);

      final loaded = await store.loadNote(note.id);

      expect(loaded, isNotNull);
      expect(loaded!.originalText, 'Line 1\nLine 2\nLine 3');
      expect(loaded.rewrittenText, contains('\n\n'));
    });
  });
}
