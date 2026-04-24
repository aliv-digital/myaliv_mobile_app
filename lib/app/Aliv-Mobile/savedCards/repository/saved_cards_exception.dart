/// Repository-level error categories for saved cards operations.
enum SavedCardsErrorType {
  noInternet,
  timeout,
  unauthorized,
  notFound,
  server,
  badResponse,
  invalidResponse,
  unknown,
}

/// Strongly-typed repository exception for saved cards operations.
class SavedCardsException implements Exception {
  const SavedCardsException({
    required this.type,
    this.statusCode,
    this.serverMessage,
    this.debugMessage,
  });

  final SavedCardsErrorType type;
  final int? statusCode;
  final String? serverMessage;
  final String? debugMessage;

  /// Check if this error type is retryable
  bool get isRetryable {
    return type == SavedCardsErrorType.noInternet ||
        type == SavedCardsErrorType.timeout ||
        type == SavedCardsErrorType.server ||
        type == SavedCardsErrorType.unknown;
  }

  @override
  String toString() {
    final message = serverMessage ?? _getDefaultMessage();
    return 'SavedCardsException: $message';
  }

  String _getDefaultMessage() {
    switch (type) {
      case SavedCardsErrorType.noInternet:
        return 'No internet connection';
      case SavedCardsErrorType.timeout:
        return 'Request timeout';
      case SavedCardsErrorType.unauthorized:
        return 'Unauthorized';
      case SavedCardsErrorType.notFound:
        return 'No saved cards found';
      case SavedCardsErrorType.server:
        return 'Server error occurred';
      case SavedCardsErrorType.badResponse:
        return 'Bad request';
      case SavedCardsErrorType.invalidResponse:
        return 'Invalid response from server';
      case SavedCardsErrorType.unknown:
        return 'An unknown error occurred';
    }
  }

  String toDebugString() {
    return 'SavedCardsException('
        'type: $type, '
        'statusCode: $statusCode, '
        'serverMessage: $serverMessage, '
        'debugMessage: $debugMessage'
        ')';
  }
}
