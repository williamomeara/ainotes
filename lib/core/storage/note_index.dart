import 'package:objectbox/objectbox.dart';

@Entity()
class NoteIndexEntry {
  @Id()
  int obxId = 0;

  @Unique()
  String noteId;

  String category;
  String? customCategory;
  double confidence;
  String source;

  @Property(type: PropertyType.dateNano)
  DateTime createdAt;

  @Property(type: PropertyType.dateNano)
  DateTime? updatedAt;

  String tags; // comma-separated

  /// Full-text search content: rewritten + original
  String searchContent;

  NoteIndexEntry({
    required this.noteId,
    required this.category,
    this.customCategory,
    required this.confidence,
    required this.source,
    required this.createdAt,
    this.updatedAt,
    this.tags = '',
    this.searchContent = '',
  });
}
