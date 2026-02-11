// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DownloadState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notStarted,
    required TResult Function(double progress) downloading,
    required TResult Function(String localPath) ready,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notStarted,
    TResult? Function(double progress)? downloading,
    TResult? Function(String localPath)? ready,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notStarted,
    TResult Function(double progress)? downloading,
    TResult Function(String localPath)? ready,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotStarted value) notStarted,
    required TResult Function(Downloading value) downloading,
    required TResult Function(Ready value) ready,
    required TResult Function(DownloadError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotStarted value)? notStarted,
    TResult? Function(Downloading value)? downloading,
    TResult? Function(Ready value)? ready,
    TResult? Function(DownloadError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotStarted value)? notStarted,
    TResult Function(Downloading value)? downloading,
    TResult Function(Ready value)? ready,
    TResult Function(DownloadError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadStateCopyWith<$Res> {
  factory $DownloadStateCopyWith(
    DownloadState value,
    $Res Function(DownloadState) then,
  ) = _$DownloadStateCopyWithImpl<$Res, DownloadState>;
}

/// @nodoc
class _$DownloadStateCopyWithImpl<$Res, $Val extends DownloadState>
    implements $DownloadStateCopyWith<$Res> {
  _$DownloadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NotStartedImplCopyWith<$Res> {
  factory _$$NotStartedImplCopyWith(
    _$NotStartedImpl value,
    $Res Function(_$NotStartedImpl) then,
  ) = __$$NotStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NotStartedImplCopyWithImpl<$Res>
    extends _$DownloadStateCopyWithImpl<$Res, _$NotStartedImpl>
    implements _$$NotStartedImplCopyWith<$Res> {
  __$$NotStartedImplCopyWithImpl(
    _$NotStartedImpl _value,
    $Res Function(_$NotStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NotStartedImpl implements NotStarted {
  const _$NotStartedImpl();

  @override
  String toString() {
    return 'DownloadState.notStarted()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NotStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notStarted,
    required TResult Function(double progress) downloading,
    required TResult Function(String localPath) ready,
    required TResult Function(String message) error,
  }) {
    return notStarted();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notStarted,
    TResult? Function(double progress)? downloading,
    TResult? Function(String localPath)? ready,
    TResult? Function(String message)? error,
  }) {
    return notStarted?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notStarted,
    TResult Function(double progress)? downloading,
    TResult Function(String localPath)? ready,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (notStarted != null) {
      return notStarted();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotStarted value) notStarted,
    required TResult Function(Downloading value) downloading,
    required TResult Function(Ready value) ready,
    required TResult Function(DownloadError value) error,
  }) {
    return notStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotStarted value)? notStarted,
    TResult? Function(Downloading value)? downloading,
    TResult? Function(Ready value)? ready,
    TResult? Function(DownloadError value)? error,
  }) {
    return notStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotStarted value)? notStarted,
    TResult Function(Downloading value)? downloading,
    TResult Function(Ready value)? ready,
    TResult Function(DownloadError value)? error,
    required TResult orElse(),
  }) {
    if (notStarted != null) {
      return notStarted(this);
    }
    return orElse();
  }
}

abstract class NotStarted implements DownloadState {
  const factory NotStarted() = _$NotStartedImpl;
}

/// @nodoc
abstract class _$$DownloadingImplCopyWith<$Res> {
  factory _$$DownloadingImplCopyWith(
    _$DownloadingImpl value,
    $Res Function(_$DownloadingImpl) then,
  ) = __$$DownloadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double progress});
}

/// @nodoc
class __$$DownloadingImplCopyWithImpl<$Res>
    extends _$DownloadStateCopyWithImpl<$Res, _$DownloadingImpl>
    implements _$$DownloadingImplCopyWith<$Res> {
  __$$DownloadingImplCopyWithImpl(
    _$DownloadingImpl _value,
    $Res Function(_$DownloadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? progress = null}) {
    return _then(
      _$DownloadingImpl(
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$DownloadingImpl implements Downloading {
  const _$DownloadingImpl({required this.progress});

  @override
  final double progress;

  @override
  String toString() {
    return 'DownloadState.downloading(progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadingImpl &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, progress);

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadingImplCopyWith<_$DownloadingImpl> get copyWith =>
      __$$DownloadingImplCopyWithImpl<_$DownloadingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notStarted,
    required TResult Function(double progress) downloading,
    required TResult Function(String localPath) ready,
    required TResult Function(String message) error,
  }) {
    return downloading(progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notStarted,
    TResult? Function(double progress)? downloading,
    TResult? Function(String localPath)? ready,
    TResult? Function(String message)? error,
  }) {
    return downloading?.call(progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notStarted,
    TResult Function(double progress)? downloading,
    TResult Function(String localPath)? ready,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (downloading != null) {
      return downloading(progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotStarted value) notStarted,
    required TResult Function(Downloading value) downloading,
    required TResult Function(Ready value) ready,
    required TResult Function(DownloadError value) error,
  }) {
    return downloading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotStarted value)? notStarted,
    TResult? Function(Downloading value)? downloading,
    TResult? Function(Ready value)? ready,
    TResult? Function(DownloadError value)? error,
  }) {
    return downloading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotStarted value)? notStarted,
    TResult Function(Downloading value)? downloading,
    TResult Function(Ready value)? ready,
    TResult Function(DownloadError value)? error,
    required TResult orElse(),
  }) {
    if (downloading != null) {
      return downloading(this);
    }
    return orElse();
  }
}

