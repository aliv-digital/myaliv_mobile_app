/// Network-related exceptions
///
/// This file contains all custom exception classes for network operations.
/// Responsible for: Error type definitions and error handling.
library;

/// Base class for all network-related exceptions
class NetworkException implements Exception {
  /// Human-readable error message
  final String message;

  /// HTTP status code (if available)
  final int? statusCode;

  /// Raw error data from the server
  final dynamic data;

  NetworkException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}

/// Exception thrown when session has expired (401 Unauthorized)
class SessionExpiredException extends NetworkException {
  SessionExpiredException() : super('Session expired', statusCode: 401);
}

/// Exception thrown when there's no internet connection
class NoInternetException extends NetworkException {
  NoInternetException() : super('No internet connection');
}

/// Exception thrown when request times out
class TimeoutException extends NetworkException {
  TimeoutException() : super('Request timeout');
}

/// Exception thrown when server returns 5xx errors
class ServerException extends NetworkException {
  ServerException(super.message, {super.statusCode});
}
