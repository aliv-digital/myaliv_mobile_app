import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/theme/home_plans_payment_method_theme.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/services/payment_receipt_builder.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/widgets/payment_app_bar.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/widgets/payment_method_content.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/widgets/payment_pay_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Stateful orchestrator: bootstraps wallet balance, listens for bloc-driven
/// navigation/toasts, and composes the screen's small parts.
class HomePlansPaymentMethodView extends StatefulWidget {
  const HomePlansPaymentMethodView({super.key});

  @override
  State<HomePlansPaymentMethodView> createState() =>
      _HomePlansPaymentMethodViewState();
}

class _HomePlansPaymentMethodViewState
    extends State<HomePlansPaymentMethodView> {
  int _lastWalletWarningRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadWalletBalanceIfPossible();
  }

  void _loadWalletBalanceIfPossible() {
    final info = context.read<AccountInfoCubit>().state.accountInfo;
    if (info == null || info.idAcc <= 0) return;
    // BalanceCubit owns the wallet balance app-wide; it caches & refetches.
    context.read<BalanceCubit>().loadBalances(deviceAccountId: info.idAcc);
  }

  void _onState(BuildContext context, HomePlansPaymentMethodState state) {
    _maybeShowWalletWarning(state);

    if (state.errorMessage != null &&
        state.status == HomePlansPaymentMethodStatus.failure) {
      AppToast.show(message: state.errorMessage!, type: ToastType.error);
    }

    if (state.navTarget == HomePlansPaymentMethodNavTarget.none) return;

    if (state.navTarget == HomePlansPaymentMethodNavTarget.paid) {
      final isCardPath = state.paymentMode == HomePlansPaymentMode.card ||
          state.paymentMode == HomePlansPaymentMode.payWithCard;
      context.push(
        AppRoutes.homePlanPurchaseReceiptScreen,
        extra: PaymentReceiptBuilder.build(
          context,
          state,
          hideSaveCreditCard: !isCardPath,
        ),
      );
    }
    // addCard / wallet nav targets are placeholders for future routes.

    context
        .read<HomePlansPaymentMethodBloc>()
        .add(const HomePlansPaymentNavConsumed());
  }

  void _maybeShowWalletWarning(HomePlansPaymentMethodState state) {
    if (state.walletWarningRequestId <= _lastWalletWarningRequestId) return;
    if (state.walletWarningMessage == null) return;
    _lastWalletWarningRequestId = state.walletWarningRequestId;
    AppToast.show(message: state.walletWarningMessage!, type: ToastType.error);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomePlansPaymentMethodBloc,
        HomePlansPaymentMethodState>(
      listenWhen: (p, c) =>
          p.navTarget != c.navTarget ||
          p.errorMessage != c.errorMessage ||
          p.walletWarningRequestId != c.walletWarningRequestId,
      listener: _onState,
      builder: (context, state) {
        final isLoading = state.status == HomePlansPaymentMethodStatus.loading;
        final isSubmitting =
            state.status == HomePlansPaymentMethodStatus.submitting;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: HomePlansPaymentMethodTheme.bg,
            bottomNavigationBar: PaymentPayBar(
              state: state,
              isSubmitting: isSubmitting,
            ),
            body: Column(
              children: <Widget>[
                const PaymentAppBar(),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(29, 24, 29, 20),
                        sliver: SliverToBoxAdapter(
                          child: PaymentMethodContent(
                            state: state,
                            isLoading: isLoading,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 90)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
