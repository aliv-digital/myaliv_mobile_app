import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/checkout_card_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/saved_card_payment_bottom_sheet.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/payment_option_tile.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../../../../../../router/app_routes.dart';
import '../bloc/top_up_payment_prepaid_bloc.dart';
import '../bloc/top_up_payment_prepaid_event.dart';
import '../bloc/top_up_payment_prepaid_state.dart';
import '../repository/top_up_payment_prepaid_repository.dart';
import '../theme/top_up_payment_prepaid_theme.dart';
import '../theme/top_up_payment_radio_metrics.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/top_up_payment_saved_cards_section.dart';

class TopUpPaymentScreen extends StatelessWidget {
  final double? amount;
  final String? recipientPhone;

  const TopUpPaymentScreen({super.key, this.amount, this.recipientPhone});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TopUpPaymentPrepaidBloc>(
      create: (_) =>
          TopUpPaymentPrepaidBloc(TopUpPaymentPrepaidRepositoryImpl())..add(
            TopUpPaymentStarted(amount: amount, recipientPhone: recipientPhone),
          ),
      child: const _TopUpPaymentPrepaidView(),
    );
  }
}

class _TopUpPaymentPrepaidView extends StatefulWidget {
  const _TopUpPaymentPrepaidView();

  @override
  State<_TopUpPaymentPrepaidView> createState() =>
      _TopUpPaymentPrepaidViewState();
}

class _TopUpPaymentPrepaidViewState extends State<_TopUpPaymentPrepaidView> {
  @override
  void initState() {
    super.initState();
    // Ensure card list is loaded (uses 5-min cache; safe to call repeatedly).
    instance<SavedCardsCubit>().fetchSavedCards();
  }

  void _onState(BuildContext context, TopUpPaymentPrepaidState state) {
    final msg = state.errorMessage;
    if (msg != null && msg.isNotEmpty) {
      AppToast.show(message: msg, type: ToastType.error);
    }

    if (state.navTarget == TopUpPaymentNavTarget.paid) {
      context.push(
        AppRoutes.userProfileReceiptScreen,
        extra: UserProfileReceiptRouteArgs(
          amount: state.summary.total,
          recipientPhone: state.summary.recipientPhone,
          paymentMethod: state.paymentMode == TopUpPaymentMode.payWithCard
              ? 'visa'
              : 'credit card',
        ),
      );
      context.read<TopUpPaymentPrepaidBloc>().add(const PaymentNavConsumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TopUpPaymentPrepaidBloc, TopUpPaymentPrepaidState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage ||
          p.status != c.status ||
          p.navTarget != c.navTarget,
      listener: _onState,
      builder: (context, state) => _TopUpPaymentPrepaidScaffold(state: state),
    );
  }
}

class _TopUpPaymentPrepaidScaffold extends StatelessWidget {
  final TopUpPaymentPrepaidState state;

  const _TopUpPaymentPrepaidScaffold({required this.state});

  String _amountText(double amount) => '\$ ${amount.toStringAsFixed(2)}';

  double _stickyHeaderHeight(BuildContext context) {
    const double appBarContentHeight = 64.0;
    final double topInset = MediaQuery.paddingOf(context).top;
    return appBarContentHeight + topInset;
  }

  Future<void> _onPayNow(BuildContext context) async {
    if (state.paymentMode == TopUpPaymentMode.payWithCard) {
      await _payWithNewCard(context);
      return;
    }
    await _payWithSavedCard(context);
  }

  Future<void> _payWithSavedCard(BuildContext context) async {
    final bloc = context.read<TopUpPaymentPrepaidBloc>();
    final token = state.selectedMethodId?.trim() ?? '';
    if (token.isEmpty) return;

    final card = _cardByToken(token);
    if (card == null) return;

    final confirmed = await SavedCardPaymentBottomSheet.show(
      context,
      cardLabel: card.displayLabel,
      amountText: _amountText(state.summary.total),
    );
    if (confirmed != true) return;

    bloc.add(const PaySavedCardConfirmed());
  }

  Future<void> _payWithNewCard(BuildContext context) async {
    final bloc = context.read<TopUpPaymentPrepaidBloc>();
    final details = await CheckoutCardBottomSheet.show(
      context,
      amountText: _amountText(state.summary.total),
    );
    if (details == null) return;

    bloc.add(PayWithCardConfirmed(details));
  }

  SavedCardModel? _cardByToken(String token) {
    for (final c in instance<SavedCardsCubit>().state.cards) {
      if (c.token == token) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TopUpPaymentPrepaidTheme.background,
      bottomNavigationBar: DefaultBottomPayBar(
        amountText: _amountText(state.summary.total),
        isVatExclusive: !state.summary.vatInclusive,
        isLoading: state.status == TopUpPaymentStatus.paying,
        isButtonEnabled: state.hasMethodSelected,
        buttonColor: TopUpPaymentPrepaidTheme.primary,
        onPayNow: () => _onPayNow(context),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              height: _stickyHeaderHeight(context),
              child: ColoredBox(
                color: TopUpPaymentPrepaidTheme.primary,
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: 64,
                    child: DefaultAppBar(
                      title: 'payment',
                      showHome: true,
                      onBack: () => Navigator.of(context).maybePop(),
                      onHomeTap: () => context.go(AppRoutes.home),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverToBoxAdapter(
              child: _PaymentMethodSection(
                selectedToken: state.selectedMethodId,
                payWithCardSelected:
                    state.paymentMode == TopUpPaymentMode.payWithCard,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final String? selectedToken;
  final bool payWithCardSelected;

  const _PaymentMethodSection({
    required this.selectedToken,
    required this.payWithCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentMethodCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment method',
            style: TopUpPaymentPrepaidTheme.labelSm(context),
          ),
          const SizedBox(height: 16),
          TopUpPaymentSavedCardsSection(
            selectedToken: payWithCardSelected ? null : selectedToken,
            autoSelectFirst: !payWithCardSelected,
            onCardSelected: (card) {
              context.read<TopUpPaymentPrepaidBloc>().add(
                PaymentMethodSelected(card.token),
              );
            },
          ),
          const SizedBox(height: 12),
          PaymentOptionTile(
            title: 'pay with card',
            selected: payWithCardSelected,
            onTap: () => context.read<TopUpPaymentPrepaidBloc>().add(
                  const PayWithCardPressed(),
                ),
            tileRadius: TopUpPaymentRadioMetrics.tileRadius,
            radioSize: TopUpPaymentRadioMetrics.radioSize,
            leadingWidth: TopUpPaymentRadioMetrics.logoBoxWidth,
            leadingHeight: TopUpPaymentRadioMetrics.logoBoxHeight,
            unselectedRadioFill: TopUpPaymentRadioMetrics.unselectedRadioFill,
            leading: const Icon(
              Icons.add,
              size: 18,
              color: Color(0xFF5045A7),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}
