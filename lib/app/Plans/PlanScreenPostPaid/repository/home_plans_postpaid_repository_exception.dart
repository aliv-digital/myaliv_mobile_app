enum HomePlansPostPaidRepositoryErrorType {
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

class HomePlansPostPaidRepositoryException implements Exception {
  const HomePlansPostPaidRepositoryException({
    required this.type,
    this.statusCode,
    this.serverMessage,
    this.debugMessage,
  });

  final HomePlansPostPaidRepositoryErrorType type;
  final int? statusCode;
  final String? serverMessage;
  final String? debugMessage;

  @override
  String toString() {
    return 'HomePlansPostPaidRepositoryException('
        'type: $type, '
        'statusCode: $statusCode, '
        'serverMessage: $serverMessage, '
        'debugMessage: $debugMessage'
        ')';
  }
}
