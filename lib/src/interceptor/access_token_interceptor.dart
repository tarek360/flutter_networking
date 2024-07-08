import 'package:dio/dio.dart';
import 'package:network/src/create_refresh_access_token_options.dart';
import 'package:network/src/logger.dart';
import 'package:network/src/model/network_request_mapper.dart';

typedef OnAccessTokenExpired = Future<String> Function();

class AccessTokenInterceptor extends QueuedInterceptor {
  AccessTokenInterceptor({
    required this.dio,
    required this.createAccessTokenOptions,
  });

  final Dio dio;
  final CreateRefreshAccessTokenOptions createAccessTokenOptions;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isCreateTokenRequest(options)) {
      await _addToken(options);
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isCreateTokenRequest(err.requestOptions)) {
      final token = await _refreshAccessToken();
      if (token != null) {
        return await _retry(err, handler);
      }
    }
    return super.onError(err, handler);
  }

  Future<void> _retry(DioException err, ErrorInterceptorHandler handler) async {
    await _addToken(err.requestOptions);

    final result = await _executeRequest(err.requestOptions);

    if (result is Response) {
      return handler.resolve(result);
    } else if (result is DioException) {
      if (result.response?.statusCode == 401) {
        return handler.reject(result);
      } else {
        return handler.next(result);
      }
    } else {
      return handler.next(err);
    }
  }

  Future<dynamic> _executeRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    dio.interceptors.remove(this);

    dynamic result;
    try {
      final response = await dio.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );

      result = response;
    } on DioException catch (e) {
      result = e;
    } finally {
      dio.interceptors.add(this);
    }

    return result;
  }

  Future<String?> _refreshAccessToken() async {
    logger.d('Token refreshment is needed.');

    final request = await createAccessTokenOptions.networkRequest;

    if (request != null) {
      final result = await _executeRequest(NetworkRequestMapper.transform(request));
      if (result is Response) {
        final data = result.data;
        if (data != null) {
          final token = createAccessTokenOptions.parse(data);
          createAccessTokenOptions.onTokenCreated(token);
          return token;
        }
      }
    }
    
    logger.e('Token refreshment failed.');

    return null;
  }

  bool _isCreateTokenRequest(RequestOptions options) {
    return options.path == createAccessTokenOptions.networkRequestPath;
  }

  Future<void> _addToken(RequestOptions options) async {
    final accessToken = await createAccessTokenOptions.currentToken;
    options.headers['Authorization'] = 'Bearer $accessToken';
  }
}
