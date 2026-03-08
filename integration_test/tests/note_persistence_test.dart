import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ainotes/core/storage/note_file_store.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_source.dart';

/// Register note persistence (file store) tests.
///
/// These run on-device and exercise the real filesystem.
void registerNotePersistenceTests() {
  group('Note Persistence', () {
    late NoteFileStore store;
    final createdIds = <String>[];

    setUp(() {
      store = NoteFileStore();
    });

    tearDown(() async {
      // Clean up test notes
      for (final id in createdIds) {
        await store.delete(id);
      }
      createdIds.clear();
    });

    test('save and load round-trip preserves all fields', () async {
      final note = Note(
        id: 'itest-roundtrip-001',
        originalText: 'um so like I need to buy milk and eggs',
        rewrittenText: 'Buy milk and eggs.',
        categoryId: 1,
        categoryName: 'shopping',
        confidence: 0.92,
        createdAt: DateTime(2026, 2, 27, 10, 30),
        updatedAt: DateTime(2026, 2, 27, 11, 0),
        tags: ['groceries', 'weekly'],
        source: NoteSource.voice,
        audioDuration: const Duration(seconds: 12),
      );
      createdIds.add(note.id);

      // Save
      final saveResult = await store.save(note);
      expect(saveResult.isOk, isTrue, reason: 'Save should succeed');

      // Load
      final loadResult = await store.load(note.id);
      expect(loadResult.isOk, isTrue, reason: 'Load should succeed');

      final loaded = loadResult.value;
      expect(loaded.id, equals(note.id));
      expect(loaded.originalText, equals(note.originalText));
      expect(loaded.rewrittenText, equals(note.rewrittenText));
      expect(loaded.categoryName, equals('shopping'));
      expect(loaded.confidence, equals(0.92));
      expect(loaded.source, equals(NoteSource.voice));
      expect(loaded.tags, containsAll(['groceries', 'weekly']));
      expect(loaded.audioDuration?.inSeconds, equals(12));
    });

    test('raw markdown file has correct YAML frontmatter', () async {
      final note = Note(
        id: 'itest-yaml-002',
        originalText: 'raw original text',
        rewrittenText: 'Clean rewritten text.',
        categoryId: 4,
        categoryName: 'ideas',
        confidence: 0.85,
        createdAt: DateTime(2026, 2, 27, 12, 0),
        tags: ['creative', 'app'],
        source: NoteSource.text,
      );
      createdIds.add(note.id);

      await store.save(note);

      // Read the raw file
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/notes/${note.id}.md';
      final rawContent = await File(filePath).readAsString();

      expect(rawContent, contains('---'));
      expect(rawContent, contains('id: itest-yaml-002'));
      expect(rawContent, contains('category: ideas'));
      expect(rawContent, contains('confidence: 0.85'));
      expect(rawContent, contains('source: text'));
      expect(rawContent, contains('tags: [creative, app]'));
      expect(rawContent, contains('Clean rewritten text.'));
      expect(rawContent, contains('<!-- original -->'));
      expect(rawContent, contains('raw original text'));
    });

    test('loadAll returns notes sorted by createdAt descending', () async {
      final noteA = Note(
        id: 'itest-sort-a',
        originalText: 'older note',
        rewrittenText: 'Older note.',
        categoryId: 0,
        categoryName: 'general',
        confidence: 0.7,
        createdAt: DateTime(2026, 2, 25),
        source: NoteSource.text,
      );
      final noteB = Note(
        id: 'itest-sort-b',
        originalText: 'newer note',
        rewrittenText: 'Newer note.',
        categoryId: 0,
        categoryName: 'general',
        confidence: 0.8,
        createdAt: DateTime(2026, 2, 27),
        source: NoteSource.text,
      );
      createdIds.addAll([noteA.id, noteB.id]);

      await store.save(noteA);
      await store.save(noteB);

      final result = await store.loadAll();
      expect(result.isOk, isTrue);

      final notes = result.value;
      // Find our test notes in the full list
      final testNotes =
          notes.where((n) => n.id.startsWith('itest-sort-')).toList();
      expect(testNotes.length, equals(2));
      // Newer should come first (descending)
      expect(testNotes.first.id, equals('itest-sort-b'));
      expect(testNotes.last.id, equals('itest-sort-a'));
    });

    test('delete removes the note file', () async {
      final note = Note(
        id: 'itest-delete-003',
        originalText: 'to be deleted',
        rewrittenText: 'To be deleted.',
        categoryId: 0,
        categoryName: 'general',
        confidence: 0.5,
        createdAt: DateTime.now(),
        source: NoteSource.text,
      );
      // Don't add to createdIds — we'll delete it ourselves

      await store.save(note);
      final loadBefore = await store.load(note.id);
      expect(loadBefore.isOk, isTrue, reason: 'Note should exist before delete');

      await store.delete(note.id);
      final loadAfter = await store.load(note.id);
      expect(loadAfter.isErr, isTrue, reason: 'Note should not exist after delete');
    });
  });
}
