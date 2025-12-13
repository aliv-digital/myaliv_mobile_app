class AuthResponse {
  final int status;       // e.g. 200, 401
  final String message;   // e.g. "OTP SMS sent successfully"
  final String? phone;    // optional, যদি data এর ভেতরে থাকে

  const AuthResponse({
    required this.status,
    required this.message,
    this.phone,
  });

  factory AuthResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AuthResponse(
        status: -1,
        message: 'Unexpected empty response',
      );
    }

    final rawStatus = json['status'];
    final status = rawStatus is int
        ? rawStatus
        : int.tryParse('$rawStatus') ?? -1;

    final rawMessage = json['message'];
    final message = rawMessage?.toString() ?? '';

    // nested data safe parse
    String? phone;
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      phone = data['phone']?.toString();
    }

    return AuthResponse(
      status: status,
      message: message,
      phone: phone,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    if (phone != null) 'phone': phone,
  };
}
