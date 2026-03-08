import 'dart:typed_data';

import 'package:drift/drift.dart';
import '../database.dart';

class ChunkEntry {
  final int id;
  final String noteId;
  final int chunkIndex;
  final String chunkText;
  final Float32List embedding;

  const ChunkEntry({
    required this.id,
    required this.noteId,
    required this.chunkIndex,
    required this.chunkText,
    required this.embedding,
  });
}

class ChunksDao {
  final AppDatabase _db;

  ChunksDao(this._db);

  Future<void> upsertChunk({
    required String noteId,
    required int chunkIndex,
    required String chunkText,
    required List<double> embedding,
  }) async {
    final blob = _toBlob(embedding);
    await _db.into(_db.noteChunks).insertOnConflictUpdate(
          NoteChunksCompanion.insert(
            noteId: noteId,
            chunkIndex: chunkIndex,
            chunkText: chunkText,
            embedding: blob,
          ),
        );
  }

  Future<void> removeNote(String noteId) async {
    await (_db.delete(_db.noteChunks)
          ..where((t) => t.noteId.equals(noteId)))
        .go();
  }

  Future<List<ChunkEntry>> getAll() async {
    final rows = await _db.select(_db.noteChunks).get();
    return rows.map(_toEntry).toList();
  }

  Future<List<ChunkEntry>> getForNote(String noteId) async {
    final rows = await (_db.select(_db.noteChunks)
          ..where((t) => t.noteId.equals(noteId)))
        .get();
    return rows.map(_toEntry).toList();
  }

  Future<int> get chunkCount async {
    final count = _db.noteChunks.id.count();
    final query = _db.selectOnly(_db.noteChunks)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<Set<String>> get noteIds async {
    final query = _db.selectOnly(_db.noteChunks, distinct: true)
      ..addColumns([_db.noteChunks.noteId]);
    final rows = await query.get();
    return rows.map((r) => r.read(_db.noteChunks.noteId)!).toSet();
  }

  ChunkEntry _toEntry(NoteChunkRow row) {
    return ChunkEntry(
      id: row.id,
      noteId: row.noteId,
      chunkIndex: row.chunkIndex,
      chunkText: row.chunkText,
      embedding: _fromBlob(row.embedding),
    );
  }

  static Uint8List _toBlob(List<double> embedding) {
    final float32 = Float32List.fromList(embedding);
    return float32.buffer.asUint8List();
  }

  static Float32List _fromBlob(Uint8List blob) {
    return blob.buffer.asFloat32List();
  }
}
