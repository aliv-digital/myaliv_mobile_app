/// Exception types for Best Plan repository errors
///
/// Categorizes different types of errors that can occur when fetching plans.
enum BestPlanErrorType {
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

  /// Other unknown errors
  unknown,
}

/// Custom exception for Best Plan repository operations
///
/// Wraps errors from API calls and parsing with user-friendly error types.
class BestPlanRepositoryException implements Exception {
  final BestPlanErrorType type;
  final String message;
  final dynamic originalError;

  const BestPlanRepositoryException(
    this.message, {
    this.type = BestPlanErrorType.unknown,
    this.originalError,
  });

  @override
  String toString() {
    return 'BestPlanRepositoryException($type): $message';
  }
}

/// Exception for JSON parsing errors
class BestPlanParseException implements Exception {
  final String message;
  final dynamic originalError;

  const BestPlanParseException(
    this.message, {
    this.originalError,
  });

  @override
  String toString() {
    return 'BestPlanParseException: $message';
  }
}
