import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import '../repository/auto_renew_auth_prepaid_repository.dart';

extension AutoRenewAuthorizationOtpRequirement on AutoRenewPaymentMethodType {
  bool get requiresAuthorizationOtp =>
      this == AutoRenewPaymentMethodType.wallet ||
      this == AutoRenewPaymentMethodType.card ||
      this == AutoRenewPaymentMethodType.postpaidInvoice;
}

/// Lives only with the form; card tokens never enter the OTP route.
/// The [attemptId] originates in the Setup screen (where the OTP challenge is
/// issued) and is reused here so the submission can match the one-use
/// [ActionVerifiedResult] on consume.
class AutoRenewAuthorizationSubmission {
  AutoRenewAuthorizationSubmission({
    required this.attemptId,
    required this.name,
    required this.paymentMethod,
    this.cardToken,
  });

  final Object attemptId;
  final String name;
  final AutoRenewPaymentMethodType paymentMethod;
  final String? cardToken;
}

typedef AutoRenewAuthorizationVerifiedResult =
    ActionVerifiedResult<AutoRenewPaymentMethodType>;
