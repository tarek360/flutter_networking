import 'package:network/network.dart';

/// Example model class for demonstration
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

void main() async {
  // Create a NetworkService instance
  final networkService = NetworkService(
    baseUrlBuilder: () async => 'https://jsonplaceholder.typicode.com',
    enableLogging: true,
  );

  // Example 1: GET request
  print('--- Example 1: GET Request ---');
  final getUserResponse = await networkService.request<User, User>(
    request: NetworkRequest.get(endpoint: '/users/1'),
    fromJson: (json) => User.fromJson(json),
  );

  getUserResponse.when(
    success: (user) => print('User: ${user.name} (${user.email})'),
    failure: (error) => print('Error: $error'),
  );

  // Example 2: GET request with query parameters
  print('\n--- Example 2: GET with Query Parameters ---');
  final listRequest = NetworkRequest.get(endpoint: '/users');
  listRequest.addQueryParameter('_limit', '3');

  final listResponse = await networkService.request<List<User>, User>(
    request: listRequest,
    fromJson: (json) => User.fromJson(json),
  );

  listResponse.when(
    success: (users) {
      print('Found ${users.length} users:');
      for (final user in users) {
        print('  - ${user.name}');
      }
    },
    failure: (error) => print('Error: $error'),
  );

  // Example 3: POST request
  print('\n--- Example 3: POST Request ---');
  final createUserResponse = await networkService.request<User, User>(
    request: NetworkRequest.post(
      endpoint: '/users',
      body: {
        'name': 'John Doe',
        'email': 'john@example.com',
      },
    ),
    fromJson: (json) => User.fromJson(json),
  );

  createUserResponse.when(
    success: (user) => print('Created user with id: ${user.id}'),
    failure: (error) => print('Error: $error'),
  );

  // Example 4: Request cancellation
  print('\n--- Example 4: Request Cancellation ---');
  final cancelToken = CancelToken();

  // Start the request
  final cancelFuture = networkService.request<User, User>(
    request: NetworkRequest.get(endpoint: '/users/1'),
    fromJson: (json) => User.fromJson(json),
    cancelToken: cancelToken,
  );

  // Cancel immediately for demonstration
  cancelToken.cancel('Cancelled by user');

  final cancelResponse = await cancelFuture;
  cancelResponse.when(
    success: (user) => print('Got user: ${user.name}'),
    failure: (error) => print('Request cancelled: $error'),
  );

  // Example 5: Error handling
  print('\n--- Example 5: Error Handling ---');
  final errorResponse = await networkService.request<User, User>(
    request: NetworkRequest.get(endpoint: '/users/99999'),
    fromJson: (json) => User.fromJson(json),
  );

  errorResponse.when(
    success: (user) => print('User: ${user.name}'),
    failure: (errorType) {
      switch (errorType) {
        case NetworkErrorType.noData:
          print('User not found (404)');
          break;
        case NetworkErrorType.badConnection:
          print('No internet connection');
          break;
        case NetworkErrorType.server:
          print('Server error');
          break;
        default:
          print('Error: $errorType');
      }
    },
  );
}
