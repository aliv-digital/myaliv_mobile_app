class AuthResponse {
  final String? twoFactorKey;
  final String? message;

  const AuthResponse({
    this.twoFactorKey,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AuthResponse();

    final rawTwoFactorKey = json['TwoFactorKey'] ?? json['twoFactorKey'] ?? json['two_factor_key'];
    final twoFactorKey = rawTwoFactorKey?.toString();

    final rawMessage = json['message'] ?? json['error'] ?? json['detail'];
    final message = rawMessage?.toString();

    return AuthResponse(twoFactorKey: twoFactorKey, message: message);
  }

  Map<String, dynamic> toJson() => {
        if (twoFactorKey != null) 'TwoFactorKey': twoFactorKey,
        if (message != null) 'message': message,
      };
}
