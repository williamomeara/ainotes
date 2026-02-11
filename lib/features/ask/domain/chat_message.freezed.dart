// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'user':
      return UserMessage.fromJson(json);
    case 'ai':
      return AiMessage.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'ChatMessage',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$ChatMessage {
  String get text => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text, DateTime timestamp) user,
    required TResult Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )
    ai,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text, DateTime timestamp)? user,
    TResult? Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )?
    ai,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text, DateTime timestamp)? user,
    TResult Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )?
    ai,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserMessage value) user,
    required TResult Function(AiMessage value) ai,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserMessage value)? user,
    TResult? Function(AiMessage value)? ai,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserMessage value)? user,
    TResult Function(AiMessage value)? ai,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({String text, DateTime timestamp});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? text = null, Object? timestamp = null}) {
    return _then(
      _value.copyWith(
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$UserMessageImplCopyWith(
    _$UserMessageImpl value,
    $Res Function(_$UserMessageImpl) then,
  ) = __$$UserMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, DateTime timestamp});
}

/// @nodoc
class __$$UserMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$UserMessageImpl>
    implements _$$UserMessageImplCopyWith<$Res> {
  __$$UserMessageImplCopyWithImpl(
    _$UserMessageImpl _value,
    $Res Function(_$UserMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? text = null, Object? timestamp = null}) {
    return _then(
      _$UserMessageImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserMessageImpl implements UserMessage {
  const _$UserMessageImpl({
    required this.text,
    required this.timestamp,
    final String? $type,
  }) : $type = $type ?? 'user';

  factory _$UserMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserMessageImplFromJson(json);

  @override
  final String text;
  @override
  final DateTime timestamp;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ChatMessage.user(text: $text, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserMessageImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, timestamp);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserMessageImplCopyWith<_$UserMessageImpl> get copyWith =>
      __$$UserMessageImplCopyWithImpl<_$UserMessageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text, DateTime timestamp) user,
    required TResult Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )
    ai,
  }) {
    return user(text, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text, DateTime timestamp)? user,
    TResult? Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )?
    ai,
  }) {
    return user?.call(text, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text, DateTime timestamp)? user,
    TResult Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )?
    ai,
    required TResult orElse(),
  }) {
    if (user != null) {
      return user(text, timestamp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserMessage value) user,
    required TResult Function(AiMessage value) ai,
  }) {
    return user(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserMessage value)? user,
    TResult? Function(AiMessage value)? ai,
  }) {
    return user?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserMessage value)? user,
    TResult Function(AiMessage value)? ai,
    required TResult orElse(),
  }) {
    if (user != null) {
      return user(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$UserMessageImplToJson(this);
  }
}

abstract class UserMessage implements ChatMessage {
  const factory UserMessage({
    required final String text,
    required final DateTime timestamp,
  }) = _$UserMessageImpl;

  factory UserMessage.fromJson(Map<String, dynamic> json) =
      _$UserMessageImpl.fromJson;

  @override
  String get text;
  @override
  DateTime get timestamp;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserMessageImplCopyWith<_$UserMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AiMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$AiMessageImplCopyWith(
    _$AiMessageImpl value,
    $Res Function(_$AiMessageImpl) then,
  ) = __$$AiMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, DateTime timestamp, List<String> sourceNoteIds});
}

/// @nodoc
class __$$AiMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$AiMessageImpl>
    implements _$$AiMessageImplCopyWith<$Res> {
  __$$AiMessageImplCopyWithImpl(
    _$AiMessageImpl _value,
    $Res Function(_$AiMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? timestamp = null,
    Object? sourceNoteIds = null,
  }) {
    return _then(
      _$AiMessageImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        sourceNoteIds: null == sourceNoteIds
            ? _value._sourceNoteIds
            : sourceNoteIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiMessageImpl implements AiMessage {
  const _$AiMessageImpl({
    required this.text,
    required this.timestamp,
    final List<String> sourceNoteIds = const [],
    final String? $type,
  }) : _sourceNoteIds = sourceNoteIds,
       $type = $type ?? 'ai';

  factory _$AiMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiMessageImplFromJson(json);

  @override
  final String text;
  @override
  final DateTime timestamp;
  final List<String> _sourceNoteIds;
  @override
  @JsonKey()
  List<String> get sourceNoteIds {
    if (_sourceNoteIds is EqualUnmodifiableListView) return _sourceNoteIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceNoteIds);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ChatMessage.ai(text: $text, timestamp: $timestamp, sourceNoteIds: $sourceNoteIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiMessageImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(
              other._sourceNoteIds,
              _sourceNoteIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    text,
    timestamp,
    const DeepCollectionEquality().hash(_sourceNoteIds),
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiMessageImplCopyWith<_$AiMessageImpl> get copyWith =>
      __$$AiMessageImplCopyWithImpl<_$AiMessageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text, DateTime timestamp) user,
    required TResult Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )
    ai,
  }) {
    return ai(text, timestamp, sourceNoteIds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text, DateTime timestamp)? user,
    TResult? Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )?
    ai,
  }) {
    return ai?.call(text, timestamp, sourceNoteIds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text, DateTime timestamp)? user,
    TResult Function(
      String text,
      DateTime timestamp,
      List<String> sourceNoteIds,
    )?
    ai,
    required TResult orElse(),
  }) {
    if (ai != null) {
      return ai(text, timestamp, sourceNoteIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserMessage value) user,
    required TResult Function(AiMessage value) ai,
  }) {
    return ai(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserMessage value)? user,
    TResult? Function(AiMessage value)? ai,
  }) {
    return ai?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserMessage value)? user,
    TResult Function(AiMessage value)? ai,
    required TResult orElse(),
  }) {
    if (ai != null) {
      return ai(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AiMessageImplToJson(this);
  }
}

abstract class AiMessage implements ChatMessage {
  const factory AiMessage({
    required final String text,
    required final DateTime timestamp,
    final List<String> sourceNoteIds,
  }) = _$AiMessageImpl;

  factory AiMessage.fromJson(Map<String, dynamic> json) =
      _$AiMessageImpl.fromJson;

  @override
  String get text;
  @override
  DateTime get timestamp;
  List<String> get sourceNoteIds;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiMessageImplCopyWith<_$AiMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
