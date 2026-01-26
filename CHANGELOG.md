# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-26

### Added
- Initial public release
- `NetworkService` for making HTTP requests with Dio
- `NetworkRequest` class with support for GET, POST, PUT, PATCH, DELETE, and OPTIONS methods
- `NetworkResponse` with typed success/failure handling via `when` method
- `AccessTokenInterceptor` for automatic token refresh on 401 responses
- `HeaderInterceptor` for adding custom headers to requests
- `CancelToken` support for request cancellation
- Comprehensive `NetworkErrorType` enum for error handling
- Configurable timeouts (connect, send, receive)
- Built-in request/response logging
- JSON parsing with generic type support
- Re-export of Dio library for advanced usage

### Dependencies
- dio: ^5.9.0
- logger: ^2.6.2
