/// Repository-level error categories for login OTP operations.
///
/// Provides structured error handling for OTP verification and resend operations.
enum LoginOtpErrorType {
  noInternet,
  timeout,
  unauthorized,
  invalidOtp,
  expiredOtp,
  invalidResponse,
  missingTicket,
  missingKey,
  server,
  badResponse,
  unknown,
}

/// Strongly-typed repository exception for login OTP operations.
///
/// Benefits:
/// - BLoC can map technical errors to friendly UI messages
/// - Type-safe error handling with specific error types
/// - Debug details available without leaking to users
/// - Retryable errors can be identified programmatically
class LoginOtpException implements Exception {
  const LoginOtpException({
    required this.type,
    this.statusCode,
    this.serverMessage,
    this.debugMessage,
  });

  final LoginOtpErrorType type;
  final int? statusCode;
  final String? serverMessage;
  final String? debugMessage;

  /// Check if this error type is retryable
  bool get isRetryable {
    return type == LoginOtpErrorType.noInternet ||
        type == LoginOtpErrorType.timeout ||
        type == LoginOtpErrorType.server ||
        type == LoginOtpErrorType.unknown;
  }

  @override
  String toString() {
    // Return only the message for clean toast display
    return serverMessage ?? _getDefaultMessage();
  }

  /// Get default error message based on type
  String _getDefaultMessage() {
    switch (type) {
      case LoginOtpErrorType.noInternet:
        return 'No internet connection';
      case LoginOtpErrorType.timeout:
        return 'Request timeout';
      case LoginOtpErrorType.unauthorized:
        return 'Unauthorized';
      case LoginOtpErrorType.invalidOtp:
        return 'Invalid OTP code';
      case LoginOtpErrorType.expiredOtp:
        return 'OTP has expired';
      case LoginOtpErrorType.invalidResponse:
        return 'Invalid response from server';
      case LoginOtpErrorType.missingTicket:
        return 'Ticket missing in response';
      case LoginOtpErrorType.missingKey:
        return 'Key missing in response';
      case LoginOtpErrorType.server:
        return 'Server error occurred';
      case LoginOtpErrorType.badResponse:
        return 'Bad request';
      case LoginOtpErrorType.unknown:
        return 'An unknown error occurred';
    }
  }

  /// Get detailed debug information (for logging/debugging)
  String toDebugString() {
    return 'LoginOtpException('
        'type: $type, '
        'statusCode: $statusCode, '
        'serverMessage: $serverMessage, '
        'debugMessage: $debugMessage'
        ')';
  }
}
