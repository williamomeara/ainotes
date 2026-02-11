// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Note _$NoteFromJson(Map<String, dynamic> json) {
  return _Note.fromJson(json);
}

/// @nodoc
mixin _$Note {
  String get id => throw _privateConstructorUsedError;
  String get originalText => throw _privateConstructorUsedError;
  String get rewrittenText => throw _privateConstructorUsedError;
  NoteCategory get category => throw _privateConstructorUsedError;
  String? get customCategory => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  NoteSource get source => throw _privateConstructorUsedError;
  Duration? get audioDuration => throw _privateConstructorUsedError;
  String? get filePath => throw _privateConstructorUsedError;

  /// Serializes this Note to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteCopyWith<Note> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteCopyWith<$Res> {
  factory $NoteCopyWith(Note value, $Res Function(Note) then) =
      _$NoteCopyWithImpl<$Res, Note>;
  @useResult
  $Res call({
    String id,
    String originalText,
    String rewrittenText,
    NoteCategory category,
    String? customCategory,
    double confidence,
    DateTime createdAt,
    DateTime? updatedAt,
    List<String> tags,
    NoteSource source,
    Duration? audioDuration,
    String? filePath,
  });
}

/// @nodoc
class _$NoteCopyWithImpl<$Res, $Val extends Note>
    implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalText = null,
    Object? rewrittenText = null,
    Object? category = null,
    Object? customCategory = freezed,
    Object? confidence = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? tags = null,
    Object? source = null,
    Object? audioDuration = freezed,
    Object? filePath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            originalText: null == originalText
                ? _value.originalText
                : originalText // ignore: cast_nullable_to_non_nullable
                      as String,
            rewrittenText: null == rewrittenText
                ? _value.rewrittenText
                : rewrittenText // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as NoteCategory,
            customCategory: freezed == customCategory
                ? _value.customCategory
                : customCategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as NoteSource,
            audioDuration: freezed == audioDuration
                ? _value.audioDuration
                : audioDuration // ignore: cast_nullable_to_non_nullable
                      as Duration?,
            filePath: freezed == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoteImplCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$$NoteImplCopyWith(
    _$NoteImpl value,
    $Res Function(_$NoteImpl) then,
  ) = __$$NoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String originalText,
    String rewrittenText,
    NoteCategory category,
    String? customCategory,
    double confidence,
    DateTime createdAt,
    DateTime? updatedAt,
    List<String> tags,
    NoteSource source,
    Duration? audioDuration,
    String? filePath,
  });
}

/// @nodoc
class __$$NoteImplCopyWithImpl<$Res>
    extends _$NoteCopyWithImpl<$Res, _$NoteImpl>
    implements _$$NoteImplCopyWith<$Res> {
  __$$NoteImplCopyWithImpl(_$NoteImpl _value, $Res Function(_$NoteImpl) _then)
    : super(_value, _then);

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalText = null,
    Object? rewrittenText = null,
    Object? category = null,
    Object? customCategory = freezed,
    Object? confidence = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? tags = null,
    Object? source = null,
    Object? audioDuration = freezed,
    Object? filePath = freezed,
  }) {
    return _then(
      _$NoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        originalText: null == originalText
            ? _value.originalText
            : originalText // ignore: cast_nullable_to_non_nullable
                  as String,
        rewrittenText: null == rewrittenText
            ? _value.rewrittenText
            : rewrittenText // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as NoteCategory,
        customCategory: freezed == customCategory
            ? _value.customCategory
            : customCategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as NoteSource,
        audioDuration: freezed == audioDuration
            ? _value.audioDuration
            : audioDuration // ignore: cast_nullable_to_non_nullable
                  as Duration?,
        filePath: freezed == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoteImpl implements _Note {
  const _$NoteImpl({
    required this.id,
    required this.originalText,
    required this.rewrittenText,
    required this.category,
    this.customCategory,
    required this.confidence,
    required this.createdAt,
    this.updatedAt,
    final List<String> tags = const [],
    this.source = NoteSource.voice,
    this.audioDuration,
    this.filePath,
  }) : _tags = tags;

  factory _$NoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoteImplFromJson(json);

  @override
  final String id;
  @override
  final String originalText;
  @override
  final String rewrittenText;
  @override
  final NoteCategory category;
  @override
  final String? customCategory;
  @override
  final double confidence;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final NoteSource source;
  @override
  final Duration? audioDuration;
  @override
  final String? filePath;

  @override
  String toString() {
    return 'Note(id: $id, originalText: $originalText, rewrittenText: $rewrittenText, category: $category, customCategory: $customCategory, confidence: $confidence, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, source: $source, audioDuration: $audioDuration, filePath: $filePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.originalText, originalText) ||
                other.originalText == originalText) &&
            (identical(other.rewrittenText, rewrittenText) ||
                other.rewrittenText == rewrittenText) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.customCategory, customCategory) ||
                other.customCategory == customCategory) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.audioDuration, audioDuration) ||
                other.audioDuration == audioDuration) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    originalText,
    rewrittenText,
    category,
    customCategory,
    confidence,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_tags),
    source,
    audioDuration,
    filePath,
  );

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteImplCopyWith<_$NoteImpl> get copyWith =>
      __$$NoteImplCopyWithImpl<_$NoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NoteImplToJson(this);
  }
}

abstract class _Note implements Note {
  const factory _Note({
    required final String id,
    required final String originalText,
    required final String rewrittenText,
    required final NoteCategory category,
    final String? customCategory,
    required final double confidence,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final List<String> tags,
    final NoteSource source,
    final Duration? audioDuration,
    final String? filePath,
  }) = _$NoteImpl;

  factory _Note.fromJson(Map<String, dynamic> json) = _$NoteImpl.fromJson;

  @override
  String get id;
  @override
  String get originalText;
  @override
  String get rewrittenText;
  @override
  NoteCategory get category;
  @override
  String? get customCategory;
  @override
  double get confidence;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  List<String> get tags;
  @override
  NoteSource get source;
  @override
  Duration? get audioDuration;
  @override
  String? get filePath;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteImplCopyWith<_$NoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
