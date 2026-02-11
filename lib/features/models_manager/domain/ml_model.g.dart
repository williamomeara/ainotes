// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ml_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MLModelImpl _$$MLModelImplFromJson(Map<String, dynamic> json) =>
    _$MLModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$MLModelTypeEnumMap, json['type']),
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      downloadUrl: json['downloadUrl'] as String?,
      localPath: json['localPath'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
    );

Map<String, dynamic> _$$MLModelImplToJson(_$MLModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$MLModelTypeEnumMap[instance.type]!,
      'sizeBytes': instance.sizeBytes,
      'downloadUrl': instance.downloadUrl,
      'localPath': instance.localPath,
      'isDownloaded': instance.isDownloaded,
      'isActive': instance.isActive,
    };

const _$MLModelTypeEnumMap = {
  MLModelType.stt: 'stt',
  MLModelType.llm: 'llm',
  MLModelType.embedding: 'embedding',
};
