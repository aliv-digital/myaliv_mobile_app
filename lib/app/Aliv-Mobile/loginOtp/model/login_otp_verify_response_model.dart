class LoginOtpVerifyResponse {
  final String? ticket;
  final int? accountId;
  final String? reason;

  const LoginOtpVerifyResponse({
    this.ticket,
    this.accountId,
    this.reason,
  });

  factory LoginOtpVerifyResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LoginOtpVerifyResponse();

    final rawTicket = json['Ticket'] ?? json['ticket'];
    final rawAccountId = json['AccountId'] ?? json['accountId'];
    final rawReason =
        json['Reason'] ?? json['reason'] ?? json['message'] ?? json['error'];

    return LoginOtpVerifyResponse(
      ticket: rawTicket?.toString(),
      accountId: rawAccountId is int
          ? rawAccountId
          : int.tryParse(rawAccountId?.toString() ?? ''),
      reason: rawReason?.toString(),
    );
  }
}
