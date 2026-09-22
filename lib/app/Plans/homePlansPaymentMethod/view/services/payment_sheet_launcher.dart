import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/bottomsheet/wallet_payment_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/repository/plan_bundle_mapper.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/theme/home_plans_payment_method_theme.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_request.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/saved_card_payment_bottom_sheet.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Opens the payment confirmation sheets and forwards the result to the bloc.
/// Pure plumbing — kept out of the view so widgets stay declarative.
class PaymentSheetLauncher {
  PaymentSheetLauncher._();

  static Future<void> openWallet(
    BuildContext context, {
    required double walletBalance,
    required String walletBalanceText,
    required String amountText,
  }) async {
    final bloc = context.read<HomePlansPaymentMethodBloc>();
    if (bloc.state.status == HomePlansPaymentMethodStatus.submitting) return;

    final confirmed = await WalletPaymentBottomSheet.show(
      context,
      walletBalanceText: walletBalanceText,
      amountText: amountText,
      navigateToReceiptOnConfirm: false,
    );
    if (confirmed != true) return;

    bloc.add(HomePlansPayFromWalletConfirmed(walletBalance: walletBalance));
  }

  static Future<void> openSavedCard(BuildContext context) async {
    final bloc = context.read<HomePlansPaymentMethodBloc>();
    final state = bloc.state;
    if (state.status == HomePlansPaymentMethodStatus.submitting) return;

    final token = state.selectedMethodId?.trim() ?? '';
    if (token.isEmpty) return;

    final card = _cardByToken(token);
    if (card == null) return;

    final confirmed = await SavedCardPaymentBottomSheet.show(
      context,
      cardLabel: card.displayLabel,
      amountText: state.amountText,
    );
    if (confirmed != true) return;

    bloc.add(const HomePlansPaySavedCardConfirmed());
  }

  /// Opens the 3DS WebView for "pay with card". The WebView POSTs to
  /// /Order/3ds/change-bundle, loads the bank's payment page, and fires
  /// [HomePlans3DSPayWithCardSucceeded] when the redirect-back URL is
  /// intercepted — triggering the normal navTarget = paid flow.
  static Future<void> openPayWithCard(BuildContext context) async {
    final bloc = context.read<HomePlansPaymentMethodBloc>();
    final state = bloc.state;
    if (state.status == HomePlansPaymentMethodStatus.submitting) return;

    final Map<String, dynamic> body;
    try {
      body = ChangeBundleRequestFactory.changeBundleBodyFor3DS(
        amount: state.amount,
        bundle: PlanBundleMapper.fromSelectedItems(state.selectedItems),
        promoCodes: state.promoCodes,
        forceNow: state.forceNow,
        selectedBeginDate: state.selectedBeginDate,
      );
    } catch (e) {
      AppToast.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ToastType.error,
      );
      return;
    }

    final request = PaymentRequest(
      url: Api.changeBundleDs3Url,
      body: body,
      redirectScheme: 'myaliv',
    );

    // Capture navigator before pushing so we can pop the iframe on result.
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PaymentIFrameScreen(
          request: request,
          appBarBgColor: HomePlansPaymentMethodTheme.appBarBg,
          onSuccess: (PaymentSuccess success) {
            navigator.pop();
            bloc.add(
              HomePlans3DSPayWithCardSucceeded(orderId: success.orderId),
            );
          },
          onFailure: (String message) {
            navigator.pop();
            AppToast.show(message: message, type: ToastType.error);
          },
          onHomeTap: () {
            navigator.pop();
            router.go(AppRoutes.home);
          },
        ),
      ),
    );
  }

  static SavedCardModel? _cardByToken(String token) {
    for (final c in instance<SavedCardsCubit>().state.cards) {
      if (c.token == token) return c;
    }
    return null;
  }
}
