// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ml_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MLModel _$MLModelFromJson(Map<String, dynamic> json) {
  return _MLModel.fromJson(json);
}

/// @nodoc
mixin _$MLModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  MLModelType get type => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  String? get downloadUrl => throw _privateConstructorUsedError;
  String? get localPath => throw _privateConstructorUsedError;
  bool get isDownloaded => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this MLModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MLModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MLModelCopyWith<MLModel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MLModelCopyWith<$Res> {
  factory $MLModelCopyWith(MLModel value, $Res Function(MLModel) then) =
      _$MLModelCopyWithImpl<$Res, MLModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    MLModelType type,
    int sizeBytes,
    String? downloadUrl,
    String? localPath,
    bool isDownloaded,
    bool isActive,
  });
}

/// @nodoc
class _$MLModelCopyWithImpl<$Res, $Val extends MLModel>
    implements $MLModelCopyWith<$Res> {
  _$MLModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MLModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? sizeBytes = null,
    Object? downloadUrl = freezed,
    Object? localPath = freezed,
    Object? isDownloaded = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MLModelType,
            sizeBytes: null == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            downloadUrl: freezed == downloadUrl
                ? _value.downloadUrl
                : downloadUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            localPath: freezed == localPath
                ? _value.localPath
                : localPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDownloaded: null == isDownloaded
                ? _value.isDownloaded
                : isDownloaded // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MLModelImplCopyWith<$Res> implements $MLModelCopyWith<$Res> {
  factory _$$MLModelImplCopyWith(
    _$MLModelImpl value,
    $Res Function(_$MLModelImpl) then,
  ) = __$$MLModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    MLModelType type,
    int sizeBytes,
    String? downloadUrl,
    String? localPath,
    bool isDownloaded,
    bool isActive,
  });
}

/// @nodoc
class __$$MLModelImplCopyWithImpl<$Res>
    extends _$MLModelCopyWithImpl<$Res, _$MLModelImpl>
    implements _$$MLModelImplCopyWith<$Res> {
  __$$MLModelImplCopyWithImpl(
    _$MLModelImpl _value,
    $Res Function(_$MLModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MLModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? sizeBytes = null,
    Object? downloadUrl = freezed,
    Object? localPath = freezed,
    Object? isDownloaded = null,
    Object? isActive = null,
  }) {
    return _then(
      _$MLModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MLModelType,
        sizeBytes: null == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        downloadUrl: freezed == downloadUrl
            ? _value.downloadUrl
            : downloadUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        localPath: freezed == localPath
            ? _value.localPath
            : localPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDownloaded: null == isDownloaded
            ? _value.isDownloaded
            : isDownloaded // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MLModelImpl implements _MLModel {
  const _$MLModelImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.sizeBytes,
    this.downloadUrl,
    this.localPath,
    this.isDownloaded = false,
    this.isActive = false,
  });

  factory _$MLModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MLModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final MLModelType type;
  @override
  final int sizeBytes;
  @override
  final String? downloadUrl;
  @override
  final String? localPath;
  @override
  @JsonKey()
  final bool isDownloaded;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'MLModel(id: $id, name: $name, description: $description, type: $type, sizeBytes: $sizeBytes, downloadUrl: $downloadUrl, localPath: $localPath, isDownloaded: $isDownloaded, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MLModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    type,
    sizeBytes,
    downloadUrl,
    localPath,
    isDownloaded,
    isActive,
  );

  /// Create a copy of MLModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MLModelImplCopyWith<_$MLModelImpl> get copyWith =>
      __$$MLModelImplCopyWithImpl<_$MLModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MLModelImplToJson(this);
  }
}

abstract class _MLModel implements MLModel {
  const factory _MLModel({
    required final String id,
    required final String name,
    required final String description,
    required final MLModelType type,
    required final int sizeBytes,
    final String? downloadUrl,
    final String? localPath,
    final bool isDownloaded,
    final bool isActive,
  }) = _$MLModelImpl;

  factory _MLModel.fromJson(Map<String, dynamic> json) = _$MLModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  MLModelType get type;
  @override
  int get sizeBytes;
  @override
  String? get downloadUrl;
  @override
  String? get localPath;
  @override
  bool get isDownloaded;
  @override
  bool get isActive;

  /// Create a copy of MLModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MLModelImplCopyWith<_$MLModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
