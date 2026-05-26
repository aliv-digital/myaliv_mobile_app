/// Error categories for bucket usage summary operations.
enum BucketUsageSummaryErrorType {
  network,
  parsing,
  timeout,
  notFound,
  server,
  sessionExpired,
  unknown,
}

/// Exception used by the bucket usage summary repository and API service.
class BucketUsageSummaryException implements Exception {
  final BucketUsageSummaryErrorType type;
  final String message;
  final dynamic originalError;

  const BucketUsageSummaryException(
    this.message, {
    this.type = BucketUsageSummaryErrorType.unknown,
    this.originalError,
  });

  @override
  String toString() {
    return 'BucketUsageSummaryException($type): $message';
  }
}

/// Exception used when JSON parsing fails.
class BucketUsageSummaryParseException implements Exception {
  final String message;
  final dynamic originalError;

  const BucketUsageSummaryParseException(this.message, {this.originalError});

  @override
  String toString() {
    return 'BucketUsageSummaryParseException: $message';
  }
}
