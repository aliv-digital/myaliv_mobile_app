enum PaymentIFrameErrorType {
  network,
  noInternet,
  timeout,
  server,
  invalidResponse,
  unknown,
}

class PaymentIFrameException implements Exception {
  const PaymentIFrameException(
    this.message, {
    this.type = PaymentIFrameErrorType.unknown,
    this.originalError,
  });

  final String message;
  final PaymentIFrameErrorType type;
  final Object? originalError;

  @override
  String toString() => 'PaymentIFrameException[$type]: $message';
}
