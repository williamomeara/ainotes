import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_category.dart';
import 'package:ainotes/features/notes/providers/notes_provider.dart';
import 'package:ainotes/features/processing/providers/pipeline_provider.dart';

void main() {
  group('NotesProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('createNote adds a new note', () async {
      final notifier = container.read(notesProvider.notifier);

      final note = await notifier.createNote(
        originalText: 'Buy milk',
        rewrittenText: 'Shopping: milk',
        category: NoteCategory.shopping,
        source: NoteSource.text,
      );

      expect(note, isNotNull);
      expect(note!.originalText, 'Buy milk');
      expect(note.rewrittenText, 'Shopping: milk');
      expect(note.category, NoteCategory.shopping);
    });

    test('updateNote modifies existing note', () async {
      final notifier = container.read(notesProvider.notifier);

      // Create note
      final note = await notifier.createNote(
        originalText: 'Buy milk',
        rewrittenText: 'Shopping: milk',
        category: NoteCategory.shopping,
        source: NoteSource.text,
      );

      // Update note
      final updated = note!.copyWith(
        rewrittenText: 'Shopping: milk, eggs',
      );
      await notifier.updateNote(updated);

      // Verify update
      await notifier.refresh();
      final notes = await container.read(notesProvider.future);
      final found = notes.firstWhere((n) => n.id == note.id);
      expect(found.rewrittenText, 'Shopping: milk, eggs');
    });

    test('deleteNote removes a note', () async {
      final notifier = container.read(notesProvider.notifier);

      // Create note
      final note = await notifier.createNote(
        originalText: 'Test note',
        rewrittenText: 'Test note',
        category: NoteCategory.general,
        source: NoteSource.text,
      );

      // Delete note
      await notifier.deleteNote(note!.id);

      // Verify deletion
      await notifier.refresh();
      final notes = await container.read(notesProvider.future);
      expect(notes.where((n) => n.id == note.id), isEmpty);
    });

    test('refresh loads notes from storage', () async {
      final notifier = container.read(notesProvider.notifier);

      // Create some notes
      await notifier.createNote(
        originalText: 'Note 1',
        rewrittenText: 'Note 1',
        category: NoteCategory.general,
        source: NoteSource.text,
      );
      await notifier.createNote(
        originalText: 'Note 2',
        rewrittenText: 'Note 2',
        category: NoteCategory.todos,
        source: NoteSource.text,
      );

      // Refresh
      await notifier.refresh();

      final notes = await container.read(notesProvider.future);
      expect(notes.length, greaterThanOrEqualTo(2));
    });

    test('filtering by category works', () async {
      final notifier = container.read(notesProvider.notifier);

      // Create notes in different categories
      await notifier.createNote(
        originalText: 'Buy milk',
        rewrittenText: 'Shopping: milk',
        category: NoteCategory.shopping,
        source: NoteSource.text,
      );
      await notifier.createNote(
        originalText: 'Call dentist',
        rewrittenText: 'Todo: call dentist',
        category: NoteCategory.todos,
        source: NoteSource.text,
      );

      await notifier.refresh();
      final allNotes = await container.read(notesProvider.future);

      // Filter shopping notes
      final shoppingNotes = allNotes
          .where((note) => note.category == NoteCategory.shopping)
          .toList();
      expect(shoppingNotes, isNotEmpty);
      expect(shoppingNotes.every((n) => n.category == NoteCategory.shopping),
          true);

      // Filter todos
      final todoNotes = allNotes
          .where((note) => note.category == NoteCategory.todos)
          .toList();
      expect(todoNotes, isNotEmpty);
      expect(todoNotes.every((n) => n.category == NoteCategory.todos), true);
    });

    test('notes are sorted by creation date', () async {
      final notifier = container.read(notesProvider.notifier);

      // Create notes with delays
      final note1 = await notifier.createNote(
        originalText: 'First',
        rewrittenText: 'First',
        category: NoteCategory.general,
        source: NoteSource.text,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      final note2 = await notifier.createNote(
        originalText: 'Second',
        rewrittenText: 'Second',
        category: NoteCategory.general,
        source: NoteSource.text,
      );

      await notifier.refresh();
      final notes = await container.read(notesProvider.future);

      // Should be sorted newest first
      final index1 = notes.indexWhere((n) => n.id == note1!.id);
      final index2 = notes.indexWhere((n) => n.id == note2!.id);
      expect(index2, lessThan(index1));
    });
  });
}
