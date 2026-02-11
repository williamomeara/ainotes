import 'package:freezed_annotation/freezed_annotation.dart';
import 'note_category.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String originalText,
    required String rewrittenText,
    required NoteCategory category,
    String? customCategory,
    required double confidence,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> tags,
    @Default(NoteSource.voice) NoteSource source,
    Duration? audioDuration,
    String? filePath,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
