import 'package:core/core.dart';

/// Result of a successful 2fa/verify call: a JWT [TokenSession].
///
/// The 2fa/verify endpoint returns the same token-pair envelope as the
/// login endpoint's no-2FA branch (access_token, refresh_token, expires_in,
/// refresh_expires_in), so we just wrap a [TokenSession].
class LoginOtpVerifyResponse {
  final TokenSession session;
  const LoginOtpVerifyResponse({required this.session});
}
