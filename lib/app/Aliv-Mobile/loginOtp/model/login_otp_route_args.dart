/// Typed navigation payload for the login OTP screen.
///
/// Keeps route data explicit and avoids fragile `Map<String, dynamic>` casting.
class LoginOtpRouteArgs {
  final String mfaToken;
  final String phoneNumber;
  final String apiPhoneNumber;

  const LoginOtpRouteArgs({
    required this.mfaToken,
    required this.phoneNumber,
    required this.apiPhoneNumber,
  });
}
