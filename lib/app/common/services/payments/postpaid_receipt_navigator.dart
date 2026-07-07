import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Postpaid payment success → receipt navigation. Resolves the account's
/// primary phone (matches the number the server just charged) and pushes
/// [AppRoutes.userProfileReceiptScreen] with the standard args.
///
/// Reusable from any postpaid payment surface — make-payment, auto-pay,
/// etc. — so they render identical receipts without each screen owning a
/// copy of the args + phone lookup.
class PostpaidReceiptNavigator {
  PostpaidReceiptNavigator._();

  /// Pushes the receipt screen. Caller must ensure `context.mounted`
  /// before invoking; this helper does not perform its own mount guard so
  /// it can be composed cleanly inside sync listener callbacks.
  static void push(
    BuildContext context, {
    required double amount,
    required PostpaidPaymentMethod method,
    NewCardDetails? cardToSave,
  }) {
    context.push(
      AppRoutes.userProfileReceiptScreen,
      extra: UserProfileReceiptRouteArgs(
        amount: amount,
        topUpType: 'postpaid',
        recipientPhone: _accountPrimaryPhone(),
        paymentMethod: method.label,
        cardToSave: cardToSave,
      ),
    );
  }

  /// Prefer the account's primary phone; fall back to `phoneNumber`, then
  /// null so the receipt repo can apply its own defaults.
  static String? _accountPrimaryPhone() {
    final account = instance<AccountInfoCubit>().state.accountInfo;
    final primary = account?.primaryPhoneNumber.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    final fallback = account?.phoneNumber.trim() ?? '';
    if (fallback.isNotEmpty) return fallback;
    return null;
  }
}

/// Payment-method label shown on the receipt. `newCard` maps to `'visa'`
/// because the checkout sheet is currently Visa-only; when multi-brand
/// support lands, derive from the card brand instead.
enum PostpaidPaymentMethod {
  newCard('visa'),
  savedCard('credit card');

  const PostpaidPaymentMethod(this.label);
  final String label;
}
