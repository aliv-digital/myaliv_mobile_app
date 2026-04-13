/// Exception types for Balance repository errors
///
/// Categorizes different types of errors that can occur when fetching balances.
enum BalanceErrorType {
  /// Network connectivity issues
  network,

  /// JSON parsing errors
  parsing,

  /// Request timeout
  timeout,

  /// 404 Not Found
  notFound,

  /// 5xx Server errors
  server,

  /// Session expired or authentication failed
  sessionExpired,

  /// Other unknown errors
  unknown,
}

/// Custom exception for Balance repository operations
///
/// Wraps errors from API calls and parsing with user-friendly error types.
class BalanceRepositoryException implements Exception {
  final BalanceErrorType type;
  final String message;
  final dynamic originalError;

  const BalanceRepositoryException(
    this.message, {
    this.type = BalanceErrorType.unknown,
    this.originalError,
  });

  @override
  String toString() {
    return 'BalanceRepositoryException($type): $message';
  }
}

/// Exception for JSON parsing errors
class BalanceParseException implements Exception {
  final String message;
  final dynamic originalError;

  const BalanceParseException(
    this.message, {
    this.originalError,
  });

  @override
  String toString() {
    return 'BalanceParseException: $message';
  }
}
