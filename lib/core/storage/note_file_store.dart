import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import '../../features/notes/domain/note.dart';
import '../../features/notes/domain/note_category.dart';
import '../constants.dart';
import '../error/result.dart';

class NoteFileStore {
  String? _notesDir;

  Future<String> get notesDirectory async {
    if (_notesDir != null) return _notesDir!;
    final appDir = await getApplicationDocumentsDirectory();
    _notesDir = '${appDir.path}/${AppConstants.notesDirectoryName}';
    await Directory(_notesDir!).create(recursive: true);
    return _notesDir!;
  }

  Future<Result<void>> save(Note note) async {
    try {
      final dir = await notesDirectory;
      final file = File('$dir/${note.id}.md');
      final content = _noteToMarkdown(note);
      await file.writeAsString(content);
      return const Ok(null);
    } catch (e) {
      return Err('Failed to save note: $e');
    }
  }

  Future<Result<Note>> load(String id) async {
    try {
      final dir = await notesDirectory;
      final file = File('$dir/$id.md');
      if (!await file.exists()) return Err('Note not found: $id');
      final content = await file.readAsString();
      return Ok(_markdownToNote(id, content));
    } catch (e) {
      return Err('Failed to load note: $e');
    }
  }

  Future<Result<List<Note>>> loadAll() async {
    try {
      final dir = await notesDirectory;
      final directory = Directory(dir);
      if (!await directory.exists()) return const Ok([]);

      final notes = <Note>[];
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.md')) {
          final id = entity.uri.pathSegments.last.replaceAll('.md', '');
          final content = await entity.readAsString();
          notes.add(_markdownToNote(id, content));
        }
      }
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Ok(notes);
    } catch (e) {
      return Err('Failed to load notes: $e');
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      final dir = await notesDirectory;
      final file = File('$dir/$id.md');
      if (await file.exists()) await file.delete();
      return const Ok(null);
    } catch (e) {
      return Err('Failed to delete note: $e');
    }
  }

  String _noteToMarkdown(Note note) {
    final buf = StringBuffer();
    buf.writeln('---');
    buf.writeln('id: ${note.id}');
    buf.writeln('category: ${note.category.name}');
    if (note.customCategory != null) {
      buf.writeln('custom_category: ${note.customCategory}');
    }
    buf.writeln('confidence: ${note.confidence}');
    buf.writeln('source: ${note.source.name}');
    buf.writeln('created: ${note.createdAt.toIso8601String()}');
    if (note.updatedAt != null) {
      buf.writeln('updated: ${note.updatedAt!.toIso8601String()}');
    }
    if (note.tags.isNotEmpty) {
      buf.writeln('tags: [${note.tags.join(', ')}]');
    }
    if (note.audioDuration != null) {
      buf.writeln('audio_duration: ${note.audioDuration!.inSeconds}s');
    }
    buf.writeln('---');
    buf.writeln();
    buf.writeln(note.rewrittenText);
    buf.writeln();
    buf.writeln('---');
    buf.writeln('<!-- original -->');
    buf.writeln(note.originalText);
    return buf.toString();
  }

  Note _markdownToNote(String id, String content) {
    final parts = content.split('---');
    // parts[0] is empty (before first ---), parts[1] is YAML, parts[2+] is body
    final yamlStr = parts.length > 1 ? parts[1].trim() : '';
    final meta = yamlStr.isNotEmpty ? loadYaml(yamlStr) as YamlMap : YamlMap();

    final bodyParts = parts.length > 2 ? parts.sublist(2).join('---') : '';
    final originalMarker = '<!-- original -->';
    final markerIndex = bodyParts.indexOf(originalMarker);

    String rewritten;
    String original;
    if (markerIndex != -1) {
      rewritten = bodyParts.substring(0, markerIndex).trim();
      original =
          bodyParts.substring(markerIndex + originalMarker.length).trim();
    } else {
      rewritten = bodyParts.trim();
      original = '';
    }

    return Note(
      id: meta['id']?.toString() ?? id,
      originalText: original,
      rewrittenText: rewritten,
      category: NoteCategory.values.firstWhere(
        (c) => c.name == meta['category']?.toString(),
        orElse: () => NoteCategory.general,
      ),
      customCategory: meta['custom_category']?.toString(),
      confidence: (meta['confidence'] as num?)?.toDouble() ?? 0.0,
      source: NoteSource.values.firstWhere(
        (s) => s.name == meta['source']?.toString(),
        orElse: () => NoteSource.text,
      ),
      createdAt: DateTime.tryParse(meta['created']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: meta['updated'] != null
          ? DateTime.tryParse(meta['updated'].toString())
          : null,
      tags: (meta['tags'] as YamlList?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      audioDuration: meta['audio_duration'] != null
          ? Duration(
              seconds: int.tryParse(
                      meta['audio_duration'].toString().replaceAll('s', '')) ??
                  0)
          : null,
      filePath: '$id.md',
    );
  }
}
