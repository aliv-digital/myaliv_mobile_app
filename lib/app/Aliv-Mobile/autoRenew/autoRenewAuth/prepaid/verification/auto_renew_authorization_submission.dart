import '../repository/auto_renew_auth_prepaid_repository.dart';

extension AutoRenewAuthorizationOtpRequirement on AutoRenewPaymentMethodType {
  bool get requiresAuthorizationOtp =>
      this == AutoRenewPaymentMethodType.wallet ||
      this == AutoRenewPaymentMethodType.card ||
      this == AutoRenewPaymentMethodType.postpaidInvoice;
}

/// Lives only with the form; card tokens never enter the OTP route.
class AutoRenewAuthorizationSubmission {
  AutoRenewAuthorizationSubmission({
    required this.name,
    required this.paymentMethod,
    this.cardToken,
  });

  final Object attemptId = Object();
  final String name;
  final AutoRenewPaymentMethodType paymentMethod;
  final String? cardToken;
}

/// A one-use result issued only after secure session persistence completes.
class AutoRenewAuthorizationVerifiedResult {
  AutoRenewAuthorizationVerifiedResult({
    required this.attemptId,
    required this.paymentMethod,
    required bool Function() canConsume,
  }) : _canConsume = canConsume;

  final Object attemptId;
  final AutoRenewPaymentMethodType paymentMethod;
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
