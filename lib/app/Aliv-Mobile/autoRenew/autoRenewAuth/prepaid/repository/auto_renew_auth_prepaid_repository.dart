import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/core/utils/user_display_name.dart';

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
  final String? cardLastDigits;

  const AutoRenewAuthArgs({
    required this.paymentMethod,
    this.cardToken,
    this.cardLastDigits,
  });
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
  Future<AutoRenewAuthContent> fetchContent({String? cardLastDigits});
  Future<bool> submitAuthorization({
    required String name,
    required AutoRenewPaymentMethodType paymentMethod,
    String? cardToken,
  });
}

class AutoRenewAuthPrepaidRepositoryImpl
    implements AutoRenewAuthPrepaidRepository {
  @override
  Future<AutoRenewAuthContent> fetchContent({String? cardLastDigits}) async {
    final fullName = resolveUserDisplayName();
    final cardDigits = (cardLastDigits ?? '').replaceAll(RegExp(r'\D'), '');
    final displayedCardDigits = cardDigits.isEmpty
        ? 'xxxx'
        : cardDigits.substring(
            cardDigits.length > 4 ? cardDigits.length - 4 : 0,
          );

    // Small delay for loading state
    await Future.delayed(const Duration(milliseconds: 100));

    return AutoRenewAuthContent(
      title: 'auto renew authorization form',
      paragraph1:
          'by providing my credit card ending *$displayedCardDigits as payment method, i authorize ALIV and/or its agents to store my payment method information and to automatically charge plan renewal costs of qualifying plans for all subscriber lines on my account. i am certifying i am the payment method owner or have authorization to use the payment method information provided for the automatic charging of plan renewal costs.',
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
    final deviceId = deviceLimitsCubit.state.deviceLimits?.deviceId ?? 0;
    if (deviceId <= 0) return false;

    // Call appropriate API based on payment method
    switch (paymentMethod) {
      case AutoRenewPaymentMethodType.wallet:
        return deviceLimitsCubit.enableAutoRenewWallet(deviceId);
      case AutoRenewPaymentMethodType.card:
        if (cardToken == null || cardToken.isEmpty) return false;
        final cardSuccess = await deviceLimitsCubit.enableAutoRenewCard(
          token: cardToken,
          refreshAfter: false,
        );
        if (!cardSuccess) return false;
        return deviceLimitsCubit.enableAutoRenewWallet(deviceId);
      case AutoRenewPaymentMethodType.postpaidInvoice:
        if (cardToken != null && cardToken.isNotEmpty) {
          final cardSuccess = await deviceLimitsCubit.enableAutoRenewCard(
            token: cardToken,
            refreshAfter: false,
          );
          if (!cardSuccess) return false;
        }
        return instance<AccountInfoCubit>().enableAutoPayInvoice();
    }
  }
}
