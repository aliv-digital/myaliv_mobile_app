import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../../../../resources/widgets/top_toast.dart';
import '../../../../../../router/app_routes.dart';
import '../../../../core/utils/app_session.dart';
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
    _printRouteArgs();

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
            selectedItems: args.selectedItems,
          ),
        );

        return bloc;
      },
      child: const _HomePlansPaymentMethodView(),
    );
  }

  void _printRouteArgs() {
    debugPrint('HomePlansPaymentMethodScreen args:');
    debugPrint('subscriberType: ${args.subscriberType}');
    debugPrint('amount: ${args.amount}');
    debugPrint('vatNote: ${args.vatNote}');
    debugPrint('selectedItems count: ${args.selectedItems.length}');

    for (final item in args.selectedItems) {
      debugPrint(
        'selectedItem: id=${item.id}, label=${item.label}, title=${item.title}, '
        'subtitle=${item.subtitle}, price=${item.price}, planType=${item.planType}',
      );
    }
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
  int _lastWalletWarningRequestId = 0;

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
    context.read<BalanceCubit>().loadBalances(
      deviceAccountId: accountInfo.idAcc,
    );
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
          walletBalance: balanceState.walletBalance,
          walletBalanceText: walletBalanceText,
          amountText: state.amountText,
        );
        // context.read<HomePlansPaymentMethodBloc>().add(
        //       const HomePlansPayFromWalletPressed(),
        //     );
      },
    );
  }

  Future<void> _openWalletPaymentSheet({
    required double walletBalance,
    required String walletBalanceText,
    required String amountText,
  }) async {
    final paymentBloc = context.read<HomePlansPaymentMethodBloc>();

    if (paymentBloc.state.status == HomePlansPaymentMethodStatus.submitting) {
      return;
    }

    final bool? confirmed = await WalletPaymentBottomSheet.show(
      context,
      walletBalanceText: walletBalanceText,
      amountText: amountText,
      navigateToReceiptOnConfirm: false,
    );

    if (!mounted || confirmed != true) return;

    paymentBloc.add(
      HomePlansPayFromWalletConfirmed(walletBalance: walletBalance),
    );
  }

  void _showWalletWarningIfNeeded(HomePlansPaymentMethodState state) {
    final bool hasNewWarning =
        state.walletWarningRequestId > _lastWalletWarningRequestId;

    if (!hasNewWarning || state.walletWarningMessage == null) return;

    _lastWalletWarningRequestId = state.walletWarningRequestId;

    AppToast.show(message: state.walletWarningMessage!, type: ToastType.error);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      HomePlansPaymentMethodBloc,
      HomePlansPaymentMethodState
    >(
      listenWhen: (p, c) =>
          p.navTarget != c.navTarget ||
          p.errorMessage != c.errorMessage ||
          p.walletWarningRequestId != c.walletWarningRequestId,
      listener: (context, state) {
        _showWalletWarningIfNeeded(state);

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
            context.push(
              AppRoutes.homePlanPurchaseReceiptScreen,
              extra: {'hideSaveCreditCard': true},
            );
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
