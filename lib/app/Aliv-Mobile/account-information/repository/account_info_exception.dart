/// Repository-level error categories for account information operations.
///
/// Provides structured error handling for fetching account details.
enum AccountInfoErrorType {
  noInternet,
  timeout,
  unauthorized,
  invalidCredentials,
  notFound,
  server,
  badResponse,
  invalidResponse,
  unknown,
}

/// Strongly-typed repository exception for account information operations.
///
/// Benefits:
/// - Cubit can map technical errors to friendly UI messages
/// - Type-safe error handling with specific error types
/// - Debug details available without leaking to users
/// - Retryable errors can be identified programmatically
class AccountInfoException implements Exception {
  const AccountInfoException({
    required this.type,
    this.statusCode,
    this.serverMessage,
    this.debugMessage,
  });

  final AccountInfoErrorType type;
  final int? statusCode;
  final String? serverMessage;
  final String? debugMessage;

  /// Check if this error type is retryable
  bool get isRetryable {
    return type == AccountInfoErrorType.noInternet ||
        type == AccountInfoErrorType.timeout ||
        type == AccountInfoErrorType.server ||
        type == AccountInfoErrorType.unknown;
  }

  @override
  String toString() {
    // Return user-friendly message for backwards compatibility
    final message = serverMessage ?? _getDefaultMessage();
    return 'Exception: $message';
  }

  /// Get default error message based on type
  String _getDefaultMessage() {
    switch (type) {
      case AccountInfoErrorType.noInternet:
        return 'No internet connection';
      case AccountInfoErrorType.timeout:
        return 'Request timeout';
      case AccountInfoErrorType.unauthorized:
        return 'Unauthorized';
      case AccountInfoErrorType.invalidCredentials:
        return 'Invalid username or password';
      case AccountInfoErrorType.notFound:
        return 'Account not found';
      case AccountInfoErrorType.server:
        return 'Server error occurred';
      case AccountInfoErrorType.badResponse:
        return 'Bad request';
      case AccountInfoErrorType.invalidResponse:
        return 'Invalid response from server';
      case AccountInfoErrorType.unknown:
        return 'An unknown error occurred';
    }
  }

  /// Get detailed debug information (for logging/debugging)
  String toDebugString() {
    return 'AccountInfoException('
        'type: $type, '
        'statusCode: $statusCode, '
        'serverMessage: $serverMessage, '
        'debugMessage: $debugMessage'
        ')';
  }
}
