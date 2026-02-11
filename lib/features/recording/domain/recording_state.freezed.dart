// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RecordingSession {
  /// Current recording status (idle, recording, paused, stopped)
  RecordingStatus get status => throw _privateConstructorUsedError;

  /// Elapsed time since recording started
  Duration get elapsed => throw _privateConstructorUsedError;

  /// Full finalized transcript (confirmed words)
  String get transcript => throw _privateConstructorUsedError;

  /// Partial/interim transcript (current word being spoken)
  String get partialTranscript => throw _privateConstructorUsedError;

  /// Path to saved audio file (populated after stop)
  String? get audioFilePath => throw _privateConstructorUsedError;

  /// Total audio duration
  Duration? get audioDuration => throw _privateConstructorUsedError;

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordingSessionCopyWith<RecordingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordingSessionCopyWith<$Res> {
  factory $RecordingSessionCopyWith(
    RecordingSession value,
    $Res Function(RecordingSession) then,
  ) = _$RecordingSessionCopyWithImpl<$Res, RecordingSession>;
  @useResult
  $Res call({
    RecordingStatus status,
    Duration elapsed,
    String transcript,
    String partialTranscript,
    String? audioFilePath,
    Duration? audioDuration,
  });
}

/// @nodoc
class _$RecordingSessionCopyWithImpl<$Res, $Val extends RecordingSession>
    implements $RecordingSessionCopyWith<$Res> {
  _$RecordingSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? elapsed = null,
    Object? transcript = null,
    Object? partialTranscript = null,
    Object? audioFilePath = freezed,
    Object? audioDuration = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RecordingStatus,
            elapsed: null == elapsed
                ? _value.elapsed
                : elapsed // ignore: cast_nullable_to_non_nullable
                      as Duration,
            transcript: null == transcript
                ? _value.transcript
                : transcript // ignore: cast_nullable_to_non_nullable
                      as String,
            partialTranscript: null == partialTranscript
                ? _value.partialTranscript
                : partialTranscript // ignore: cast_nullable_to_non_nullable
                      as String,
            audioFilePath: freezed == audioFilePath
                ? _value.audioFilePath
                : audioFilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            audioDuration: freezed == audioDuration
                ? _value.audioDuration
                : audioDuration // ignore: cast_nullable_to_non_nullable
                      as Duration?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecordingSessionImplCopyWith<$Res>
    implements $RecordingSessionCopyWith<$Res> {
  factory _$$RecordingSessionImplCopyWith(
    _$RecordingSessionImpl value,
    $Res Function(_$RecordingSessionImpl) then,
  ) = __$$RecordingSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RecordingStatus status,
    Duration elapsed,
    String transcript,
    String partialTranscript,
    String? audioFilePath,
    Duration? audioDuration,
  });
}

/// @nodoc
class __$$RecordingSessionImplCopyWithImpl<$Res>
    extends _$RecordingSessionCopyWithImpl<$Res, _$RecordingSessionImpl>
    implements _$$RecordingSessionImplCopyWith<$Res> {
  __$$RecordingSessionImplCopyWithImpl(
    _$RecordingSessionImpl _value,
    $Res Function(_$RecordingSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? elapsed = null,
    Object? transcript = null,
    Object? partialTranscript = null,
    Object? audioFilePath = freezed,
    Object? audioDuration = freezed,
  }) {
    return _then(
      _$RecordingSessionImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RecordingStatus,
        elapsed: null == elapsed
            ? _value.elapsed
            : elapsed // ignore: cast_nullable_to_non_nullable
                  as Duration,
        transcript: null == transcript
            ? _value.transcript
            : transcript // ignore: cast_nullable_to_non_nullable
                  as String,
        partialTranscript: null == partialTranscript
            ? _value.partialTranscript
            : partialTranscript // ignore: cast_nullable_to_non_nullable
                  as String,
        audioFilePath: freezed == audioFilePath
            ? _value.audioFilePath
            : audioFilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        audioDuration: freezed == audioDuration
            ? _value.audioDuration
            : audioDuration // ignore: cast_nullable_to_non_nullable
                  as Duration?,
      ),
    );
  }
}

/// @nodoc

class _$RecordingSessionImpl implements _RecordingSession {
  const _$RecordingSessionImpl({
    this.status = RecordingStatus.idle,
    this.elapsed = Duration.zero,
    this.transcript = '',
    this.partialTranscript = '',
    this.audioFilePath,
    this.audioDuration,
  });

  /// Current recording status (idle, recording, paused, stopped)
  @override
  @JsonKey()
  final RecordingStatus status;

  /// Elapsed time since recording started
  @override
  @JsonKey()
  final Duration elapsed;

  /// Full finalized transcript (confirmed words)
  @override
  @JsonKey()
  final String transcript;

  /// Partial/interim transcript (current word being spoken)
  @override
  @JsonKey()
  final String partialTranscript;

  /// Path to saved audio file (populated after stop)
  @override
  final String? audioFilePath;

  /// Total audio duration
  @override
  final Duration? audioDuration;

  @override
  String toString() {
    return 'RecordingSession(status: $status, elapsed: $elapsed, transcript: $transcript, partialTranscript: $partialTranscript, audioFilePath: $audioFilePath, audioDuration: $audioDuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingSessionImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.elapsed, elapsed) || other.elapsed == elapsed) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            (identical(other.partialTranscript, partialTranscript) ||
                other.partialTranscript == partialTranscript) &&
            (identical(other.audioFilePath, audioFilePath) ||
                other.audioFilePath == audioFilePath) &&
            (identical(other.audioDuration, audioDuration) ||
                other.audioDuration == audioDuration));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    elapsed,
    transcript,
    partialTranscript,
    audioFilePath,
    audioDuration,
  );

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingSessionImplCopyWith<_$RecordingSessionImpl> get copyWith =>
      __$$RecordingSessionImplCopyWithImpl<_$RecordingSessionImpl>(
        this,
        _$identity,
      );
}

abstract class _RecordingSession implements RecordingSession {
  const factory _RecordingSession({
    final RecordingStatus status,
    final Duration elapsed,
    final String transcript,
    final String partialTranscript,
    final String? audioFilePath,
    final Duration? audioDuration,
  }) = _$RecordingSessionImpl;

  /// Current recording status (idle, recording, paused, stopped)
  @override
  RecordingStatus get status;

  /// Elapsed time since recording started
  @override
  Duration get elapsed;

  /// Full finalized transcript (confirmed words)
  @override
  String get transcript;

  /// Partial/interim transcript (current word being spoken)
  @override
  String get partialTranscript;

  /// Path to saved audio file (populated after stop)
  @override
  String? get audioFilePath;

  /// Total audio duration
  @override
  Duration? get audioDuration;

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingSessionImplCopyWith<_$RecordingSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
