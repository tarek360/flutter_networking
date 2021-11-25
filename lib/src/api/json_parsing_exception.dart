class JsonParsingException implements Exception {
  final Error? error;
  final _prefix = 'JSON parsing error: ';

  JsonParsingException([this.error]);

  @override
  String toString() {
    return '$_prefix $error\n${error?.stackTrace.toString()}';
  }
}
