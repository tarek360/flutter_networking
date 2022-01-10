import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:network/src/model/network_error_type.dart';

part 'network_response.freezed.dart';

@freezed
class NetworkResponse<T> with _$NetworkResponse<T> {
  const factory NetworkResponse.success(T data) = _Success;

  const factory NetworkResponse.failure(NetworkErrorType errorType) = _Failure;
}
