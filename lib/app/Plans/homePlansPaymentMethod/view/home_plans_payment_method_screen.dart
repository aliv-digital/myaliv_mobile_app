import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/bloc/home_plan_purchase_receipt_state.dart';

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
            phoneNumber: args.phoneNumber,
            selectedItems: args.selectedItems,
            forceNow: args.forceNow,
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
    debugPrint('phoneNumber: ${args.phoneNumber}');
    debugPrint('amount: ${args.amount}');
    debugPrint('vatNote: ${args.vatNote}');
    debugPrint('forceNow: ${args.forceNow}');
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
        context.push(
          AppRoutes.homePlanPurchaseReceiptScreen,
          extra: _buildReceiptExtra(
            state,
            paymentMethod: _selectedPaymentMethodLabel(state),
          ),
        );
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

  Map<String, dynamic> _buildReceiptExtra(
    HomePlansPaymentMethodState state, {
    required String paymentMethod,
  }) {
    final now = DateTime.now();
    final dateText = DateFormat('MMM d, yyyy').format(now);
    final timeText = DateFormat('h:mm a').format(now).toLowerCase();
    final phoneNumber = _receiptPhoneNumber(state);
    final emailAddress = _receiptEmailAddress();

    return <String, dynamic>{
      'hideSaveCreditCard': paymentMethod.toLowerCase() == 'wallet',
      'phoneNumber': phoneNumber,
      'amount': state.amount,
      'dateText': dateText,
      'timeText': timeText,
      'paymentMethod': paymentMethod,
      'statusMessage':
          'It will take a few moments for the plan to appear on the account.',
      'leftType': 'service',
      'rightType': state.isPrepaidUser ? 'prepaid' : 'postpaid',
      'details': _buildReceiptDetails(
        state,
        dateText: dateText,
        timeText: timeText,
        phoneNumber: phoneNumber,
        emailAddress: emailAddress,
        paymentMethod: paymentMethod,
      ),
      // Keep the original payment-screen payload available to the route.
      'subscriberType': state.subscriberType,
      'vatNote': state.vatNote,
      'selectedItems': state.selectedItems,
      'selectedMethodId': state.selectedMethodId,
      'paymentMethods': state.methods,
    };
  }

  List<HomePlanPurchaseReceiptDetailItem> _buildReceiptDetails(
    HomePlansPaymentMethodState state, {
    required String dateText,
    required String timeText,
    required String phoneNumber,
    required String emailAddress,
    required String paymentMethod,
  }) {
    final details = <HomePlanPurchaseReceiptDetailItem>[
      for (final item in state.selectedItems)
        HomePlanPurchaseReceiptDetailItem(
          label: item.label.trim().isEmpty
              ? _planTypeLabel(item.planType)
              : item.label,
          value: item.title,
        ),
      HomePlanPurchaseReceiptDetailItem(label: 'date', value: dateText),
      HomePlanPurchaseReceiptDetailItem(label: 'time', value: timeText),
    ];

    if (phoneNumber.isNotEmpty) {
      details.add(
        HomePlanPurchaseReceiptDetailItem(
          label: 'phone no.',
          value: phoneNumber,
        ),
      );
    }

    if (emailAddress.isNotEmpty) {
      details.add(
        HomePlanPurchaseReceiptDetailItem(
          label: 'email address',
          value: emailAddress,
        ),
      );
    }

    details.add(
      HomePlanPurchaseReceiptDetailItem(
        label: 'payment method',
        value: paymentMethod,
      ),
    );

    if (state.vatNote.trim().isNotEmpty) {
      details.add(
        HomePlanPurchaseReceiptDetailItem(label: 'vat', value: state.vatNote),
      );
    }

    return details;
  }

  String _selectedPaymentMethodLabel(HomePlansPaymentMethodState state) {
    final selectedMethodId = state.selectedMethodId;
    HomePlansSavedPaymentMethod? method;
    for (final item in state.methods) {
      if (item.id == selectedMethodId) {
        method = item;
        break;
      }
    }

    if (method == null) return 'credit card';
    if (method.isChargeToMyAccount) return 'charge to my account';

    return switch (method.brand) {
      HomePlansCardBrand.visa => 'visa ending ${method.ending}',
      HomePlansCardBrand.mastercard => 'mastercard ending ${method.ending}',
      HomePlansCardBrand.unknown => 'card ending ${method.ending}',
    };
  }

  String _planTypeLabel(HomePlansPaymentPlanType type) {
    return switch (type) {
      HomePlansPaymentPlanType.primary => 'primary plan',
      HomePlansPaymentPlanType.secondary => 'secondary plan',
      HomePlansPaymentPlanType.standalone => 'plan',
    };
  }

  String _receiptPhoneNumber(HomePlansPaymentMethodState state) {
    final accountInfo = context.read<AccountInfoCubit>().state.accountInfo;
    final phoneNumber = _firstNonEmpty([
      state.phoneNumber,
      accountInfo?.phoneNumber,
      accountInfo?.primaryPhoneNumber,
      accountInfo?.username,
    ]);

    return _formatMobileNumberForReceipt(phoneNumber);
  }

  String _formatMobileNumberForReceipt(String value) {
    final trimmed = value.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return trimmed;

    if (digitsOnly.length == 10) {
      return '${digitsOnly.substring(0, 3)}-'
          '${digitsOnly.substring(3, 6)}-'
          '${digitsOnly.substring(6)}';
    }

    return trimmed;
  }

  String _receiptEmailAddress() {
    final accountInfo = context.read<AccountInfoCubit>().state.accountInfo;
    return _firstNonEmpty([accountInfo?.email]);
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomePlansPaymentMethodBloc,
        HomePlansPaymentMethodState>(
      listenWhen: (p, c) =>
          p.navTarget != c.navTarget ||
          p.errorMessage != c.errorMessage ||
          p.walletWarningRequestId != c.walletWarningRequestId,
      listener: (context, state) {
        _showWalletWarningIfNeeded(state);

        // Show API/validation errors from bloc.
        if (state.errorMessage != null && state.status == HomePlansPaymentMethodStatus.failure) {

          AppToast.show(
              message: state.errorMessage!.toString(),
              type:ToastType.error
          );
          // ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
              extra: _buildReceiptExtra(state, paymentMethod: 'wallet'),
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
                  extra: _buildReceiptExtra(
                    state,
                    paymentMethod: _selectedPaymentMethodLabel(state),
                  ),
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
