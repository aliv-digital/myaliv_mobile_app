/// Carries the phone fields collected during forget-password so the sheet
/// shown after a successful password reset can cache credentials for
/// biometric re-login.
///
/// Stored on a transient module holder rather than piped through
/// `GoRouterState.extra` because `GoRouter.refresh()` drops custom-object
/// extras — see the "Android system Back" scenario in
/// `test/forget_password/forget_password_back_navigation_test.dart`.
class PasswordRecoveryCreatePasswordArgs {
  const PasswordRecoveryCreatePasswordArgs({
    required this.apiPhoneNumber,
    required this.phoneNumber,
  });

  final String apiPhoneNumber;
  final String phoneNumber;
}

/// Transient hand-off from the forget-password OTP screen to the
/// recovery variant of the create-password screen.
///
/// The OTP screen writes [pending] immediately before replacing itself with
/// create-password; the create-password screen reads it on first build.
/// Overwrites are safe — a new recovery attempt replaces any stale value.
class PasswordRecoveryContext {
  const PasswordRecoveryContext._();

  static PasswordRecoveryCreatePasswordArgs? pending;
}
