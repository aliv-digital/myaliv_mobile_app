/// Repository-level error categories for all plan APIs.
///
/// Shared by both prepaid and postpaid plan services.
enum BasePlanRepositoryErrorType {
  noInternet,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  server,
  badResponse,
  parsing,
  unknown,
}

/// Base repository exception for plan-related errors.
///
/// All plan repositories (prepaid/postpaid) should use this exception.
///
/// Benefits:
/// - Single source of truth for error types
/// - Consistent error handling across all plan services
/// - Easier to add new error types in the future
/// - Reduced code duplication
class BasePlanRepositoryException implements Exception {
  const BasePlanRepositoryException({
    required this.type,
    this.statusCode,
    this.serverMessage,
    this.debugMessage,
    this.source,
  });

  final BasePlanRepositoryErrorType type;
  final int? statusCode;
  final String? serverMessage;
  final String? debugMessage;

  /// Optional: identify which service threw this ('prepaid', 'postpaid')
  final String? source;

  /// Check if the error is retryable by the user
  bool get isRetryable {
    return type == BasePlanRepositoryErrorType.noInternet ||
        type == BasePlanRepositoryErrorType.timeout ||
        type == BasePlanRepositoryErrorType.server ||
        type == BasePlanRepositoryErrorType.unknown;
  }

  /// Check if the error is authentication-related
  bool get isAuthError {
    return type == BasePlanRepositoryErrorType.unauthorized ||
        type == BasePlanRepositoryErrorType.forbidden;
  }

  /// Check if the error indicates a client-side issue
  bool get isClientError {
    return type == BasePlanRepositoryErrorType.badResponse ||
        type == BasePlanRepositoryErrorType.parsing;
  }

  /// Check if the error is a server-side issue
  bool get isServerError {
    return type == BasePlanRepositoryErrorType.server;
  }

  @override
  String toString() {
    final sourceStr = source != null ? '$source: ' : '';
    return 'BasePlanRepositoryException('
        '${sourceStr}type: $type, '
        'statusCode: $statusCode, '
        'serverMessage: $serverMessage, '
        'debugMessage: $debugMessage'
        ')';
  }
}
