import 'package:dio/dio.dart';

import 'network_request.dart';

abstract class NetworkRequestMapper {
  NetworkRequestMapper._();

  static RequestOptions transform(NetworkRequest networkRequest) {
    return RequestOptions(
      method: networkRequest.method,
      path: networkRequest.endpoint + networkRequest.endpointVersion,
      queryParameters: networkRequest.queryParameters,
      data: networkRequest.body,
      headers: networkRequest.headers,
    );
  }
}
