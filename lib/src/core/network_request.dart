class NetworkRequest {
  final String method;
  String endpointVersion = '';
  final String endpoint;
  final Map<String, String> _queryParameters = {};
  final Map<String, String> _headers = {};
  Map<String, dynamic>? body;
  Map<String, String>? bodyFields;

  Map<String, String> get queryParameters => _queryParameters;

  Map<String, String> get headers => _headers;

  NetworkRequest.get({required this.endpoint}) : method = 'GET';

  NetworkRequest.patch({required this.endpoint}) : method = 'PATCH';

  NetworkRequest.post({required this.endpoint}) : method = 'POST';

  NetworkRequest.put({required this.endpoint}) : method = 'PUT';

  NetworkRequest.options({required this.endpoint}) : method = 'OPTIONS';

  NetworkRequest.delete({required this.endpoint}) : method = 'DELETE';

  NetworkRequest({
    required this.method,
    required this.endpoint,
  });

  void addQueryParameter(String key, String value) {
    queryParameters[key] = value;
  }

  void addHeader(String key, String value) {
    _headers[key] = value;
  }
}
