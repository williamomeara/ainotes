// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteImpl _$$NoteImplFromJson(Map<String, dynamic> json) => _$NoteImpl(
  id: json['id'] as String,
  originalText: json['originalText'] as String,
  rewrittenText: json['rewrittenText'] as String,
  category: $enumDecode(_$NoteCategoryEnumMap, json['category']),
  customCategory: json['customCategory'] as String?,
  confidence: (json['confidence'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  source:
      $enumDecodeNullable(_$NoteSourceEnumMap, json['source']) ??
      NoteSource.voice,
  audioDuration: json['audioDuration'] == null
      ? null
      : Duration(microseconds: (json['audioDuration'] as num).toInt()),
  filePath: json['filePath'] as String?,
);

Map<String, dynamic> _$$NoteImplToJson(_$NoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originalText': instance.originalText,
      'rewrittenText': instance.rewrittenText,
      'category': _$NoteCategoryEnumMap[instance.category]!,
      'customCategory': instance.customCategory,
      'confidence': instance.confidence,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'tags': instance.tags,
      'source': _$NoteSourceEnumMap[instance.source]!,
      'audioDuration': instance.audioDuration?.inMicroseconds,
      'filePath': instance.filePath,
    };

const _$NoteCategoryEnumMap = {
  NoteCategory.shopping: 'shopping',
  NoteCategory.todos: 'todos',
  NoteCategory.ideas: 'ideas',
  NoteCategory.general: 'general',
};

const _$NoteSourceEnumMap = {
  NoteSource.voice: 'voice',
  NoteSource.text: 'text',
  NoteSource.photo: 'photo',
  NoteSource.document: 'document',
  NoteSource.webClip: 'webClip',
};
