/// In-memory authorization for the current shared History visit.
///
/// This is intentionally not persisted: a cold app start requires a new
/// verification. Leaving History ends authorization; switching its tabs does
/// not. The History route owner and hard logout reset this flag.
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
