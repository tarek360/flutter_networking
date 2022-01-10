import 'dart:io';

import 'package:dio/dio.dart';
import 'package:network/src/create_refresh_access_token_options.dart';
import 'package:network/src/interceptor/access_token_interceptor.dart';
import 'package:network/src/interceptor/logging_intercepter.dart';
import 'package:network/src/json_parser.dart';
import 'package:network/src/model/network_request.dart';
import 'package:network/src/model/network_response.dart';

import 'logger.dart';
import 'model/network_error_type.dart';

typedef BaseUrlBuilder = Future<String> Function();

class NetworkService {
  final JsonParser _jsonParser = JsonParser();

  final CreateRefreshAccessTokenOptions? createRefreshAccessTokenOptions;
  late Dio _dio;
  final BaseUrlBuilder baseUrlBuilder;

  NetworkService({
    required this.baseUrlBuilder,
    this.createRefreshAccessTokenOptions,
  }) {
    _dio = Dio();
    _initInterceptors();
  }

  _initInterceptors() {
    _dio.interceptors.add(LoggingInterceptor(logger: logger));

    if (createRefreshAccessTokenOptions != null) {
      _dio.interceptors.add(AccessTokenInterceptor(
        dio: _dio,
        createAccessTokenOptions: createRefreshAccessTokenOptions!,
      ));
    }
  }

  Future<NetworkResponse<T>> request<T, K>({
    required NetworkRequest request,
    K Function(Map<String, dynamic>)? fromJson,
  }) async {
    _dio.options.baseUrl = await baseUrlBuilder();
    try {
      final response = await _request(request);

      final parsed = _jsonParser.parse(response.data, fromJson);

      return NetworkResponse.success(parsed);
    } on DioError catch (dioError) {
      return NetworkResponse.failure(_getErrorType(dioError));
    } on Error catch (e) {
      logger.e(e);
      logger.e(e.stackTrace);
      return NetworkResponse.failure(NetworkErrorType.other);
    } on JsonParsingException catch (e) {
      logger.e(e);
      return NetworkResponse.failure(NetworkErrorType.parsing);
    }
  }

  Future<Response> _request(NetworkRequest request) {
    final options = Options(
      method: request.method,
      headers: request.headers,
    );

    return _dio.request(
      request.endpoint,
      data: request.body,
      queryParameters: request.queryParameters,
      options: options,
    );
  }

  NetworkErrorType _getErrorType(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return NetworkErrorType.badConnection;

      case DioErrorType.response:
        return _getErrorTypeWhenHaveResponse(dioError.response?.statusCode);

      case DioErrorType.cancel:
        return NetworkErrorType.cancel;

      case DioErrorType.other:
        if (dioError.error is SocketException) {
          return NetworkErrorType.badConnection;
        } else {
          return NetworkErrorType.other;
        }
    }
  }

  NetworkErrorType _getErrorTypeWhenHaveResponse(int? statusCode) {
    if (statusCode == null) {
      return NetworkErrorType.other;
    }

    if (statusCode == 401) {
      return NetworkErrorType.unauthorised;
    } else if (statusCode == 403) {
      return NetworkErrorType.forbidden;
    } else if (statusCode == 404) {
      return NetworkErrorType.noData;
    } else if (statusCode >= 500) {
      return NetworkErrorType.server;
    }

    return NetworkErrorType.other;
  }
}
