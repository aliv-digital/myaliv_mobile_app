import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/models/auto_renew_prepaid_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/theme/auto_renew_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_payment_method_section.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_prepaid_proceed_action_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/shared/auto_pay_selection_resolver.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/postpaid_pay_with_new_card_flow.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class AutoPayPostpaidScreen extends StatelessWidget {
  const AutoPayPostpaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: instance<SavedCardsCubit>(),
      child: const _AutoPayPostpaidView(),
    );
  }
}

class _AutoPayPostpaidView extends StatefulWidget {
  const _AutoPayPostpaidView();

  @override
  State<_AutoPayPostpaidView> createState() => _AutoPayPostpaidViewState();
}

class _AutoPayPostpaidViewState extends State<_AutoPayPostpaidView> {
  SavedCardModel? _selectedCard;
  bool _noAutoRenewSelected = false;
  bool _payWithCardSelected = false;
  bool _disabling = false;
  bool _paying = false;
  bool _seededFromServer = false;

  @override
  void initState() {
    super.initState();
    instance<SavedCardsCubit>()
        .fetchSavedCards(forceRefresh: true, userType: UserType.postpaid);
  }

  void _seedSelectionFromServer(SavedCardsState state) {
    if (_seededFromServer) return;
    if (!state.isSuccess) return;
    if (_selectedCard != null ||
        _noAutoRenewSelected ||
        _payWithCardSelected) {
      _seededFromServer = true;
      return;
    }

    final autoPayOn =
        instance<AccountInfoCubit>().state.accountInfo?.autoPayInvoice ?? false;

    final selection = AutoPaySelectionResolver.resolve(
      autoEnabled: autoPayOn,
      serverToken: state.autoPayToken,
      savedCards: state.cards,
      // walletAvailable defaults to false — postpaid has no wallet row.
    );

    switch (selection) {
      case SelectSavedCard(card: final card):
        setState(() => _selectedCard = card);
      case SelectNoAutoRenew():
        setState(() => _noAutoRenewSelected = true);
      case SelectPayFromWallet():
        // Unreachable on postpaid (walletAvailable is false); ignore.
        break;
    }
    _seededFromServer = true;
  }

  bool get _canProceed =>
      _selectedCard != null || _noAutoRenewSelected || _payWithCardSelected;

  Future<void> _onProceed() async {
    if (_payWithCardSelected) {
      await _payWithNewCard();
      return;
    }
    if (_noAutoRenewSelected) {
      await _disableAutoPay();
      return;
    }
    final card = _selectedCard;
    if (card == null) return;
    context.push(
      AppRoutes.autoRenewAuthPrepaidScreen,
      extra: AutoRenewAuthArgs(
        paymentMethod: AutoRenewPaymentMethodType.postpaidInvoice,
        cardToken: card.token,
        cardLastDigits: card.lastDigits,
      ),
    );
  }

  /// One-shot payment via a newly entered card, POSTed to `/Order/payment`.
  /// Delegates the entire sheet → service → receipt-nav flow to the shared
  /// [PostpaidPayWithNewCardFlow]; the button just reflects `_paying` so
  /// the user sees a spinner while the request is in flight.
  Future<void> _payWithNewCard() async {
    if (_paying) return;
    setState(() => _paying = true);
    try {
      await PostpaidPayWithNewCardFlow.run(
        context,
        amount: instance<BalanceCubit>().state.walletBalance,
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _disableAutoPay() async {
    if (_disabling) return;
    setState(() => _disabling = true);

    final success = await instance<AccountInfoCubit>().disableAutoPayInvoice();

    if (!mounted) return;
    setState(() => _disabling = false);

    AppToast.show(
      message: success
          ? "We're working on it! Auto-pay takes a few minutes to update. Thank you for your patience."
          : 'Failed to disable auto-pay',
      type: success ? ToastType.success : ToastType.error,
    );

    if (success) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedCardsCubit, SavedCardsState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.cards != curr.cards ||
          prev.autoPayToken != curr.autoPayToken,
      listener: (context, state) => _seedSelectionFromServer(state),
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: AutoRenewPrepaidTheme.pageBg,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeaderDelegate(
                height: AutoRenewPrepaidTheme.appBarHeight +
                    MediaQuery.paddingOf(context).top,
                child: DefaultAppBar(
                  showHome: true,
                  title: 'auto pay',
                  onBack: () => Navigator.of(context).maybePop(),
                  onHomeTap: () => context.go(AppRoutes.home),
                ),
              ),
            ),
            SliverPadding(
              padding: AutoRenewPrepaidTheme.bodyPadding,
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoRenewPaymentMethodSection(
                      selectedCard: _selectedCard,
                      selectedMethodId: _payWithCardSelected
                          ? AutoRenewPaymentMethod.payWithCard.id
                          : _noAutoRenewSelected
                              ? AutoRenewPaymentMethod.none.id
                              : _selectedCard?.token,
                      onCardSelected: (c) => setState(() {
                        _selectedCard = c;
                        _noAutoRenewSelected = false;
                        _payWithCardSelected = false;
                      }),
                      showWalletRow: false,
                      showNoAutoRenewRow: true,
                      showPayWithCardRow: false,
                      payWithCardSelected: _payWithCardSelected,
                      noAutoRenewText: "i don't want to auto pay",
                      onNoAutoRenewSelected: () => setState(() {
                        _selectedCard = null;
                        _noAutoRenewSelected = true;
                        _payWithCardSelected = false;
                      }),
                      onPayWithCardSelected: () => setState(() {
                        _selectedCard = null;
                        _noAutoRenewSelected = false;
                        _payWithCardSelected = true;
                      }),
                    ),
                    const SizedBox(
                      height: AutoRenewPrepaidTheme.dashedToActionGap,
                    ),
                    AutoRenewPrepaidProceedActionButton(
                      isEnabled: _canProceed,
                      isLoading: _disabling || _paying,
                      onPressed: _onProceed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _PinnedHeaderDelegate({required this.height, required this.child});

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
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
