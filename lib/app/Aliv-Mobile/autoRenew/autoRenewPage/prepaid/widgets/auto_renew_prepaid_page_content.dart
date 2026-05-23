import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import '../bloc/auto_renew_prepaid_bloc.dart';
import '../bloc/auto_renew_prepaid_event.dart';
import '../bloc/auto_renew_prepaid_state.dart';
import '../models/auto_renew_prepaid_models.dart';
import '../theme/auto_renew_prepaid_theme.dart';
import 'auto_renew_payment_method_section.dart';
import 'auto_renew_prepaid_proceed_action_button.dart';

class AutoRenewPrepaidPageContent extends StatelessWidget {
  const AutoRenewPrepaidPageContent({super.key});

  // ==================== Page Scaffold ====================
  // Build the visual shell and bind bloc state to UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AutoRenewPrepaidTheme.pageBg,
      body: SafeArea(
        child: BlocBuilder<AutoRenewPrepaidBloc, AutoRenewPrepaidState>(
          builder: _buildFromState,
        ),
      ),
    );
  }

  // ==================== State Builder ====================
  // Rebuild slivers whenever feature state changes.
  Widget _buildFromState(
    BuildContext context,
    AutoRenewPrepaidState autoRenewPrepaidState,
  ) {
    final AutoRenewPrepaidBloc autoRenewPrepaidBloc =
        context.read<AutoRenewPrepaidBloc>();

    return CustomScrollView(
      slivers: [
        _buildPinnedAppBar(context, autoRenewPrepaidBloc),
        if (autoRenewPrepaidState.loadStatus == AutoRenewLoadStatus.loading)
          _buildLoadingSliver()
        else
          _buildContentSliver(
            context,
            autoRenewPrepaidState,
            autoRenewPrepaidBloc,
          ),
      ],
    );
  }

  // ==================== Pinned App Bar ====================
  // Keep top actions visible while content scrolls.
  Widget _buildPinnedAppBar(
    BuildContext context,
    AutoRenewPrepaidBloc autoRenewPrepaidBloc,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedHeaderDelegate(
        height: AutoRenewPrepaidTheme.appBarHeight,
        child: DefaultAppBar(
          showHome: true,
          title: 'auto renew',
          onBack: () {
            Navigator.of(context).maybePop();
          },
          onHomeTap: () {
            // autoRenewPrepaidBloc.add(const AutoRenewHomePressed());
            context.go(AppRoutes.home);
          },
        ),
      ),
    );
  }

  // ==================== Loading State ====================
  // Use full remaining space for loading feedback.
  Widget _buildLoadingSliver() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  // ==================== Content Wrapper ====================
  // Apply feature-level page padding around content sections.
  Widget _buildContentSliver(
    BuildContext context,
    AutoRenewPrepaidState autoRenewPrepaidState,
    AutoRenewPrepaidBloc autoRenewPrepaidBloc,
  ) {
    return SliverPadding(
      padding: AutoRenewPrepaidTheme.bodyPadding,
      sliver: SliverToBoxAdapter(
        child: _buildContentColumn(
          context,
          autoRenewPrepaidState,
          autoRenewPrepaidBloc,
        ),
      ),
    );
  }

  // ==================== Content Sections ====================
  // Render payment method list, add-card action, and proceed action.
  Widget _buildContentColumn(
    BuildContext context,
    AutoRenewPrepaidState autoRenewPrepaidState,
    AutoRenewPrepaidBloc autoRenewPrepaidBloc,
  ) {
    final isAutoRenewToggling =
        context.watch<DeviceLimitsCubit>().state.isTogglingAutoRenew;
    final isWalletRenewLoading =
        autoRenewPrepaidState.isWalletSelected && isAutoRenewToggling;
    final isNoRenewLoading =
        autoRenewPrepaidState.isNoAutoRenewSelected && isAutoRenewToggling;

    final BalanceState balanceState = context.watch<BalanceCubit>().state;
    final String walletBalanceText = BalanceCurrencyFormatterService.format(
      balanceState.walletBalance,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoRenewPaymentMethodSection(
          selectedCard: autoRenewPrepaidState.selectedCard,
          selectedMethodId: autoRenewPrepaidState.selectedMethodId,
          onCardSelected: (card) {
            autoRenewPrepaidBloc.add(AutoRenewSavedCardSelected(card));
          },
          walletBalanceText: walletBalanceText,
          showNoAutoRenewRow: true,
          showPayWithCardRow: true,
          payWithCardSelected: autoRenewPrepaidState.isPayWithCardSelected,
          onPayFromWallet: () {
            autoRenewPrepaidBloc.add(
              AutoRenewMethodSelected(AutoRenewPaymentMethod.wallet.id),
            );
          },
          onNoAutoRenewSelected: () {
            autoRenewPrepaidBloc.add(
              AutoRenewMethodSelected(AutoRenewPaymentMethod.none.id),
            );
          },
          onPayWithCardSelected: () {
            autoRenewPrepaidBloc.add(
              AutoRenewMethodSelected(AutoRenewPaymentMethod.payWithCard.id),
            );
          },
        ),
        const SizedBox(height: AutoRenewPrepaidTheme.dashedToActionGap),
        AutoRenewPrepaidProceedActionButton(
          isEnabled: autoRenewPrepaidState.canProceed,
          isLoading: autoRenewPrepaidState.savingSelection ||
              isWalletRenewLoading ||
              isNoRenewLoading,
          onPressed: () async {
            if (autoRenewPrepaidState.isPayWithCardSelected) {
              context.push(AppRoutes.addOrEditCardsPrepaidScreen);
              return;
            }

            if (autoRenewPrepaidState.isNoAutoRenewSelected) {
              await _disableAutoRenew(context);
              return;
            }

            final selectedCard = autoRenewPrepaidState.selectedCard;
            final isWalletSelected = autoRenewPrepaidState.isWalletSelected;
            if (selectedCard == null && !isWalletSelected) {
              return;
            }

            if (isWalletSelected) {
              await _enableWalletAutoRenew(context);
              return;
            }

            final card = selectedCard;
            if (card == null) {
              return;
            }

            context.push(
              AppRoutes.autoRenewAuthPrepaidScreen,
              extra: AutoRenewAuthArgs(
                paymentMethod: AutoRenewPaymentMethodType.card,
                cardToken: card.token,
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _disableAutoRenew(BuildContext context) async {
    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    if (accountInfo == null || accountInfo.idAcc <= 0) {
      AppToast.show(
        message: 'Account info not available',
        type: ToastType.error,
      );
      return;
    }

    final deviceLimitsCubit = instance<DeviceLimitsCubit>();
    final success = await deviceLimitsCubit.disableAutoRenew(accountInfo.idAcc);

    final errorMessage = deviceLimitsCubit.state.errorMessage;
    AppToast.show(
      message: success
          ? "We're working on it! Auto-renew takes a few minutes to update. Thank you for your patience."
          : (errorMessage?.isNotEmpty == true
              ? errorMessage!
              : 'Failed to disable auto-renew'),
      type: success ? ToastType.success : ToastType.error,
    );

    if (success && context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _enableWalletAutoRenew(BuildContext context) async {
    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    if (accountInfo == null || accountInfo.idAcc <= 0) {
      AppToast.show(
        message: 'Account info not available',
        type: ToastType.error,
      );
      return;
    }

    final deviceLimitsCubit = instance<DeviceLimitsCubit>();

    // Wallet auto-renew also requires clearing the card-based auto-renew
    // selection server-side. The card endpoint accepts an empty token to
    // signal "no card linked" — mirror of the card flow which calls both
    // endpoints sequentially.
    final cardSuccess = await deviceLimitsCubit.enableAutoRenewCard(
      token: '',
      refreshAfter: false,
    );
    if (!cardSuccess) {
      final errorMessage = deviceLimitsCubit.state.errorMessage;
      AppToast.show(
        message: errorMessage?.isNotEmpty == true
            ? errorMessage!
            : 'Failed to enable auto-renew',
        type: ToastType.error,
      );
      if (context.mounted) {
        context.go(AppRoutes.home);
      }
      return;
    }

    final success =
        await deviceLimitsCubit.enableAutoRenewWallet(accountInfo.idAcc);

    final errorMessage = deviceLimitsCubit.state.errorMessage;
    AppToast.show(
      message: success
          ? "We're working on it! Auto renew takes a few minutes to update. Thank you for your patience."
          : (errorMessage?.isNotEmpty == true
              ? errorMessage!
              : 'Failed to enable auto-renew'),
      type: success ? ToastType.success : ToastType.error,
    );

    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _PinnedHeaderDelegate({required this.height, required this.child});

  // ==================== Sliver Extent ====================
  // Fix both extents to avoid dynamic height changes.
  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  // ==================== Header Build ====================
  // Respect fixed extent contract by wrapping child in SizedBox.
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  // ==================== Rebuild Rule ====================
  // Rebuild only when layout inputs are changed.
  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
