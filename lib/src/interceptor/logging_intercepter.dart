import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

typedef HttpLoggerFilter = bool Function();

class LoggingInterceptor extends Interceptor {
  final Logger _logger;
  final bool _includeRequest,
      _includeRequestHeaders,
      _includeRequestQueryParams,
      _includeRequestBody,
      _includeResponse,
      _includeResponseHeaders,
      _includeResponseBody;

  /// Optionally add a filter that will log if the function returns true
  final HttpLoggerFilter? _httpLoggerFilter;

  /// Optionally can add custom [LogPrinter]
  LoggingInterceptor(
      {bool includeRequest = true,
      bool includeRequestHeaders = true,
      bool includeRequestQueryParams = true,
      bool includeRequestBody = true,
      bool includeResponse = true,
      bool includeResponseHeaders = true,
      bool includeResponseBody = true,
      required Logger logger,
      HttpLoggerFilter? httpLoggerFilter})
      : _includeRequest = includeRequest,
        _includeRequestHeaders = includeRequestHeaders,
        _includeRequestQueryParams = includeRequestQueryParams,
        _includeRequestBody = includeRequestBody,
        _includeResponse = includeResponse,
        _includeResponseHeaders = includeResponseHeaders,
        _includeResponseBody = includeResponseBody,
        _logger = logger,
        _httpLoggerFilter = httpLoggerFilter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra = <String, dynamic>{'start_time': DateTime.now().millisecondsSinceEpoch};
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (_httpLoggerFilter == null || _httpLoggerFilter!()) {
      final message = _prepareLog(response.requestOptions, response);
      if (message != '') {
        _logger.i(message);
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final stringBuffer = StringBuffer();
    if (_httpLoggerFilter == null || _httpLoggerFilter!()) {
      final message = _prepareLog(err.requestOptions, err.response);
      if (message != '') {
        stringBuffer.write(message);
      }
    }

    stringBuffer.write('\n Error: $err');
    _logger.e(stringBuffer);

    return super.onError(err, handler);
  }

  /// Whether to pretty print a JSON or return as regular String
  String _getBody(dynamic data, String? contentType) {
    if (contentType != null && contentType.toLowerCase().contains('application/json')) {
      final encoder = JsonEncoder.withIndent('  ');
      final dynamic jsonBody = _jsonDecodeOrNull(data) ?? data;
      return encoder.convert(jsonDecode(jsonEncode(jsonBody)));
    } else {
      return data.toString();
    }
  }

  dynamic _jsonDecodeOrNull(dynamic data) {
    if (data is String) {
      try {
        return json.decode(data);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  String _getQueryParams(Map<String, dynamic>? queryParams) {
    var result = '';

    if (queryParams != null && queryParams.isNotEmpty) {
      result += '===== Query Parameters =====';
      // Temporarily save the query params as string concatenation to be joined
      final params = <String>[];
      for (final entry in queryParams.entries) {
        params.add('${entry.key} : ${entry.value.toString()}');
      }
      result += '\n${params.join('\n')}';
    }
    return result;
  }

  /// Extracts the headers and body (if any) from the request and response
  String _prepareLog(RequestOptions? requestOptions, Response? response) {
    var requestString = '', responseString = '';

    if (_includeRequest) {
      requestString = '⤴ REQUEST ⤴\n\n';

      requestString += 'URL: ${requestOptions?.baseUrl}\n';

      requestString += '${requestOptions?.method ?? ''} ${requestOptions?.path ?? ''}\n';

      if (_includeRequestHeaders) {
        requestString += '===== Headers =====\n';
        for (final header in (requestOptions?.headers ?? {}).entries) {
          requestString += '${header.key}: ${header.value}\n';
        }
      }

      if (_includeRequestQueryParams &&
          requestOptions?.queryParameters != null &&
          requestOptions!.queryParameters.isNotEmpty) {
        requestString += '\n' + _getQueryParams(requestOptions.queryParameters);
      }

      if (_includeRequestBody && requestOptions?.data != null) {
        requestString += '\n\n' + _getBody(requestOptions?.data, requestOptions?.contentType);
      }

      requestString += '\n\n';
    }

    if (_includeResponse && response != null) {
      responseString = '⤵ RESPONSE [${response.statusCode}/${response.statusMessage}] '
          '${requestOptions?.extra['start_time'] != null ? '[Time elapsed: ${DateTime.now().millisecondsSinceEpoch - requestOptions?.extra['start_time']} ms]' : ''}'
          '⤵\n\n';

      if (_includeResponseHeaders) {
        for (final header in response.headers.map.entries) {
          responseString += '${header.key}: ${header.value}\n';
        }
      }

      if (_includeResponseBody && response.data != null) {
        responseString += '\n\n' + _getBody(response.data, response.headers.value('content-type'));
      }
    }

    return requestString + responseString;
  }
}
