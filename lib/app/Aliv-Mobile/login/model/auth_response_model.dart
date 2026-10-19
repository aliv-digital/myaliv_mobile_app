import 'package:core/core.dart';

/// Sealed result of a login (or 2FA verify) call.
///
/// One of two shapes:
///   - [LoginSuccess]  — full JWT token pair returned; caller can save
///     the session and treat the user as authenticated.
///   - [LoginMfaChallenge] — server dispatched a 6-digit PIN and returned
///     an mfa_token; caller must route to the OTP screen and finish the
///     exchange via `/Auth/2fa/verify`.
sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  const LoginSuccess(this.session);
  final TokenSession session;
}

class LoginMfaChallenge extends LoginResult {
  const LoginMfaChallenge({required this.mfaToken});
  final String mfaToken;
}

/// Defensive parser for the login/verify response body.
///
/// The exact MFA shape isn't fully documented — this reader accepts
/// several plausible casings so we don't have to rev the code the first
/// time we see a live response. `access_token` wins if both keys are
/// present.
class LoginResponseParser {
  static LoginResult parse(Map<String, dynamic> json) {
    final accessToken = _firstNonEmpty(json, const [
      'access_token',
      'accessToken',
      'AccessToken',
    ]);
    if (accessToken != null) {
      return LoginSuccess(TokenSession.fromLoginJson(json));
    }

    final mfaToken = _firstNonEmpty(json, const [
      'mfa_token',
      'mfaToken',
      'MfaToken',
      'MFAToken',
      // Legacy fallback in case the backend still returns the old key.
      'TwoFactorKey',
      'twoFactorKey',
    ]);
    if (mfaToken != null) {
      return LoginMfaChallenge(mfaToken: mfaToken);
    }

    throw const FormatException(
      'Login response missing both access_token and mfa_token',
    );
  }

  static String? _firstNonEmpty(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final v = json[key];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }
}
