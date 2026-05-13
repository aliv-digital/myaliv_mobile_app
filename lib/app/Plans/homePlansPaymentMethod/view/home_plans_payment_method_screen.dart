import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../../../../router/app_routes.dart';
import '../../../../core/utils/app_session.dart';
import '../../../Aliv-Mobile/autoRenew/autoRenewPage/prepaid/theme/auto_renew_prepaid_theme.dart';
import '../../../Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/bottomsheet/wallet_payment_bottom_sheet.dart';
import '../bloc/home_plans_payment_method_bloc.dart';
import '../bloc/home_plans_payment_method_event.dart';
import '../bloc/home_plans_payment_method_state.dart';
import '../model/home_plans_payment_method_models.dart';
import '../repository/home_plans_payment_method_repository_impl.dart';
import '../theme/home_plans_payment_method_theme.dart';
import '../widgets/home_plans_payment_method_section.dart';

class HomePlansPaymentMethodScreen extends StatelessWidget {
  final HomePlansPaymentMethodRouteArgs args;

  const HomePlansPaymentMethodScreen({
    super.key,
    this.args = const HomePlansPaymentMethodRouteArgs(),
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocProvider(
      create: (_) {
        final HomePlansPaymentMethodBloc bloc = HomePlansPaymentMethodBloc(
          repository: HomePlansPaymentMethodRepositoryImpl(),
        );

        // Send the initial screen configuration to the bloc.
        bloc.add(
          HomePlansPaymentMethodStarted(
            subscriberType: args.subscriberType,
            amount: args.amount,
            vatNote: args.vatNote,
          ),
        );

        return bloc;
      },
      child: const _HomePlansPaymentMethodView(),
    );
  }
}

class _HomePlansPaymentMethodView extends StatefulWidget {
  const _HomePlansPaymentMethodView();

  @override
  State<_HomePlansPaymentMethodView> createState() =>
      _HomePlansPaymentMethodViewState();
}

class _HomePlansPaymentMethodViewState
    extends State<_HomePlansPaymentMethodView> {
  @override
  void initState() {
    super.initState();
    _loadWalletBalanceIfPossible();
  }

  void _loadWalletBalanceIfPossible() {
    final accountInfo = context.read<AccountInfoCubit>().state.accountInfo;
    if (accountInfo == null || accountInfo.idAcc <= 0) return;

    // BalanceCubit is the app-wide owner of wallet balance. It will reuse its
    // cached API result when fresh, and only fetch again when needed.
    context
        .read<BalanceCubit>()
        .loadBalances(deviceAccountId: accountInfo.idAcc);
  }

  Widget _buildPaymentMethodContent(
    BuildContext context,
    HomePlansPaymentMethodState state,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocBuilder<BalanceCubit, BalanceState>(
      builder: (context, balanceState) {
        return _buildPaymentMethodSection(context, state, balanceState);
      },
    );
  }

  Widget _buildPaymentMethodSection(
    BuildContext context,
    HomePlansPaymentMethodState state,
    BalanceState balanceState,
  ) {
    final walletBalanceText = '\$${balanceState.walletBalanceFormatted}';

    return HomePlansPaymentMethodSection(
      methods: state.methods,
      selectedId: state.selectedMethodId,
      onSelect: (String id) {
        context.read<HomePlansPaymentMethodBloc>().add(
              HomePlansPaymentMethodSelected(id),
            );
      },
      onPayWithCard: () {
        AppSession.appRoute = 'prepaidPlan';
        context.push(AppRoutes.homePlanPurchaseReceiptScreen);
        // context.read<HomePlansPaymentMethodBloc>().add(
        //       const HomePlansPayWithCardPressed(),
        //     );
      },
      showPayFromWallet: state.isPrepaidUser,
      walletBalanceText: walletBalanceText,
      onPayFromWallet: () {
        _openWalletPaymentSheet(
          context: context,
          walletBalanceText: walletBalanceText,
          amountText: state.amountText,
        );
        // context.read<HomePlansPaymentMethodBloc>().add(
        //       const HomePlansPayFromWalletPressed(),
        //     );
      },
    );
  }

  void _openWalletPaymentSheet({
    required BuildContext context,
    required String walletBalanceText,
    required String amountText,
  }) {
    AppSession.appRoute = 'prepaidPlanPurchase';
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AutoRenewPrepaidTheme.sheetBg,
      shape: AutoRenewPrepaidTheme.walletPaymentSheetShape(),
      builder: (_) => WalletPaymentBottomSheet(
        walletBalanceText: walletBalanceText,
        amountText: amountText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomePlansPaymentMethodBloc,
        HomePlansPaymentMethodState>(
      listenWhen: (p, c) =>
          p.navTarget != c.navTarget || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        // Show API/validation errors from bloc.
        if (state.errorMessage != null &&
            state.status == HomePlansPaymentMethodStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        // Handle one-time navigation targets from bloc.
        if (state.navTarget != HomePlansPaymentMethodNavTarget.none) {
          if (state.navTarget == HomePlansPaymentMethodNavTarget.addCard) {
            // TODO: Add route when add-card screen is ready.
          } else if (state.navTarget ==
              HomePlansPaymentMethodNavTarget.wallet) {
            // TODO: Add route when wallet payment screen is ready.
          } else if (state.navTarget == HomePlansPaymentMethodNavTarget.paid) {
            // TODO: Add route when payment success screen is ready.
          }

          context.read<HomePlansPaymentMethodBloc>().add(
                const HomePlansPaymentNavConsumed(),
              );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == HomePlansPaymentMethodStatus.loading;
        final isSubmitting =
            state.status == HomePlansPaymentMethodStatus.submitting;

        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: HomePlansPaymentMethodTheme.bg,
            bottomNavigationBar: DefaultBottomPayBar(
              amountText: state.amountText,
              isVatExclusive: state.vatNote.toLowerCase().contains(
                    'no vat applied',
                  ),
              isButtonEnabled: state.isPayNowEnabled,
              isLoading: isSubmitting,
              buttonColor: HomePlansPaymentMethodTheme.payBtnBg,
              onPayNow: () {
                AppSession.appRoute = 'prepaidPlan';
                context.push(
                  AppRoutes.homePlanPurchaseReceiptScreen,
                  extra: {'hideSaveCreditCard': true},
                );
                // context
                //     .read<HomePlansPaymentMethodBloc>()
                //     .add(const HomePlansPayNowPressed());
              },
            ),
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: HomePlansPaymentMethodTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: 'payment',
                      height: HomePlansPaymentMethodTheme.appBarHeight,
                      backgroundColor: HomePlansPaymentMethodTheme.appBarBg,
                      showBackArrow: true,
                      showHome: true,
                      onBack: () => context.pop(),
                      onHomeTap: () => context.go(AppRoutes.home),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(29, 24, 29, 20),
                        sliver: SliverToBoxAdapter(
                          child: _buildPaymentMethodContent(
                            context,
                            state,
                            isLoading,
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
