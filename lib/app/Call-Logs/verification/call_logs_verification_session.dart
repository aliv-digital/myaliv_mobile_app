/// In-memory authorization for the sensitive Call Logs view.
///
/// This is intentionally not persisted: a cold app start requires a new
/// verification, while repeated visits in the same signed-in session do not.
class CallLogsVerificationSession {
  bool _isVerified = false;

  bool get isVerified => _isVerified;

  void markVerified() {
    _isVerified = true;
  }

  void reset() {
    _isVerified = false;
  }
}
