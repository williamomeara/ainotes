import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/features/notes/domain/note.dart';
import 'package:ainotes/features/notes/domain/note_source.dart';

void main() {
  group('Note', () {
    test('creates with required fields', () {
      final note = Note(
        id: 'test-1',
        originalText: 'um get milk',
        rewrittenText: 'Buy milk',
        categoryId: 1,
        categoryName: 'shopping',
        confidence: 0.92,
        createdAt: DateTime(2026, 2, 11),
      );

      expect(note.id, 'test-1');
      expect(note.categoryName, 'shopping');
      expect(note.categoryId, 1);
      expect(note.tags, isEmpty);
      expect(note.source, NoteSource.text);
    });

    test('copyWith works', () {
      final note = Note(
        id: 'test-1',
        originalText: 'original',
        rewrittenText: 'rewritten',
        categoryId: 4,
        categoryName: 'general',
        confidence: 0.5,
        createdAt: DateTime(2026, 2, 11),
      );

      final updated = note.copyWith(categoryId: 3, categoryName: 'ideas');
      expect(updated.categoryName, 'ideas');
      expect(updated.categoryId, 3);
      expect(updated.id, 'test-1');
    });

    test('serialization roundtrip', () {
      final note = Note(
        id: 'test-1',
        originalText: 'original',
        rewrittenText: 'rewritten',
        categoryId: 2,
        categoryName: 'todos',
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
