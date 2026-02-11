import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_category.dart';

void main() {
  group('Note', () {
    test('creates with required fields', () {
      final note = Note(
        id: 'test-1',
        originalText: 'um get milk',
        rewrittenText: 'Buy milk',
        category: NoteCategory.shopping,
        confidence: 0.92,
        createdAt: DateTime(2026, 2, 11),
      );

      expect(note.id, 'test-1');
      expect(note.category, NoteCategory.shopping);
      expect(note.tags, isEmpty);
      expect(note.source, NoteSource.voice);
    });

    test('copyWith works', () {
      final note = Note(
        id: 'test-1',
        originalText: 'original',
        rewrittenText: 'rewritten',
        category: NoteCategory.general,
        confidence: 0.5,
        createdAt: DateTime(2026, 2, 11),
      );

      final updated = note.copyWith(category: NoteCategory.ideas);
      expect(updated.category, NoteCategory.ideas);
      expect(updated.id, 'test-1');
    });

    test('serialization roundtrip', () {
      final note = Note(
        id: 'test-1',
        originalText: 'original',
        rewrittenText: 'rewritten',
        category: NoteCategory.todos,
        confidence: 0.8,
        createdAt: DateTime(2026, 2, 11),
        tags: ['urgent'],
      );

      final json = note.toJson();
      final restored = Note.fromJson(json);
      expect(restored, note);
    });
  });
}
