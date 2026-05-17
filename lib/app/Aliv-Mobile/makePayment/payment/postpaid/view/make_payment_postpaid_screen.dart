import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/utils/app_session.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../router/app_routes.dart';
import '../../../../../Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/model/guest_pay_bill_receipt_args.dart';
import '../bloc/make_payment_postpaid_bloc.dart';
import '../bloc/make_payment_postpaid_event.dart';
import '../bloc/make_payment_postpaid_state.dart';
import '../repository/make_payment_postpaid_repository_impl.dart';
import '../theme/make_payment_postpaid_theme.dart';
import '../widgets/mp_payment_due_card.dart';
import '../widgets/mp_payment_method_section.dart';
import '../widgets/mp_terms_checkbox.dart';

class MakePaymentPostPaidScreen extends StatelessWidget {
  const MakePaymentPostPaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (buildContext) {
        final makePaymentBloc = MakePaymentPostPaidBloc(
          repository: MakePaymentPostPaidRepositoryImpl(),
        );
        makePaymentBloc.add(const MakePaymentPostPaidStarted());
        instance<SavedCardsCubit>().fetchSavedCards();
        return makePaymentBloc;
      },
      child: const _MakePaymentPostPaidPage(),
    );
  }
}

class _MakePaymentPostPaidPage extends StatelessWidget {
  const _MakePaymentPostPaidPage();

  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(29, 24, 29, 22);
  static const double _paymentDueToTermsGap = 14;
  static const double _termsToMethodsGap = 17;
  static const double _bottomScrollSpacer = 90;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MakePaymentPostPaidBloc, MakePaymentPostPaidState>(
      listenWhen: (previousState, currentState) {
        return previousState.navTarget != currentState.navTarget;
      },
      listener: _handleNavigationIntent,
      builder: (context, state) {
        final paymentBloc = context.read<MakePaymentPostPaidBloc>();

        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            // Page-level layout shell.
            backgroundColor: MakePaymentPostPaidTheme.bg,
            bottomNavigationBar: _buildBottomBar(paymentBloc, state, context),
            body: Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: _buildScrollableContent(paymentBloc, state, context),
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
    MakePaymentPostPaidState state,
  ) {
    if (state.navTarget != MpNavTarget.next) return;
    context.read<MakePaymentPostPaidBloc>().add(const MpNavConsumed());
  }

  // Top app bar section.
  Widget _buildHeader(BuildContext context, MakePaymentPostPaidState state) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: MakePaymentPostPaidTheme.appBarHeight,
        child: DefaultAppBar(
          title: state.title,
          height: MakePaymentPostPaidTheme.appBarHeight,
          backgroundColor: MakePaymentPostPaidTheme.appBarBg,
          showBackArrow: true,
          showHome: true,
          onHomeTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  // Bottom summary + primary action section.
  Widget _buildBottomBar(
    MakePaymentPostPaidBloc paymentBloc,
    MakePaymentPostPaidState state,
    BuildContext context,
  ) {
    return DefaultBottomPayBar(
      amountText: '\$ ${_resolvePayAmount(state).toStringAsFixed(2)}',
      isButtonEnabled: state.canPayNow,
      backgroundColor: MakePaymentPostPaidTheme.bottomBarBg,
      buttonColor: MakePaymentPostPaidTheme.primary,
      disabledButtonColor: MakePaymentPostPaidTheme.payButtonDisabled,
      // onPayNow: () => paymentBloc.add(const MpPayNowPressed()),
      onPayNow: () {
        AppSession.appRoute = 'postpaidPayment';
        final now = DateTime.now();
        final phone = _formatPhone(
          instance<DeviceLimitsCubit>().state.deviceLimits?.tn ?? '',
        );
        final amount = _resolvePayAmount(state);
        context.push(
          AppRoutes.guestPayBillReceipt,
          extra: GuestPayBillReceiptArgs(
            serviceName: 'ALIV Postpaid',
            identifierLabel: 'phone no.',
            identifierValue: phone,
            amount: amount,
            dateText: DateFormat('MMM d, yyyy').format(now),
            timeText: DateFormat('hh:mm a').format(now).toLowerCase(),
          ),
        );
      },
    );
  }

  // Main scrollable content section.
  Widget _buildScrollableContent(
    MakePaymentPostPaidBloc paymentBloc,
    MakePaymentPostPaidState state,
    BuildContext context,
  ) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: _contentPadding,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment amount selection section.
                MpPaymentDueCard(
                  amountText: state.paymentDueAmount,
                  selectedOption: state.amountOption,
                  customAmount: state.customAmount,
                  onOptionChanged: (selectedOption) {
                    paymentBloc.add(MpAmountOptionChanged(selectedOption));
                  },
                  onCustomAmountChanged: (customAmountText) {
                    paymentBloc.add(MpCustomAmountChanged(customAmountText));
                  },
                ),
                const SizedBox(height: _paymentDueToTermsGap),

                // Terms acceptance section.
                MpTermsCheckbox(
                  value: state.termsAccepted,
                  onChanged: (isAccepted) {
                    paymentBloc.add(MpTermsToggled(isAccepted));
                  },
                  onTermsTap: () async {
                    await showTermsAndConditionsModal(
                      context,
                      badgeSize: 48,
                      badgeInnerSize: 34,
                      badgeCoreSize: 24,
                      badgeIconWidth: 16,
                      badgeIconHeight: 16,
                      closeButtonSize: 30,
                    );
                  },
                ),
                const SizedBox(height: _termsToMethodsGap),

                // Payment method selection section.
                MpPaymentMethodSection(
                  selectedToken: state.selectedMethodToken,
                  onCardSelected: (card) {
                    paymentBloc.add(MpPaymentMethodSelected(card.token));
                  },
                  onAddCard: () {},
                ),
                const SizedBox(height: _bottomScrollSpacer),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Resolves the actual amount to charge based on the user's choice:
/// - "other amount" + parsable positive value → custom amount
/// - otherwise → current balance due from BalanceCubit
double _resolvePayAmount(MakePaymentPostPaidState state) {
  if (state.amountOption == MpAmountOption.other) {
    final parsed = double.tryParse(state.customAmount.trim());
    if (parsed != null && parsed > 0) return parsed;
  }
  return instance<BalanceCubit>().state.walletBalance;
}

String _formatPhone(String phone) {
  if (phone.isEmpty) return '';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  if (digits.length == 11 && digits.startsWith('1')) {
    return '${digits.substring(1, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
  }
  return phone;
}
