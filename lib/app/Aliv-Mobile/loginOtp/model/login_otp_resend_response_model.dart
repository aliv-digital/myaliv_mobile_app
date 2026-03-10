class LoginOtpResendResponse {
  final String? key;
  final String? reason;

  const LoginOtpResendResponse({
    this.key,
    this.reason,
  });

  factory LoginOtpResendResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LoginOtpResendResponse();

    final rawKey = json['Key'] ?? json['key'];
    final rawReason =
        json['Reason'] ?? json['reason'] ?? json['message'] ?? json['error'];

    return LoginOtpResendResponse(
      key: rawKey?.toString(),
      reason: rawReason?.toString(),
    );
  }
}
