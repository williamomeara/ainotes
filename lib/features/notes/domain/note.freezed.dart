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
  int get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  NoteSource get source => throw _privateConstructorUsedError;
  Duration? get audioDuration => throw _privateConstructorUsedError;
  bool get isDraft => throw _privateConstructorUsedError;

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
    int categoryId,
    String categoryName,
    double confidence,
    DateTime createdAt,
    DateTime? updatedAt,
    List<String> tags,
    NoteSource source,
    Duration? audioDuration,
    bool isDraft,
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
    Object? categoryId = null,
    Object? categoryName = null,
    Object? confidence = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? tags = null,
    Object? source = null,
    Object? audioDuration = freezed,
    Object? isDraft = null,
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
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
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
            isDraft: null == isDraft
                ? _value.isDraft
                : isDraft // ignore: cast_nullable_to_non_nullable
                      as bool,
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
    int categoryId,
    String categoryName,
    double confidence,
    DateTime createdAt,
    DateTime? updatedAt,
    List<String> tags,
    NoteSource source,
    Duration? audioDuration,
    bool isDraft,
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
    Object? categoryId = null,
    Object? categoryName = null,
    Object? confidence = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? tags = null,
    Object? source = null,
    Object? audioDuration = freezed,
    Object? isDraft = null,
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
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
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
        isDraft: null == isDraft
            ? _value.isDraft
            : isDraft // ignore: cast_nullable_to_non_nullable
                  as bool,
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
    required this.categoryId,
    required this.categoryName,
    required this.confidence,
    required this.createdAt,
    this.updatedAt,
    final List<String> tags = const [],
    this.source = NoteSource.text,
    this.audioDuration,
    this.isDraft = false,
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
  final int categoryId;
  @override
  final String categoryName;
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
  @JsonKey()
  final bool isDraft;

  @override
  String toString() {
    return 'Note(id: $id, originalText: $originalText, rewrittenText: $rewrittenText, categoryId: $categoryId, categoryName: $categoryName, confidence: $confidence, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, source: $source, audioDuration: $audioDuration, isDraft: $isDraft)';
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
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
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
            (identical(other.isDraft, isDraft) || other.isDraft == isDraft));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    originalText,
    rewrittenText,
    categoryId,
    categoryName,
    confidence,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_tags),
    source,
    audioDuration,
    isDraft,
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
    required final int categoryId,
    required final String categoryName,
    required final double confidence,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final List<String> tags,
    final NoteSource source,
    final Duration? audioDuration,
    final bool isDraft,
  }) = _$NoteImpl;

  factory _Note.fromJson(Map<String, dynamic> json) = _$NoteImpl.fromJson;

  @override
  String get id;
  @override
  String get originalText;
  @override
  String get rewrittenText;
  @override
  int get categoryId;
  @override
  String get categoryName;
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
  bool get isDraft;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteImplCopyWith<_$NoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
