class CallLogsOtpRouteArgs {
  const CallLogsOtpRouteArgs({
    required this.mfaToken,
    required this.apiPhoneNumber,
  });

  final String mfaToken;
  final String apiPhoneNumber;
}
