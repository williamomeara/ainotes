import 'package:freezed_annotation/freezed_annotation.dart';
import 'note_source.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String originalText,
    required String rewrittenText,
    required int categoryId,
    required String categoryName,
    required double confidence,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> tags,
    @Default(NoteSource.text) NoteSource source,
    Duration? audioDuration,
    @Default(false) bool isDraft,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
