import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:networking/src/core/network_exception.dart';
import 'package:networking/src/core/network_helper.dart';
import 'package:networking/src/core/network_request.dart';
import 'package:networking/src/logger.dart';
import 'package:retry/retry.dart';

import 'api_response.dart';
import 'json_parser.dart';

typedef AuthorizationTokenBuilder = String? Function();
typedef OnAuthorizationTokenExpired = Future<void> Function();

class AppApi {
  static const _maxAttempts = 2;

  AppApi(
    Client _client,
    BaseUrlBuilder _baseUrlBuilder, {
    required this.endpointVersion,
    this.authorizationTokenBuilder,
    bool https = true,
  })  : _network = NetworkHelper(_client, _baseUrlBuilder, https),
        _jsonParser = JsonParser();

  final NetworkHelper _network;
  final JsonParser _jsonParser;
  final String endpointVersion;

  final AuthorizationTokenBuilder? authorizationTokenBuilder;

  OnAuthorizationTokenExpired? onAuthorizationTokenExpired;

  Future<ApiResponse<T>> execute<T, K>(NetworkRequest networkRequest,
      [K Function(Map<String, dynamic>)? fromJson]) async {
    try {
      final String json = await const RetryOptions(
        maxAttempts: _maxAttempts,
      ).retry(
        () async {
          networkRequest.endpointVersion = endpointVersion;
          await _appendRequiredHeaders(networkRequest);
          return _network.execute(networkRequest);
        },
        retryIf: _shouldRetry,
      );
      return ApiResponse.success(_jsonParser.parse(json, fromJson));
    } on Exception catch (e) {
      debugPrint(e.toString());
      return ApiResponse.failure(e);
    }
  }

  Future<void> _appendRequiredHeaders(NetworkRequest networkRequest) async {
    networkRequest.addHeader('content-type', 'application/json');
    final token = authorizationTokenBuilder?.call();
    if (token != null) {
      networkRequest.addHeader('Authorization', 'Bearer $token');
    }
  }

  Future<bool> _shouldRetry(Exception exception) async {
    if (exception is UnauthorisedException) {
      logger.d('UnauthorisedException: the request will be retried once,'
          'token might be expired, make sure that you return a new token in the builder authorizationTokenBuilder()');
      await onAuthorizationTokenExpired?.call();
      return true;
    }

    return false;
  }

  void closeClient() {
    _network.close();
  }
}
