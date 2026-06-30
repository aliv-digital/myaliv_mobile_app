/// Outcome of a `change-bundle` API call.
///
/// Callers pattern-match instead of catching exceptions / parsing strings:
/// ```dart
/// switch (result) {
///   case ChangeBundleSuccess(:final orderId): ...
///   case ChangeBundleFailure(:final message): ...
/// }
/// ```
sealed class ChangeBundleResult {
  const ChangeBundleResult();
}

class ChangeBundleSuccess extends ChangeBundleResult {
  final int? orderId;
  const ChangeBundleSuccess({this.orderId});
}

class ChangeBundleFailure extends ChangeBundleResult {
  final String message;
  const ChangeBundleFailure(this.message);
}