abstract class Downloading implements DownloadState {
  const factory Downloading({required final double progress}) =
      _$DownloadingImpl;

  double get progress;

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadingImplCopyWith<_$DownloadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReadyImplCopyWith<$Res> {
  factory _$$ReadyImplCopyWith(
    _$ReadyImpl value,
    $Res Function(_$ReadyImpl) then,
  ) = __$$ReadyImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String localPath});
}

/// @nodoc
class __$$ReadyImplCopyWithImpl<$Res>
    extends _$DownloadStateCopyWithImpl<$Res, _$ReadyImpl>
    implements _$$ReadyImplCopyWith<$Res> {
  __$$ReadyImplCopyWithImpl(
    _$ReadyImpl _value,
    $Res Function(_$ReadyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? localPath = null}) {
    return _then(
      _$ReadyImpl(
        localPath: null == localPath
            ? _value.localPath
            : localPath // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ReadyImpl implements Ready {
  const _$ReadyImpl({required this.localPath});

  @override
  final String localPath;

  @override
  String toString() {
    return 'DownloadState.ready(localPath: $localPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadyImpl &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, localPath);

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadyImplCopyWith<_$ReadyImpl> get copyWith =>
      __$$ReadyImplCopyWithImpl<_$ReadyImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notStarted,
    required TResult Function(double progress) downloading,
    required TResult Function(String localPath) ready,
    required TResult Function(String message) error,
  }) {
    return ready(localPath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notStarted,
    TResult? Function(double progress)? downloading,
    TResult? Function(String localPath)? ready,
    TResult? Function(String message)? error,
  }) {
    return ready?.call(localPath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notStarted,
    TResult Function(double progress)? downloading,
    TResult Function(String localPath)? ready,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready(localPath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotStarted value) notStarted,
    required TResult Function(Downloading value) downloading,
    required TResult Function(Ready value) ready,
    required TResult Function(DownloadError value) error,
  }) {
    return ready(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotStarted value)? notStarted,
    TResult? Function(Downloading value)? downloading,
    TResult? Function(Ready value)? ready,
    TResult? Function(DownloadError value)? error,
  }) {
    return ready?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotStarted value)? notStarted,
    TResult Function(Downloading value)? downloading,
    TResult Function(Ready value)? ready,
    TResult Function(DownloadError value)? error,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready(this);
    }
    return orElse();
  }
}

abstract class Ready implements DownloadState {
  const factory Ready({required final String localPath}) = _$ReadyImpl;

  String get localPath;

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadyImplCopyWith<_$ReadyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DownloadErrorImplCopyWith<$Res> {
  factory _$$DownloadErrorImplCopyWith(
    _$DownloadErrorImpl value,
    $Res Function(_$DownloadErrorImpl) then,
  ) = __$$DownloadErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$DownloadErrorImplCopyWithImpl<$Res>
    extends _$DownloadStateCopyWithImpl<$Res, _$DownloadErrorImpl>
    implements _$$DownloadErrorImplCopyWith<$Res> {
  __$$DownloadErrorImplCopyWithImpl(
    _$DownloadErrorImpl _value,
    $Res Function(_$DownloadErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$DownloadErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DownloadErrorImpl implements DownloadError {
  const _$DownloadErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'DownloadState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadErrorImplCopyWith<_$DownloadErrorImpl> get copyWith =>
      __$$DownloadErrorImplCopyWithImpl<_$DownloadErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notStarted,
    required TResult Function(double progress) downloading,
    required TResult Function(String localPath) ready,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notStarted,
    TResult? Function(double progress)? downloading,
    TResult? Function(String localPath)? ready,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notStarted,
    TResult Function(double progress)? downloading,
    TResult Function(String localPath)? ready,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotStarted value) notStarted,
    required TResult Function(Downloading value) downloading,
    required TResult Function(Ready value) ready,
    required TResult Function(DownloadError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotStarted value)? notStarted,
    TResult? Function(Downloading value)? downloading,
    TResult? Function(Ready value)? ready,
    TResult? Function(DownloadError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotStarted value)? notStarted,
    TResult Function(Downloading value)? downloading,
    TResult Function(Ready value)? ready,
    TResult Function(DownloadError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class DownloadError implements DownloadState {
  const factory DownloadError({required final String message}) =
      _$DownloadErrorImpl;

  String get message;

  /// Create a copy of DownloadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadErrorImplCopyWith<_$DownloadErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
