class NetworkRequest {
  final String method;

  final String endpoint;
  final String endpointVersion;

  final Map<String, dynamic>? body;

  final Map<String, String> _queryParameters = {};
  final Map<String, String> _headers = {};

  NetworkRequest.get({
    required this.endpoint,
    this.endpointVersion = '',
    this.body,
  }) : method = 'GET';

  NetworkRequest.patch({
    required this.endpoint,
    this.endpointVersion = '',
    this.body,
  }) : method = 'PATCH';

  NetworkRequest.post({
    required this.endpoint,
    this.endpointVersion = '',
    this.body,
  }) : method = 'POST';

  NetworkRequest.put({
    required this.endpoint,
    this.endpointVersion = '',
    this.body,
  }) : method = 'PUT';

  NetworkRequest.options({
    required this.endpoint,
    this.endpointVersion = '',
    this.body,
  }) : method = 'OPTIONS';

  NetworkRequest.delete({
    required this.endpoint,
    this.endpointVersion = '',
    this.body,
  }) : method = 'DELETE';

  NetworkRequest({
    required this.method,
    required this.endpoint,
    this.endpointVersion = '',
    this.body,
  });

  void addQueryParameter(String key, String value) {
    _queryParameters[key] = value;
  }

  void addHeader(String key, String value) {
    _headers[key] = value;
  }

  Map<String, dynamic> get queryParameters => _queryParameters;

  Map<String, String> get headers => _headers;
}
