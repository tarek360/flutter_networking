abstract class NetworkException implements Exception {
  final String? _message;
  final String? _prefix;

  NetworkException([this._message, this._prefix]);

  @override
  String toString() {
    return '$_prefix$_message';
  }
}

class FetchDataException extends NetworkException {
  FetchDataException([String? message])
      : super(message, 'Error During Communication: ');
}

class BadRequestException extends NetworkException {
  BadRequestException([message]) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends NetworkException {
  UnauthorisedException([message]) : super(message, 'Unauthorised: ');
}

class ForbiddenException extends NetworkException {
  ForbiddenException([message]) : super(message, 'Forbidden: ');
}

class ForbiddenException extends NetworkException {
  ForbiddenException([message]) : super(message, 'Forbidden: ');
}

class NotFoundException extends NetworkException {
  NotFoundException([message]) : super(message, 'Not Found: ');
}

class InvalidInputException extends NetworkException {
  InvalidInputException([String? message]) : super(message, 'Invalid Input: ');
}
