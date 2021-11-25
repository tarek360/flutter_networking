import 'dart:convert' as decoder;

import 'json_parsing_exception.dart';

class JsonParser {
  T? parse<T, K>(dynamic data, K Function(Map<String, dynamic>)? fromJson) {
    T? t;
    try {
      if (data != null) {
        final decodedJson = decoder.json.decode(data);
        if (decodedJson is Iterable) {
          t = _fromJsonList(decodedJson as List<dynamic>, fromJson) as T;
        } else if (decodedJson is Map && fromJson != null) {
          t = fromJson(decodedJson as Map<String, dynamic>) as T;
        }
      }
    } on Error catch (e) {
      throw JsonParsingException(e);
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
