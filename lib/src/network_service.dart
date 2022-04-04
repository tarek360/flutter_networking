import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:network/src/create_refresh_access_token_options.dart';
import 'package:network/src/interceptor/access_token_interceptor.dart';
import 'package:network/src/interceptor/logging_intercepter.dart';
import 'package:network/src/json_parser.dart';
import 'package:network/src/model/network_request.dart';
import 'package:network/src/model/network_response.dart';

import 'interceptor/header_interceptor.dart';
import 'logger.dart';
import 'model/network_error_type.dart';

typedef BaseUrlBuilder = Future<String> Function();
typedef OnHttpClientCreate = HttpClient? Function(HttpClient client);

class NetworkService {
  final JsonParser _jsonParser = JsonParser();

  final CreateRefreshAccessTokenOptions? createRefreshAccessTokenOptions;
  late Dio _dio;
  final BaseUrlBuilder baseUrlBuilder;
  final bool enableLogging;

  NetworkService({
    required this.baseUrlBuilder,
    this.createRefreshAccessTokenOptions,
    this.enableLogging = true,
  }) {
    _dio = Dio();
    _initInterceptors();
  }

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  void addHeaderInterceptor(HeaderInterceptor interceptor) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      interceptor.onHeaderRequest(options.headers);
      handler.next(options);
    }));
  }

  void onHttpClientCreate(OnHttpClientCreate onHttpClientCreate) {
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = onHttpClientCreate;
  }

  void _initInterceptors() {
    if (enableLogging) {
      addInterceptor(LoggingInterceptor(logger: logger));
    }

    if (createRefreshAccessTokenOptions != null) {
      addInterceptor(AccessTokenInterceptor(
        dio: _dio,
        createAccessTokenOptions: createRefreshAccessTokenOptions!,
      ));
    }
  }

  /// Clear token from memory for users that use [CreateRefreshAccessTokenOptions]
  void clear() {
    final interceptor = _dio.interceptors.firstWhere((element) => element is AccessTokenInterceptor);
    if (interceptor is AccessTokenInterceptor) {
      interceptor.clear();
    }
  }

  Future<NetworkResponse<T>> request<T extends Object, K>({
    required NetworkRequest request,
    K Function(Map<String, dynamic>)? fromJson,
  }) async {
    _dio.options.baseUrl = await baseUrlBuilder();
    try {
      final response = await _request(request);

      final dataObject = _jsonParser.parse<T, K>(response.data, fromJson);

      if (fromJson == null && dataObject == null) {
        return NetworkResponse.success(
          jsonParser: _jsonParser,
          statusCode: response.statusCode,
          dataOnSuccess: null,
          data: response.data,
        );
      }

      if (dataObject != null) {
        return NetworkResponse.success(
          jsonParser: _jsonParser,
          statusCode: response.statusCode,
          dataOnSuccess: dataObject,
          data: response.data,
        );
      } else {
        return NetworkResponse.failure(
          jsonParser: _jsonParser,
          statusCode: response.statusCode,
          rawData: response.data,
          errorType: NetworkErrorType.parsing,
        );
      }
    } on DioError catch (dioError) {
      return NetworkResponse.failure(
        jsonParser: _jsonParser,
        statusCode: dioError.response?.statusCode,
        rawData: dioError.response?.data,
        errorType: _getErrorType(dioError),
      );
    } on Error catch (e) {
      logger.e(e);
      logger.e(e.stackTrace);
      return NetworkResponse.failure(
        jsonParser: _jsonParser,
        statusCode: null,
        rawData: null,
        errorType: NetworkErrorType.other,
      );
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
    } else if (statusCode == 422) {
      return NetworkErrorType.unprocessable;
    } else if (statusCode >= 500) {
      return NetworkErrorType.server;
    }

    return NetworkErrorType.other;
  }
}
