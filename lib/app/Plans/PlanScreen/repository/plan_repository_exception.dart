/// Repository-level error categories for plan APIs.
///
/// Keep these generic so every plan tab can reuse the same type.
enum PlanRepositoryErrorType {
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

/// Strongly-typed repository exception used by bloc layer.
///
/// Why this helps:
/// - Bloc can map technical errors to friendly UI messages.
/// - Debug details stay available without leaking raw backend text to users.
class PlanRepositoryException implements Exception {
  const PlanRepositoryException({
    required this.type,
    this.statusCode,
    this.serverMessage,
    this.debugMessage,
  });

  final PlanRepositoryErrorType type;
  final int? statusCode;
  final String? serverMessage;
  final String? debugMessage;

  bool get isRetryable {
    return type == PlanRepositoryErrorType.noInternet ||
        type == PlanRepositoryErrorType.timeout ||
        type == PlanRepositoryErrorType.server ||
        type == PlanRepositoryErrorType.unknown;
  }

  @override
  String toString() {
    return 'PlanRepositoryException('
        'type: $type, '
        'statusCode: $statusCode, '
        'serverMessage: $serverMessage, '
        'debugMessage: $debugMessage'
        ')';
  }
}
