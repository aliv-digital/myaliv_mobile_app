import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_request.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/saved_card_payment_bottom_sheet.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
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
  /// PAY-001: set when pay now is tapped without a payment method.
  bool _showPaymentMethodError = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint("Screen : payment");
      debugPrint("class name : TopUpPaymentScreen");
      debugPrint("file name : top_up_payment_screen.dart");
      debugPrint("location : userProfile/topUpPayment/prepaid/view");
    }
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
          recipientPhone: _receiptPhone(state.summary.recipientPhone),
          paymentMethod: state.paymentMode == TopUpPaymentMode.payWithCard
              ? 'visa'
              : 'credit card',
          cardToSave: state.paymentMode == TopUpPaymentMode.payWithCard
              ? state.lastNewCardDetails
              : null,
        ),
      );
      context.read<TopUpPaymentPrepaidBloc>().add(const PaymentNavConsumed());
    }
  }

  /// Returns the phone number to display on the receipt.
  /// For postpaid topping up another prepaid number, show the recipient's
  /// number. For own-number top-up, show the account holder's primary number.
  String? _receiptPhone(String? routeValue) {
    final incoming = routeValue?.trim() ?? '';
    if (incoming.isNotEmpty && incoming.toLowerCase() != 'null')
      return incoming;

    final account = instance<AccountInfoCubit>().state.accountInfo;
    final primary = account?.primaryPhoneNumber.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return account?.phoneNumber.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TopUpPaymentPrepaidBloc, TopUpPaymentPrepaidState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage ||
          p.status != c.status ||
          p.navTarget != c.navTarget,
      listener: _onState,
      builder: (context, state) => _TopUpPaymentPrepaidScaffold(
        state: state,
        // Clears itself once a card or "pay with card" is selected.
        showPaymentMethodError:
            _showPaymentMethodError && !state.hasMethodSelected,
        onMissingPaymentMethod: () =>
            setState(() => _showPaymentMethodError = true),
      ),
    );
  }
}

class _TopUpPaymentPrepaidScaffold extends StatelessWidget {
  final TopUpPaymentPrepaidState state;
  final bool showPaymentMethodError;
  final VoidCallback onMissingPaymentMethod;

  const _TopUpPaymentPrepaidScaffold({
    required this.state,
    required this.showPaymentMethodError,
    required this.onMissingPaymentMethod,
  });

  String _amountText(double amount) => AppUtils.formatPrice(amount);

  double _stickyHeaderHeight(BuildContext context) {
    const double appBarContentHeight = 64.0;
    final double topInset = MediaQuery.paddingOf(context).top;
    return appBarContentHeight + topInset;
  }

  Future<void> _onPayNow(BuildContext context) async {
    if (!state.hasMethodSelected) {
      onMissingPaymentMethod();
      return;
    }
    if (state.paymentMode == TopUpPaymentMode.payWithCard) {
      _payWith3DS(context);
      return;
    }
    await _payWithSavedCard(context);
  }

  void _payWith3DS(BuildContext context) {
    final bloc = context.read<TopUpPaymentPrepaidBloc>();
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    final recipientPhone = state.summary.recipientPhone?.trim() ?? '';
    final account = instance<AccountInfoCubit>().state.accountInfo;
    final primary = account?.primaryPhoneNumber.trim() ?? '';
    final phone = recipientPhone.isNotEmpty
        ? recipientPhone
        : (primary.isNotEmpty ? primary : (account?.phoneNumber.trim() ?? ''));

    if (phone.isEmpty) {
      AppToast.show(
        message: 'Phone number unavailable. Please try again.',
        type: ToastType.error,
      );
      return;
    }

    final request = PaymentRequest(
      url: Api.topUp3DSUrl(phone),
      body: ChangeBundleRequestFactory.topUpBodyFor3DS(
        amount: state.summary.total,
      ),
      redirectScheme: 'myaliv',
    );

    navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PaymentIFrameScreen(
          request: request,
          appBarBgColor: TopUpPaymentPrepaidTheme.primary,
          title: 'payment',
          onSuccess: (PaymentSuccess success) {
            navigator.pop();
            bloc.add(Pay3DSSucceeded(orderId: success.orderId));
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

  Future<void> _payWithSavedCard(BuildContext context) async {
    final bloc = context.read<TopUpPaymentPrepaidBloc>();
    final token = state.selectedMethodId?.trim() ?? '';
    if (token.isEmpty) return;

    final card = _cardByToken(token);
    if (card == null) return;

    final isPostpaid = context.read<AppUiConfigCubit>().state.isPostpaid;
    if (isPostpaid) {
      // Postpaid users top up another prepaid number directly with the
      // selected saved card, so this flow does not need a confirmation sheet.
      bloc.add(const PayPostpaidSavedCard());
      return;
    }

    // Keep the existing confirmation flow unchanged for prepaid users.
    final confirmed = await SavedCardPaymentBottomSheet.show(
      context,
      cardLabel: card.displayLabel,
      amountText: _amountText(state.summary.total),
    );
    if (confirmed != true) return;

    bloc.add(const PaySavedCardConfirmed());
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
        // Tappable without a method so PAY-001 can explain itself.
        isButtonEnabled: state.hasMethodSelected || !state.isBusy,
        buttonColor: TopUpPaymentPrepaidTheme.primary,
        onPayNow: () => _onPayNow(context),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              height: _stickyHeaderHeight(context),
              child: DefaultAppBar(
                title: 'payment',
                backgroundColor: TopUpPaymentPrepaidTheme.primary,
                showHome: true,
                onBack: () => Navigator.of(context).maybePop(),
                onHomeTap: () => context.go(AppRoutes.home),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PaymentMethodSection(
                    selectedToken: state.selectedMethodId,
                    payWithCardSelected:
                        state.paymentMode == TopUpPaymentMode.payWithCard,
                  ),
                  if (showPaymentMethodError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'choose a payment method to continue',
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
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
            leading: const Icon(Icons.add, size: 18, color: Color(0xFF5045A7)),
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
