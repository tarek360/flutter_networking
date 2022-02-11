import 'package:network/src/logger.dart';

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
      logger.e('JSON parsing error:', e);
      return null;
    }
    return t;
  }

  List<K> _fromJsonList<K>(
      List<dynamic> jsonList, K Function(Map<String, dynamic>)? fromJson) {
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
