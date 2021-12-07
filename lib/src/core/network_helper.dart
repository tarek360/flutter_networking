import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../logger.dart';
import 'network_exception.dart';
import 'network_request.dart';

typedef BaseUrlBuilder = Future<String> Function();

class NetworkHelper {
  NetworkHelper(this._client, this._baseUrlBuilder);

  final BaseUrlBuilder _baseUrlBuilder;

  final Client _client;

  Future<String> execute(NetworkRequest networkRequest) async {
    try {
      final Uri uri = await _getUri(
        networkRequest.endpointVersion,
        networkRequest.endpoint,
        networkRequest.queryParameters,
      );

      final Request request = Request(networkRequest.method, uri);
      networkRequest.headers.forEach((key, value) {
        request.headers[key] = value;
      });

      String requestLog = 'Request => ${networkRequest.method}: $uri';
      final Map<String, String>? bodyFields = networkRequest.bodyFields;
      if (networkRequest.body != null) {
        request.body = json.encode(networkRequest.body);
        requestLog += '\nbody: ${request.body}';
      } else if (bodyFields != null) {
        request.bodyFields = bodyFields;
        requestLog += '\nbodyFields: ${request.bodyFields}';
      }

      logger.d(requestLog);

      final StreamedResponse streamedResponse = await _client.send(request);
      final Response response = await Response.fromStream(streamedResponse);
      final String stringResponse = getStringResponse(response);

      String responseLog = 'Response => ${networkRequest.method}: $uri';
      responseLog += '\nstatusCode: ${response.statusCode}';
      responseLog += '\nbody: $stringResponse';
      logger.d(responseLog);

      return stringResponse;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<Uri> _getUri(String? endpointVersion, String endpoint,
      Map<String, String> params) async {
    return Uri.https(
      await _baseUrlBuilder(),
      '$endpointVersion$endpoint',
      params.isNotEmpty ? params : null,
    );
  }

  void close() => _client.close();

  String getStringResponse(Response response) {
    final String body = utf8.decode(response.bodyBytes);

    if (response.statusCode == 204) {
      return '[]';
    } else if (response.statusCode >= 200 && response.statusCode <= 299) {
      return body;
    }

    switch (response.statusCode) {
      case 400:
        throw BadRequestException(body);
      case 401:
        throw UnauthorisedException(body);
      case 403:
        throw ForbiddenException(body);
      case 404:
        throw NotFoundException(body);
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while communicating with server with status code: ${response
                .statusCode}');
    }
  }
}
