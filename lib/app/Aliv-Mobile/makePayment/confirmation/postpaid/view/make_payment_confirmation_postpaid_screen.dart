import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import '../bloc/make_payment_confirmation_postpaid_bloc.dart';
import '../bloc/make_payment_confirmation_postpaid_event.dart';
import '../bloc/make_payment_confirmation_postpaid_state.dart';
import '../repository/make_payment_confirmation_postpaid_repository_impl.dart';
import '../theme/make_payment_confirmation_postpaid_theme.dart';
import '../widgets/mp_header_card.dart';
import '../../../../../../resources/widgets/custom_payment_break_down_card.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../../../../router/app_routes.dart';

class MakePaymentConfirmationPostPaidScreen extends StatelessWidget {
  const MakePaymentConfirmationPostPaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (buildContext) {
        _ensureDynamicDataLoaded();
        final confirmationBloc = MakePaymentConfirmationPostPaidBloc(
          repository: MakePaymentConfirmationPostPaidRepositoryImpl(),
        );
        confirmationBloc.add(const MakePaymentConfirmationPostPaidStarted());
        return confirmationBloc;
      },
      child: const _MakePaymentConfirmationPostPaidPage(),
    );
  }

  void _ensureDynamicDataLoaded() {
    instance<DeviceLimitsCubit>().loadDeviceLimits();
    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    if (accountInfo == null || accountInfo.idAcc <= 0) return;
    instance<BalanceCubit>().loadBalances(deviceAccountId: accountInfo.idAcc);
  }
}

class _MakePaymentConfirmationPostPaidPage extends StatelessWidget {
  const _MakePaymentConfirmationPostPaidPage();

  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(29, 24, 29, 22);
  static const double _headerToBreakdownGap = 18;
  static const double _bottomScrollSpacer = 90;
  static const int _receiptScallopCount = 12;
  static const TextStyle _receiptLineTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MakePaymentConfirmationPostPaidBloc,
        MakePaymentConfirmationPostPaidState>(
      listenWhen: (previousState, currentState) {
        return previousState.navTarget != currentState.navTarget;
      },
      listener: _handleNavigationIntent,
      builder: (context, state) {
        final confirmationBloc = context.read<MakePaymentConfirmationPostPaidBloc>();

        return MediaQuery(
          data:MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            // Page-level shell.
            backgroundColor: MakePaymentConfirmationPostPaidTheme.bg,
            bottomNavigationBar: _buildBottomBar(
              context,
              confirmationBloc,
              state,
            ),
            body: Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: _buildScrollableContent(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Handles one-time navigation intents emitted by the bloc.
  void _handleNavigationIntent(
    BuildContext context,
    MakePaymentConfirmationPostPaidState state,
  ) {
    if (state.navTarget != MakePaymentConfirmationNavTarget.next) {
      return;
    }
    context.read<MakePaymentConfirmationPostPaidBloc>().add(
          const MakePaymentNavConsumed(),
        );
  }

  // Top app bar section.
  Widget _buildHeader(
    BuildContext context,
    MakePaymentConfirmationPostPaidState state,
  ) {
    return DefaultAppBar(
      title: state.title,
      onBack: () {
        context.pop();
      },
      height: MakePaymentConfirmationPostPaidTheme.appBarHeight,
      backgroundColor: MakePaymentConfirmationPostPaidTheme.appBarBg,
      showBackArrow: true,
      showHome: true,
      onHomeTap: () {
        context.go(AppRoutes.home);
      },
    );
  }

  // Bottom summary + primary action section.
  Widget _buildBottomBar(
    BuildContext context,
    MakePaymentConfirmationPostPaidBloc confirmationBloc,
    MakePaymentConfirmationPostPaidState state,
  ) {
    return DefaultBottomPayBar(
      amountText: state.bottomAmount,
      isVatExclusive: true,
      buttonText: 'continue',
      buttonColor: MakePaymentConfirmationPostPaidTheme.continueBtnBg,
      onPayNow: () {
        _handleContinuePressed(context, confirmationBloc);
      },
    );
  }

  // Main scrollable body section.
  Widget _buildScrollableContent(MakePaymentConfirmationPostPaidState state) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: _contentPadding,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer header section.
                MpHeaderCard(
                  customerName: state.customerName,
                  accountNumber: state.accountNumber,
                  headerLabel: state.headerLabel,
                  amountText: state.amountPill,
                ),
                const SizedBox(height: _headerToBreakdownGap),

                // Payment breakdown section.
                _buildPaymentBreakdownCard(state),
                const SizedBox(height: _bottomScrollSpacer),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdownCard(MakePaymentConfirmationPostPaidState state) {
    return CustomPaymentBreakDownCard(
      backgroundColor: MakePaymentConfirmationPostPaidTheme.receiptBg,
      scallopCount: _receiptScallopCount,
      items: _buildBreakdownItems(state),
    );
  }

  List<CustomPaymentBreakdownLineItem> _buildBreakdownItems( MakePaymentConfirmationPostPaidState state) {
    return <CustomPaymentBreakdownLineItem>[
      _buildBreakdownLineItem(
        label: 'sub total',
        value: state.subtotal,
      ),
      _buildBreakdownLineItem(
        label: 'vat',
        value: state.vat,
      ),
      _buildBreakdownLineItem(
        label: 'total',
        value: state.total,
        isEmphasized: true,
      ),
    ];
  }

  CustomPaymentBreakdownLineItem _buildBreakdownLineItem({
    required String label,
    required String value,
    bool isEmphasized = false,
  }) {
    return CustomPaymentBreakdownLineItem(
      textStyle: _receiptLineTextStyle,
      label: label,
      value: value,
      isEmphasized: isEmphasized,
    );
  }

  void _handleContinuePressed(
    BuildContext context,
    MakePaymentConfirmationPostPaidBloc confirmationBloc,
  ) {
    final balanceDue = instance<BalanceCubit>().state.walletBalance;

    // A negative balance is displayed in parentheses. Do not continue to the
    // payment screen when that value represents an invalid payment amount.
    if (balanceDue < 0) {
      AppToast.show(
        message: 'your payment must not exceed your balance due.',
        type: ToastType.error,
      );
      return;
    }

    confirmationBloc.add(const MakePaymentContinuePressed());
    context.push(AppRoutes.makePaymentPostpaidScreen);
  }
}
