class JsonParser {
  T? parse<T, K>(dynamic data, K Function(Map<String, dynamic>)? fromJson) {
    T? t;
    try {
      if (data != null) {
        if (data is Iterable) {
          t = _fromJsonList(data as List<dynamic>, fromJson) as T;
        } else if (data is Map && fromJson != null) {
          t = fromJson(data as Map<String, dynamic>) as T;
        }
      }
    } on Error catch (e) {
      throw JsonParsingException(e);
    }
    return t;
  }

  List<K> _fromJsonList<K>(List<dynamic> jsonList, K Function(Map<String, dynamic>)? fromJson) {
    final List<K> list = <K>[];

    if (fromJson != null) {
      for (Map<String, dynamic> item in jsonList) {
        list.add(fromJson(item));
      }
    } else {
      return jsonList.cast<K>();
    }
    return list;
  }
}

class JsonParsingException implements Exception {
  const JsonParsingException(this.error);

  final Error error;
  static const _prefix = 'JSON parsing error: ';

  @override
  String toString() {
    return '$_prefix $error\n${error.stackTrace.toString()}';
  }
}
