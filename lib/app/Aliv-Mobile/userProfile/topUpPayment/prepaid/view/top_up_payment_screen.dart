import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:payment_iframe/payment_iframe.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/saved_card_payment_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/repository/top_up_payment_prepaid_repository.dart';
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
          TopUpPaymentPrepaidBloc(
            repository: TopUpPaymentPrepaidRepositoryImpl(),
          )..add(
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
    if (kDebugMode) {
      debugPrint('Screen : payment');
      debugPrint('class name : TopUpPaymentScreen');
      debugPrint('file name : top_up_payment_screen.dart');
      debugPrint('location : userProfile/topUpPayment/prepaid/view');
    }
    instance<SavedCardsCubit>().fetchSavedCards();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TopUpPaymentPrepaidBloc, TopUpPaymentPrepaidState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage ||
          p.status != c.status ||
          p.navTarget != c.navTarget,
      listener: (context, state) {
        final msg = state.errorMessage;
        if (msg != null && msg.isNotEmpty) {
          AppToast.show(message: msg, type: ToastType.error);
        }

        if (state.navTarget == TopUpPaymentNavTarget.paid) {
          context.read<TopUpPaymentPrepaidBloc>().add(
            const PaymentNavConsumed(),
          );
          final summary = state.summary;
          final isPostpaid =
              context.read<AppUiConfigCubit>().state.isPostpaid;
          final phone = isPostpaid
              ? (summary.recipientPhone?.trim() ?? '')
              : _primaryPhone();
          context.push(
            AppRoutes.userProfileReceiptScreen,
            extra: UserProfileReceiptRouteArgs(
              amount: summary.total,
              recipientPhone: phone,
              paymentMethod: 'credit card',
            ),
          );
        }
      },
      builder: (context, state) => _TopUpPaymentPrepaidScaffold(state: state),
    );
  }

  String _primaryPhone() {
    final account = instance<AccountInfoCubit>().state.accountInfo;
    final primary = account?.primaryPhoneNumber.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return account?.phoneNumber.trim() ?? '';
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

  /// Resolves the phone number for the API path.
  /// Postpaid → recipient's prepaid number. Prepaid → account holder's primary.
  String _resolvePhone(BuildContext context, {bool isPostpaid = false}) {
    if (isPostpaid) {
      final recipient = state.summary.recipientPhone?.trim() ?? '';
      if (recipient.isNotEmpty && recipient.toLowerCase() != 'null') {
        return recipient;
      }
    }
    final account = instance<AccountInfoCubit>().state.accountInfo;
    final primary = account?.primaryPhoneNumber.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return account?.phoneNumber.trim() ?? '';
  }

  void _pushIframePayment(
    BuildContext context, {
    required String phone,
    required Map<String, dynamic> body,
    required String paymentMethod,
    NewCardDetails? cardToSave,
  }) {
    final router = GoRouter.of(context);
    final amount = state.summary.total;
    final receiptPhone = _resolvePhone(
      context,
      isPostpaid: context.read<AppUiConfigCubit>().state.isPostpaid,
    );

    // 3DS endpoint requires RedirectURL and Branch in addition to the card body.
    final fullBody = <String, dynamic>{
      ...body,
      'RedirectURL': 'myaliv://topup-callback',
      'Branch': 'branch',
      'ChannelType': 'selfCare',
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentIFrameScreen(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: DefaultAppBar(
              title: 'payment',
              backgroundColor: TopUpPaymentPrepaidTheme.primary,
              showHome: true,
              onHomeTap: () => router.go(AppRoutes.home),
            ),
          ),
          request: PaymentRequest(
            endpoint: Api.topUp3dsUrl(phone),
            body: fullBody,
            redirectScheme: 'myaliv',
            requiresAuth: true,
            orderVerificationUrl: Api.orderVerificationUrl,
          ),
          onSuccess: (_) => router.push(
            AppRoutes.userProfileReceiptScreen,
            extra: UserProfileReceiptRouteArgs(
              amount: amount,
              recipientPhone: receiptPhone,
              paymentMethod: paymentMethod,
              cardToSave: cardToSave,
            ),
          ),
          onFailure: (msg) =>
              AppToast.show(message: msg, type: ToastType.error),
        ),
      ),
    );
  }

  Future<void> _onPayNow(BuildContext context) async {
    if (state.paymentMode == TopUpPaymentMode.payWithCard) {
      _payWithNewCard(context);
      return;
    }
    await _payWithSavedCard(context);
  }

  Future<void> _payWithSavedCard(BuildContext context) async {
    final token = state.selectedMethodId?.trim() ?? '';
    if (token.isEmpty) return;

    final card = _cardByToken(token);
    if (card == null) return;

    // Capture before async gap.
    final isPostpaid = context.read<AppUiConfigCubit>().state.isPostpaid;

    if (!isPostpaid) {
      final confirmed = await SavedCardPaymentBottomSheet.show(
        context,
        cardLabel: card.displayLabel,
        amountText: _amountText(state.summary.total),
      );
      if (confirmed != true) return;
    }

    if (!context.mounted) return;

    if (isPostpaid) {
      context.read<TopUpPaymentPrepaidBloc>().add(const PayPostpaidSavedCard());
    } else {
      context.read<TopUpPaymentPrepaidBloc>().add(const PaySavedCardConfirmed());
    }
  }

  void _payWithNewCard(BuildContext context) {
    final isPostpaid = context.read<AppUiConfigCubit>().state.isPostpaid;
    final phone = _resolvePhone(context, isPostpaid: isPostpaid);
    if (phone.isEmpty) {
      AppToast.show(
        message: 'Phone number unavailable. Please try again.',
        type: ToastType.error,
      );
      return;
    }

    _pushIframePayment(
      context,
      phone: phone,
      body: {'Amount': state.summary.total},
      paymentMethod: 'visa',
    );
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
