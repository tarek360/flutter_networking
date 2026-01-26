# Network

A lightweight Dart networking library built on top of [Dio](https://pub.dev/packages/dio) that simplifies HTTP requests with automatic token refresh, request cancellation, typed responses, and comprehensive error handling.

## Features

- **Simple API** - Clean request/response pattern with typed generics
- **Automatic Token Refresh** - Built-in interceptor for handling 401 responses and refreshing access tokens
- **Request Cancellation** - Cancel ongoing requests using `CancelToken`
- **Typed Responses** - Automatic JSON parsing with type-safe responses
- **Error Handling** - Comprehensive error types for different failure scenarios
- **Logging** - Built-in request/response logging (can be disabled)
- **Custom Interceptors** - Add your own Dio interceptors
- **Configurable Timeouts** - Set connect, send, and receive timeouts

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  network: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Usage

### Basic Setup

```dart
import 'package:network/network.dart';

final networkService = NetworkService(
  baseUrlBuilder: () async => 'https://api.example.com',
  enableLogging: true, // Set to false in production
);
```

### Making Requests

#### GET Request

```dart
final response = await networkService.request<User, User>(
  request: NetworkRequest.get(endpoint: '/users/1'),
  fromJson: (json) => User.fromJson(json),
);

response.when(
  success: (user) => print('User: ${user.name}'),
  failure: (error) => print('Error: $error'),
);
```

#### POST Request

```dart
final response = await networkService.request<User, User>(
  request: NetworkRequest.post(
    endpoint: '/users',
    body: {'name': 'John', 'email': 'john@example.com'},
  ),
  fromJson: (json) => User.fromJson(json),
);
```

#### Request with Query Parameters

```dart
final request = NetworkRequest.get(endpoint: '/users');
request.addQueryParameter('page', '1');
request.addQueryParameter('limit', '10');

final response = await networkService.request<List<User>, User>(
  request: request,
  fromJson: (json) => User.fromJson(json),
);
```

### Request Cancellation

```dart
final cancelToken = CancelToken();

// Start the request
final responseFuture = networkService.request<User, User>(
  request: NetworkRequest.get(endpoint: '/users/1'),
  fromJson: (json) => User.fromJson(json),
  cancelToken: cancelToken,
);

// Cancel the request
cancelToken.cancel('User cancelled the request');
```

### Automatic Token Refresh

Implement `CreateRefreshAccessTokenOptions` to enable automatic token refresh:

```dart
class MyTokenOptions extends CreateRefreshAccessTokenOptions {
  @override
  Future<String?> get currentToken async => await storage.getToken();

  @override
  Future<NetworkRequest?> get networkRequest async {
    final refreshToken = await storage.getRefreshToken();
    return NetworkRequest.post(
      endpoint: '/auth/refresh',
      body: {'refresh_token': refreshToken},
    );
  }

  @override
  String get networkRequestPath => '/auth/refresh';

  @override
  String parse(dynamic data) => data['access_token'];

  @override
  void onTokenCreated(String token) => storage.saveToken(token);
}

// Use it when creating NetworkService
final networkService = NetworkService(
  baseUrlBuilder: () async => 'https://api.example.com',
  createRefreshAccessTokenOptions: MyTokenOptions(),
);
```

### Adding Custom Interceptors

```dart
networkService.addInterceptor(MyCustomInterceptor());
```

### Adding Header Interceptors

```dart
class AuthHeaderInterceptor extends HeaderInterceptor {
  @override
  void onHeaderRequest(RequestOptions options) {
    options.headers['X-Custom-Header'] = 'value';
  }
}

networkService.addHeaderInterceptor(AuthHeaderInterceptor());
```

### Error Handling

The library provides typed error handling through `NetworkErrorType`:

```dart
response.when(
  success: (data) => handleSuccess(data),
  failure: (errorType) {
    switch (errorType) {
      case NetworkErrorType.badConnection:
        showError('No internet connection');
        break;
      case NetworkErrorType.unauthorised:
        navigateToLogin();
        break;
      case NetworkErrorType.server:
        showError('Server error, please try again later');
        break;
      case NetworkErrorType.cancel:
        // Request was cancelled, do nothing
        break;
      default:
        showError('Something went wrong');
    }
  },
);
```

#### Available Error Types

| Error Type | Description |
|------------|-------------|
| `cancel` | Request was cancelled |
| `parsing` | Failed to parse response |
| `badRequest` | 400 Bad Request |
| `unauthorised` | 401 Unauthorized |
| `forbidden` | 403 Forbidden |
| `noData` | 404 Not Found |
| `unprocessable` | 422 Unprocessable Entity |
| `badConnection` | Network connectivity issue |
| `server` | 5xx Server Error |
| `other` | Other unhandled errors |

## Configuration

### Timeouts

```dart
final networkService = NetworkService(
  baseUrlBuilder: () async => 'https://api.example.com',
  connectTimeout: 10000,  // 10 seconds
  sendTimeout: 10000,     // 10 seconds
  receiveTimeout: 15000,  // 15 seconds
);
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
