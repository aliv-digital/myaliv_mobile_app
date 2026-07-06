class AuthResponse {
  final String? twoFactorKey;
  final String? ticket;
  final int? accountId;
  final String? message;

  const AuthResponse({
    this.twoFactorKey,
    this.ticket,
    this.accountId,
    this.message,
  });

  bool get hasTicket => (ticket?.trim().isNotEmpty ?? false) && accountId != null;

  bool get hasTwoFactorKey => twoFactorKey?.trim().isNotEmpty ?? false;

  factory AuthResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AuthResponse();

    final rawTwoFactorKey =
        json['TwoFactorKey'] ?? json['twoFactorKey'] ?? json['two_factor_key'];
    final twoFactorKey = rawTwoFactorKey?.toString();

    final rawTicket = json['Ticket'] ?? json['ticket'];
    final ticket = rawTicket?.toString();

    final rawAccountId = json['AccountId'] ?? json['accountId'];
    final accountId = rawAccountId is int
        ? rawAccountId
        : int.tryParse(rawAccountId?.toString() ?? '');

    final rawMessage = json['message'] ?? json['error'] ?? json['detail'];
    final message = rawMessage?.toString();

    return AuthResponse(
      twoFactorKey: twoFactorKey,
      ticket: ticket,
      accountId: accountId,
      message: message,
    );
  }

  Map<String, dynamic> toJson() => {
        if (twoFactorKey != null) 'TwoFactorKey': twoFactorKey,
        if (ticket != null) 'Ticket': ticket,
        if (accountId != null) 'AccountId': accountId,
        if (message != null) 'message': message,
      };
}
