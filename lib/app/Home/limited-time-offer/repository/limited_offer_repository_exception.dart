/// Error types for Limited Time Offer feature
enum LimitedOfferErrorType {
  network, // Network/API errors
  parsing, // JSON parsing errors
  timeout, // Request timeout
  notFound, // No offers found (404)
  server, // Server errors (5xx)
  unknown, // Unexpected errors
}

/// Base exception for Limited Time Offer repository errors
class LimitedOfferRepositoryException implements Exception {
  final LimitedOfferErrorType type;
  final String message;
  final dynamic originalError;

  const LimitedOfferRepositoryException({
    required this.type,
    required this.message,
    this.originalError,
  });

  @override
  String toString() {
    return 'LimitedOfferRepositoryException(type: $type, message: $message)';
  }
}

/// Exception thrown by API service layer
class LimitedOfferApiException implements Exception {
  final int? statusCode;
  final String message;

  const LimitedOfferApiException({
    this.statusCode,
    required this.message,
  });

  @override
  String toString() {
    return 'LimitedOfferApiException(statusCode: $statusCode, message: $message)';
  }
}

/// Exception thrown by parser service layer
class LimitedOfferParseException implements Exception {
  final String message;
  final dynamic originalError;

  const LimitedOfferParseException(
    this.message, {
    this.originalError,
  });

  @override
  String toString() {
    return 'LimitedOfferParseException(message: $message)';
  }
}
