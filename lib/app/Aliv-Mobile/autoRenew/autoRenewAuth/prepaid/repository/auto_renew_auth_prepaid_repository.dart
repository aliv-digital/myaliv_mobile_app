import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';

/// Payment method for auto-renew/auto-pay
enum AutoRenewPaymentMethodType {
  /// Prepaid: Auto-renew from wallet
  wallet,

  /// Prepaid: Auto-renew from credit card
  card,

  /// Postpaid: Auto-pay invoice
  postpaidInvoice,
}

/// Args carried as router `extra` when navigating to the auth screen.
/// Bundles the payment method with the optional saved-card token.
class AutoRenewAuthArgs {
  final AutoRenewPaymentMethodType paymentMethod;
  final String? cardToken;

  const AutoRenewAuthArgs({
    required this.paymentMethod,
    this.cardToken,
  });
}

/// Extract name from email (substring before @)
/// Same logic as used in drawer.dart
String _nameFromEmail(String email) {
  if (email.isEmpty || !email.contains('@')) return 'User';
  return email.split('@').first;
}

class AutoRenewAuthContent {
  final String title;
  final String paragraph1;
  final String consentTitle;
  final String paragraph2;
  final String signatureName;
  final String expectedName; // Name to validate against
  final String nameLabel;
  final String nameHint;
  final String submitText;

  const AutoRenewAuthContent({
    required this.title,
    required this.paragraph1,
    required this.consentTitle,
    required this.paragraph2,
    required this.signatureName,
    required this.expectedName,
    required this.nameLabel,
    required this.nameHint,
    required this.submitText,
  });
}

abstract class AutoRenewAuthPrepaidRepository {
  Future<AutoRenewAuthContent> fetchContent();
  Future<bool> submitAuthorization({
    required String name,
    required AutoRenewPaymentMethodType paymentMethod,
    String? cardToken,
  });
}

class AutoRenewAuthPrepaidRepositoryImpl
    implements AutoRenewAuthPrepaidRepository {
  @override
  Future<AutoRenewAuthContent> fetchContent() async {
    // Get user's full name from DeviceLimitsCubit (same as drawer)
    // Fallback to name extracted from email if not available
    final deviceLimitsCubit = instance<DeviceLimitsCubit>();
    final email = instance<AccountInfoCubit>().state.accountInfo?.email ?? '';
    final fullName = deviceLimitsCubit.state.fullName ?? _nameFromEmail(email);

    // Small delay for loading state
    await Future.delayed(const Duration(milliseconds: 100));

    return AutoRenewAuthContent(
      title: 'auto renew authorization form',
      paragraph1:
          'by providing my credit card ending *xxxx as payment method, i authorize ALIV and/or its agents to store my payment method information and to automatically charge plan renewal costs of qualifying plans for all subscriber lines on my account. i am certifying i am the payment method owner or have authorization to use the payment method information provided for the automatic charging of plan renewal costs.',
      consentTitle: 'electronic communication consent',
      paragraph2:
          'by entering my pin, full name matching the name displayed and clicking agree, i am providing my electronic signature as evidence that i understand the terms i am to which i am agreeing. in addition, i understand this automatic payment authorization will remain in effect until canceled by me via the myALIV app. the complete ALIV automatic payment policy will be sent to your account email address.',
      signatureName: fullName,
      expectedName: fullName,
      nameLabel: 'name',
      nameHint: 'type your name exactly as it appears on your account',
      submitText: 'submit',
    );
  }

  @override
  Future<bool> submitAuthorization({
    required String name,
    required AutoRenewPaymentMethodType paymentMethod,
    String? cardToken,
  }) async {
    final deviceLimitsCubit = instance<DeviceLimitsCubit>();
    final accountInfoCubit = instance<AccountInfoCubit>();
    final accountInfo = accountInfoCubit.state.accountInfo;

    if (accountInfo == null || accountInfo.idAcc <= 0) {
      return false;
    }

    // Call appropriate API based on payment method
    switch (paymentMethod) {
      case AutoRenewPaymentMethodType.wallet:
        return deviceLimitsCubit.enableAutoRenewWallet(accountInfo.idAcc);
      case AutoRenewPaymentMethodType.card:
        if (cardToken == null || cardToken.isEmpty) return false;
        final cardSuccess = await deviceLimitsCubit.enableAutoRenewCard(
          token: cardToken,
          refreshAfter: false,
        );
        if (!cardSuccess) return false;
        return deviceLimitsCubit.enableAutoRenewWallet(accountInfo.idAcc);
      case AutoRenewPaymentMethodType.postpaidInvoice:
        return accountInfoCubit.enableAutoPayInvoice();
    }
  }
}
