/// Error types for consumption limit operations
enum ConsumptionLimitErrorType {
  network,
  timeout,
  notFound,
  server,
  sessionExpired,
  parsing,
  unknown,
}

/// Exception for consumption limit repository operations
///
/// Wraps all errors that occur during API calls and data parsing.
/// Contains error type for easy categorization and user-friendly messaging.
class ConsumptionLimitRepositoryException implements Exception {
  final String message;
  final ConsumptionLimitErrorType type;
  final Object? originalError;

  const ConsumptionLimitRepositoryException(
    this.message, {
    required this.type,
    this.originalError,
  });

  @override
  String toString() {
    return 'ConsumptionLimitRepositoryException(type: $type, message: $message)';
  }
}
