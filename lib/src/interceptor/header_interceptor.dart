import 'package:dio/dio.dart';

abstract class HeaderInterceptor {
  void onHeaderRequest(RequestOptions options);
}
