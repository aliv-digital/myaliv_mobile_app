/// Policy B purposes. No temporary-access authorization is created.
enum ProtectedAccountAction { changePassword, upgradeCreditLimit }

/// One-use capability issued only after successful secure persistence.
class ActionVerifiedResult<T extends Object> {
  ActionVerifiedResult({
    required this.attemptId,
    required this.paymentMethod,
    required bool Function() canConsume,
  }) : _canConsume = canConsume;

  final Object attemptId;

  /// Legacy parameter name retained for the existing Auto Renew callers.
  /// T may also be a non-payment protected account action.
  final T paymentMethod;
  T get purpose => paymentMethod;
  final bool Function() _canConsume;
  bool _consumed = false;

  bool consume() {
    if (_consumed || !_canConsume()) {
      return false;
    }
    _consumed = true;
    return true;
  }
}
