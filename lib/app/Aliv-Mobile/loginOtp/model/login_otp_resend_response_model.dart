/// Result of a successful 2fa/resend call.
///
/// The backend may rotate the mfa token on resend — the response carries
/// the (possibly new) token as `Key`. Callers must overwrite the mfa
/// token they hold with [mfaToken] before the next verify attempt.
class LoginOtpResendResponse {
  final String? mfaToken;
  final String? reason;

  const LoginOtpResendResponse({
    this.mfaToken,
    this.reason,
  });

  factory LoginOtpResendResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LoginOtpResendResponse();

    final rawKey = json['Key'] ?? json['key'] ?? json['mfa_token'];
    final rawReason =
        json['Reason'] ?? json['reason'] ?? json['message'] ?? json['error'];

    return LoginOtpResendResponse(
      mfaToken: rawKey?.toString(),
      reason: rawReason?.toString(),
    );
  }
}
