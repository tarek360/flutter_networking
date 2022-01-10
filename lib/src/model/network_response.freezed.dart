// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'network_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$NetworkResponseTearOff {
  const _$NetworkResponseTearOff();

  _Success<T> success<T>(T data) {
    return _Success<T>(
      data,
    );
  }

  _Failure<T> failure<T>(NetworkErrorType errorType) {
    return _Failure<T>(
      errorType,
    );
  }
}

/// @nodoc
const $NetworkResponse = _$NetworkResponseTearOff();

/// @nodoc
mixin _$NetworkResponse<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(NetworkErrorType errorType) failure,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(NetworkErrorType errorType)? failure,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(NetworkErrorType errorType)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success<T> value) success,
    required TResult Function(_Failure<T> value) failure,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Failure<T> value)? failure,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Failure<T> value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkResponseCopyWith<T, $Res> {
  factory $NetworkResponseCopyWith(NetworkResponse<T> value, $Res Function(NetworkResponse<T>) then) =
      _$NetworkResponseCopyWithImpl<T, $Res>;
}

/// @nodoc
class _$NetworkResponseCopyWithImpl<T, $Res> implements $NetworkResponseCopyWith<T, $Res> {
  _$NetworkResponseCopyWithImpl(this._value, this._then);

  final NetworkResponse<T> _value;

  // ignore: unused_field
  final $Res Function(NetworkResponse<T>) _then;
}

/// @nodoc
abstract class _$SuccessCopyWith<T, $Res> {
  factory _$SuccessCopyWith(_Success<T> value, $Res Function(_Success<T>) then) = __$SuccessCopyWithImpl<T, $Res>;

  $Res call({T data});
}

/// @nodoc
class __$SuccessCopyWithImpl<T, $Res> extends _$NetworkResponseCopyWithImpl<T, $Res>
    implements _$SuccessCopyWith<T, $Res> {
  __$SuccessCopyWithImpl(_Success<T> _value, $Res Function(_Success<T>) _then)
      : super(_value, (v) => _then(v as _Success<T>));

  @override
  _Success<T> get _value => super._value as _Success<T>;

  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_Success<T>(
      data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$_Success<T> implements _Success<T> {
  const _$_Success(this.data);

  @override
  final T data;

  @override
  String toString() {
    return 'NetworkResponse<$T>.success(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Success<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  _$SuccessCopyWith<T, _Success<T>> get copyWith => __$SuccessCopyWithImpl<T, _Success<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(NetworkErrorType errorType) failure,
  }) {
    return success(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(NetworkErrorType errorType)? failure,
  }) {
    return success?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(NetworkErrorType errorType)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success<T> value) success,
    required TResult Function(_Failure<T> value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Failure<T> value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Failure<T> value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success<T> implements NetworkResponse<T> {
  const factory _Success(T data) = _$_Success<T>;

  T get data;

  @JsonKey(ignore: true)
  _$SuccessCopyWith<T, _Success<T>> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$FailureCopyWith<T, $Res> {
  factory _$FailureCopyWith(_Failure<T> value, $Res Function(_Failure<T>) then) = __$FailureCopyWithImpl<T, $Res>;

  $Res call({NetworkErrorType errorType});
}

/// @nodoc
class __$FailureCopyWithImpl<T, $Res> extends _$NetworkResponseCopyWithImpl<T, $Res>
    implements _$FailureCopyWith<T, $Res> {
  __$FailureCopyWithImpl(_Failure<T> _value, $Res Function(_Failure<T>) _then)
      : super(_value, (v) => _then(v as _Failure<T>));

  @override
  _Failure<T> get _value => super._value as _Failure<T>;

  @override
  $Res call({
    Object? errorType = freezed,
  }) {
    return _then(_Failure<T>(
      errorType == freezed
          ? _value.errorType
          : errorType // ignore: cast_nullable_to_non_nullable
              as NetworkErrorType,
    ));
  }
}

/// @nodoc

class _$_Failure<T> implements _Failure<T> {
  const _$_Failure(this.errorType);

  @override
  final NetworkErrorType errorType;

  @override
  String toString() {
    return 'NetworkResponse<$T>.failure(errorType: $errorType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Failure<T> &&
            const DeepCollectionEquality().equals(other.errorType, errorType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(errorType));

  @JsonKey(ignore: true)
  @override
  _$FailureCopyWith<T, _Failure<T>> get copyWith => __$FailureCopyWithImpl<T, _Failure<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) success,
    required TResult Function(NetworkErrorType errorType) failure,
  }) {
    return failure(errorType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(NetworkErrorType errorType)? failure,
  }) {
    return failure?.call(errorType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? success,
    TResult Function(NetworkErrorType errorType)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(errorType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success<T> value) success,
    required TResult Function(_Failure<T> value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Failure<T> value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Failure<T> value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _Failure<T> implements NetworkResponse<T> {
  const factory _Failure(NetworkErrorType errorType) = _$_Failure<T>;

  NetworkErrorType get errorType;

  @JsonKey(ignore: true)
  _$FailureCopyWith<T, _Failure<T>> get copyWith => throw _privateConstructorUsedError;
}
