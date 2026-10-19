import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';

/// Reuses transport/refresh/phone selection, not History authorization.
/// Concurrent invoice entry requests share only the in-flight challenge;
/// completed challenges are never cached for a later visit or resend.
class ReviewInvoiceVerificationRepository
    extends CallLogsVerificationRepository {
  ReviewInvoiceVerificationRepository({
    super.networkService,
    super.authManager,
    super.internetConnection,
    super.phoneNumberProvider,
  });

  Future<CallLogsChallenge>? _pending;

  @override
  Future<CallLogsChallenge> requestChallenge() {
    final pending = _pending;
    if (pending != null) {
      return pending;
    }
    late final Future<CallLogsChallenge> request;
    request = super.requestChallenge().whenComplete(() {
      if (identical(_pending, request)) {
        _pending = null;
      }
    });
    _pending = request;
    return request;
  }

  /// Do not let another subscriber reuse an in-flight pre-logout challenge.
  void reset() {
    _pending = null;
  }
}
