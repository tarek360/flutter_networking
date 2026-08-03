# network

A lightweight [Dio](https://pub.dev/packages/dio) wrapper that turns HTTP calls into typed,
exhaustively handled results, with pluggable access-token refresh, header injection, and
structured request/response logging.

Instead of `try`/`catch` around every call site, you get a `NetworkResponse<T>` that you must
handle in both directions:

```dart
final response = await networkService.request<User, User>(
  request: NetworkRequest.get(endpoint: '/me'),
  fromJson: User.fromJson,
);

final label = response.when(
  success: (user) => 'Hello, ${user.name}',
  failure: (error) => switch (error) {
    NetworkErrorType.unauthorised   => 'Please sign in again',
    NetworkErrorType.badConnection  => 'Check your connection',
    NetworkErrorType.noData         => 'Not found',
    NetworkErrorType.server         => 'Something went wrong on our side',
    _                               => 'Something went wrong',
  },
);
```

## Install

```yaml
dependencies:
  network:
    git:
      url: https://github.com/tarek360/flutter_networking.git
      ref: master
```

Consider pinning `ref` to a commit SHA rather than a branch, so a push here can't silently
change what your CI builds.

`package:network` re-exports `package:dio/dio.dart`, so `CancelToken`, `Interceptor`, and
`RequestOptions` are available from a single import.

## Getting started

```dart
import 'package:network/network.dart';

final networkService = NetworkService(
  baseUrlBuilder: () async => 'https://api.example.com',
  enableLogging: kDebugMode,
  connectTimeout: 8000,
  sendTimeout: 8000,
  receiveTimeout: 10000,
);
```

`baseUrlBuilder` is resolved on **every** request, not once at construction — so switching
environments, regions, or tenants at runtime needs no new client.

## Requests

Named constructors cover the common verbs; the unnamed one takes any method.

```dart
NetworkRequest.get(endpoint: '/products');
NetworkRequest.post(endpoint: '/orders', body: {'sku': 'A-1'});
NetworkRequest.put(endpoint: '/cart');
NetworkRequest.patch(endpoint: '/profile');
NetworkRequest.delete(endpoint: '/session');
NetworkRequest.options(endpoint: '/health');
NetworkRequest(method: 'HEAD', endpoint: '/ping');
```

Query parameters and per-request headers are added after construction:

```dart
final request = NetworkRequest.get(endpoint: '/search')
  ..addQueryParameter('q', 'shoes')
  ..addQueryParameter('page', '2')
  ..addHeader('X-Trace-Id', traceId);
```

Cancellation uses Dio's `CancelToken`:

```dart
final token = CancelToken();
final future = networkService.request(request: request, cancelToken: token);
token.cancel();  // -> NetworkErrorType.cancel
```

## Responses

`request<T, K>` takes two type parameters: `T` is what you get back, `K` is what `fromJson`
builds. For a single object they match; for a list, `T` is `List<K>`.

```dart
// Single object
await networkService.request<User, User>(
  request: NetworkRequest.get(endpoint: '/me'),
  fromJson: User.fromJson,
);

// List — the parser maps each element
await networkService.request<List<User>, User>(
  request: NetworkRequest.get(endpoint: '/users'),
  fromJson: User.fromJson,
);
```

Beyond `when`, a response exposes:

| Member | Description |
|---|---|
| `statusCode` | HTTP status, `null` on transport failures |
| `rawData` | Undecoded body, available on both success and failure |
| `getDataOnError<K>(fromJson:)` | Parses a structured error body (validation details, error codes) |

```dart
final apiError = response.getDataOnError(fromJson: ApiError.fromJson);
```

## Error types

A failure is reported as a `NetworkErrorType` rather than a thrown exception.

| Value | Cause |
|---|---|
| `unauthorised` | 401 |
| `forbidden` | 403 |
| `noData` | 404 |
| `unprocessable` | 422 |
| `server` | 5xx |
| `badConnection` | Connect/send/receive timeout, or no route to host |
| `parsing` | Body arrived but `fromJson` could not build it |
| `cancel` | Cancelled via `CancelToken` |
| `other` | Anything unclassified — including 400 and 429 |

## Access-token refresh

Implement `CreateRefreshAccessTokenOptions` and the interceptor handles the 401 → refresh →
replay cycle. It extends Dio's `QueuedInterceptor`, so concurrent 401s wait on one refresh
rather than each firing their own.

```dart
class AuthOptions extends CreateRefreshAccessTokenOptions {
  @override
  Future<String?> get currentToken async => secureStorage.read('access_token');

  @override
  Future<NetworkRequest?> get networkRequest async => NetworkRequest.post(
        endpoint: '/auth/refresh',
        body: {'refresh_token': await secureStorage.read('refresh_token')},
      );

  @override
  String get networkRequestPath => '/auth/refresh';

  @override
  String parse(dynamic data) => data['access_token'] as String;

  @override
  void onTokenCreated(String token) => secureStorage.write('access_token', token);
}

final networkService = NetworkService(
  baseUrlBuilder: () async => baseUrl,
  createRefreshAccessTokenOptions: AuthOptions(),
);
```

`networkRequestPath` marks the refresh endpoint itself so a failing refresh cannot recurse.

## Headers and interceptors

`HeaderInterceptor` injects headers computed per request — locale, device id, correlation id:

```dart
class AppHeaders implements HeaderInterceptor {
  @override
  void onHeaderRequest(RequestOptions options) {
    options.headers['Accept-Language'] = Intl.getCurrentLocale();
    options.headers['X-App-Version'] = appVersion;
  }
}

networkService.addHeaderInterceptor(AppHeaders());
networkService.addInterceptor(anyDioInterceptor);
```

For custom TLS or proxy setup:

```dart
networkService.onHttpClientCreate(() => HttpClient()..findProxy = ...);
```

## Logging

Set `enableLogging: false` in release builds. When enabled, requests and responses are logged
with method, path, headers, query parameters, and body.

> **Note:** logging currently prints headers verbatim, including `Authorization`. Keep it off
> outside debug builds until header redaction lands (see below).

## Known limitations

Honest about what isn't fixed yet — contributions welcome:

- **`when` on an empty success body.** A 2xx with no body falls through to `success(true as T)`,
  which throws a cast error unless `T` is `bool`. Affects endpoints that return `204`/empty.
- **Logging is not redacted.** `Authorization` and `Cookie` headers and full bodies reach the log
  sink.
- **`badRequest` is never returned.** The enum declares it, but 400 currently maps to `other`.
- **`badConnection` is coarse.** A connect timeout, a slow server, a dropped upload, and being
  offline all collapse into one value, so callers can't pick different retry behaviour or copy.
  429 has no value at all and falls into `other`.
- **`endpointVersion` is ignored on the main request path.** It is applied by
  `NetworkRequestMapper` but not by `NetworkService._request`.
- **`CreateRefreshAccessTokenOptions.statusCodes` is ignored.** The interceptor hardcodes `401`.
- **`JsonParser` catches only `Error`.** An `Exception` thrown from your `fromJson` escapes the
  guarded path instead of becoming `NetworkErrorType.parsing`.
- **No test suite.**

## License

MIT — see [LICENSE](LICENSE).
