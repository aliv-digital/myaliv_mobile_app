/// UI feedback for a recovery challenge; this does not enforce a security lock.
class PasswordRecoveryOtpFeedback {
  const PasswordRecoveryOtpFeedback({
    required this.incorrectAttempts,
    this.message,
  });

  final int incorrectAttempts;
  final String? message;
}

/// Owned by the recovery challenge, independently of widget/Bloc reconstruction.
/// Backend retry-count support can replace this policy without changing the UI.
class PasswordRecoveryOtpAttempts {
  PasswordRecoveryOtpAttempts({required String mfaToken})
    : _mfaToken = mfaToken.trim();

  static const limitMessage =
      'Too many incorrect attempts. Please request a new code to continue.';
  String _mfaToken;
  int _incorrectAttempts = 0;

  String get mfaToken => _mfaToken;

  PasswordRecoveryOtpFeedback? recordIncorrectCode(String requestToken) {
    if (requestToken.trim() != _mfaToken) {
      return null;
    }
    _incorrectAttempts++;
    return PasswordRecoveryOtpFeedback(
      incorrectAttempts: _incorrectAttempts,
      message: _incorrectAttempts >= 5 ? limitMessage : null,
    );
  }

  void verified(String requestToken) {
    if (requestToken.trim() == _mfaToken) {
      _incorrectAttempts = 0;
    }
  }

  void replaceChallenge(String replacementToken) {
    final token = replacementToken.trim();
    if (token.isNotEmpty && token != _mfaToken) {
      _mfaToken = token;
      _incorrectAttempts = 0;
    }
  }
}
