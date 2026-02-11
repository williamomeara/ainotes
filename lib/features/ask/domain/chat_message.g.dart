// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserMessageImpl _$$UserMessageImplFromJson(Map<String, dynamic> json) =>
    _$UserMessageImpl(
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$UserMessageImplToJson(_$UserMessageImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'runtimeType': instance.$type,
    };

_$AiMessageImpl _$$AiMessageImplFromJson(Map<String, dynamic> json) =>
    _$AiMessageImpl(
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sourceNoteIds:
          (json['sourceNoteIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$AiMessageImplToJson(_$AiMessageImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'sourceNoteIds': instance.sourceNoteIds,
      'runtimeType': instance.$type,
    };
