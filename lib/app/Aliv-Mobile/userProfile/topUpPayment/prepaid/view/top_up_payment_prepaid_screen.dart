import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/widgets/pay_with_card_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/widgets/payment_method_tile.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';

import '../../../../../../core/utils/app_session.dart';
import '../../../../../../router/app_routes.dart';
import '../bloc/top_up_payment_prepaid_bloc.dart';
import '../bloc/top_up_payment_prepaid_event.dart';
import '../bloc/top_up_payment_prepaid_state.dart';
import '../repository/top_up_payment_prepaid_repository.dart';
import '../theme/top_up_payment_prepaid_theme.dart';
import '../widgets/payment_method_card.dart';

class TopUpPaymentPrepaidScreen extends StatelessWidget {
  const TopUpPaymentPrepaidScreen({super.key});

  // Creates the feature Bloc and triggers initial loading.
  TopUpPaymentPrepaidBloc _createTopUpPaymentPrepaidBloc(BuildContext context) {
    final TopUpPaymentPrepaidRepository repository =
        TopUpPaymentPrepaidRepositoryImpl();
    final TopUpPaymentPrepaidBloc bloc = TopUpPaymentPrepaidBloc(repository);
    bloc.add(const TopUpPaymentStarted());
    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TopUpPaymentPrepaidBloc>(
      create: _createTopUpPaymentPrepaidBloc,
      child: const _TopUpPaymentPrepaidView(),
    );
  }
}

class _TopUpPaymentPrepaidView extends StatelessWidget {
  const _TopUpPaymentPrepaidView();

  // Controls when one-off side effects should run.
  bool _shouldHandleStateChange(
    TopUpPaymentPrepaidState previousState,
    TopUpPaymentPrepaidState currentState,
  ) {
    return previousState.errorMessage != currentState.errorMessage ||
        previousState.status != currentState.status;
  }

  // Handles transient UI feedback (for example, error snackbar).
  void _handleStateChange(
    BuildContext context,
    TopUpPaymentPrepaidState state,
  ) {
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TopUpPaymentPrepaidBloc, TopUpPaymentPrepaidState>(
      listenWhen: _shouldHandleStateChange,
      listener: _handleStateChange,
      builder: (BuildContext context, TopUpPaymentPrepaidState state) {
        return _TopUpPaymentPrepaidScaffold(state: state);
      },
    );
  }
}

class _TopUpPaymentPrepaidScaffold extends StatelessWidget {
  final TopUpPaymentPrepaidState state;

  const _TopUpPaymentPrepaidScaffold({
    required this.state,
  });

  // Converts numeric amount to display text used by bottom pay bar.
  String _amountText(double amount) {
    return '\$ ${amount.toStringAsFixed(2)}';
  }

  // Computes sticky header height including safe-area inset.
  double _stickyHeaderHeight(BuildContext context) {
    const double appBarContentHeight = 64.0;
    final double topInset = MediaQuery.paddingOf(context).top;
    return appBarContentHeight + topInset;
  }

  // Dispatches pay action to Bloc.
  void _onPayNowPressed(BuildContext context) {
    context.read<TopUpPaymentPrepaidBloc>().add(const PayNowPressed());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TopUpPaymentPrepaidTheme.background,
      bottomNavigationBar: DefaultBottomPayBar(
        amountText: _amountText(state.summary.total),
        isVatExclusive: !state.summary.vatInclusive,
        isLoading: state.status == TopUpPaymentStatus.paying,
        buttonColor: TopUpPaymentPrepaidTheme.primary,
        onPayNow: () {
          // _onPayNowPressed(context);
          AppSession.isTopUp = true;
          context.push(AppRoutes.guestTopUpReceipt);
        },
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          // Sticky header that remains visible while body content scrolls.
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
                        onHomeTap: () => context.go(AppRoutes.home)
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content section.
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverToBoxAdapter(
              child: _PaymentMethodSection(state: state),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final TopUpPaymentPrepaidState state;

  const _PaymentMethodSection({
    required this.state,
  });

  // Builds payment method rows from current state.
  List<Widget> _buildPaymentMethodTiles(BuildContext context) {
    return state.methods.map((paymentMethod) {
      final bool isSelected = state.selectedMethodId == paymentMethod.id;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PaymentMethodTile(
          logoAsset: paymentMethod.logoAsset,
          title: paymentMethod.title,
          subtitle: 'expiry ${paymentMethod.expiry}',
          isSelected: isSelected,
          onTap: () {
            context.read<TopUpPaymentPrepaidBloc>().add(
              PaymentMethodSelected(paymentMethod.id),
            );
          },
        ),
      );
    }).toList(growable: false);
  }

  // Handles tap on "pay with card" tile.
  void _onPayWithCardPressed(BuildContext context) {
    context.read<TopUpPaymentPrepaidBloc>().add(const PayWithCardPressed());
    // TODO: Navigate to add card screen when route is ready.
  }

  @override
  Widget build(BuildContext context) {
    return PaymentMethodCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'payment method',
            style: TopUpPaymentPrepaidTheme.labelSm(context),
          ),
          const SizedBox(height: 16),
          ..._buildPaymentMethodTiles(context),
          PayWithCardTile(
            onTap: () => _onPayWithCardPressed(context),
          ),
        ],
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedHeaderDelegate({
    required this.height,
    required this.child,
  });

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
