import 'package:network/src/model/network_request.dart';

abstract class CreateRefreshAccessTokenOptions {
  Future<String?> get currentToken;

  Future<NetworkRequest?> get networkRequest;

  String get networkRequestPath;

  List<int> get statusCodes => [401];

  String parse(dynamic data);

  void onTokenCreated(String token);
}
