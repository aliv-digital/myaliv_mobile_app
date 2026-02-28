import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auto_renew_prepaid_bloc.dart';
import '../bloc/auto_renew_prepaid_event.dart';
import '../bloc/auto_renew_prepaid_state.dart';
import 'bottomsheet/add_card_bottom_sheet.dart';
import 'bottomsheet/wallet_payment_bottom_sheet.dart';

class AutoRenewPrepaidStateListener extends StatelessWidget {
  final Widget child;

  const AutoRenewPrepaidStateListener({
    super.key,
    required this.child,
  });

  // ==================== Listener Wrapper ====================
  // Attach side-effect handling without mixing it into rendering widgets.
  @override
  Widget build(BuildContext context) {
    return BlocListener<AutoRenewPrepaidBloc, AutoRenewPrepaidState>(
      listenWhen: _shouldHandleUiSideEffects,
      listener: _handleUiSideEffects,
      child: child,
    );
  }

  // ==================== Side-Effect Filter ====================
  // Trigger listener only for transient changes.
  bool _shouldHandleUiSideEffects(
    AutoRenewPrepaidState previousState,
    AutoRenewPrepaidState currentState,
  ) {
    return previousState.errorMessage != currentState.errorMessage ||
        previousState.navTarget != currentState.navTarget;
  }

  // ==================== Side-Effect Router ====================
  // Route each side-effect to a dedicated handler.
  Future<void> _handleUiSideEffects(
    BuildContext context,
    AutoRenewPrepaidState state,
  ) async {
    final AutoRenewPrepaidBloc autoRenewPrepaidBloc =
        context.read<AutoRenewPrepaidBloc>();

    _showErrorMessageIfPresent(context, state.errorMessage);

    if (state.navTarget == AutoRenewNavTarget.addCard) {
      await _handleAddCardFlow(context, autoRenewPrepaidBloc);
      return;
    }

    if (state.navTarget == AutoRenewNavTarget.wallet) {
      await _handleWalletPaymentFlow(context, autoRenewPrepaidBloc, state);
      return;
    }

    if (state.navTarget == AutoRenewNavTarget.home) {
      _consumeHomeNavigation(autoRenewPrepaidBloc);
      return;
    }

    if (state.navTarget == AutoRenewNavTarget.proceed) {
      _consumeProceedNavigation(autoRenewPrepaidBloc);
      return;
    }
  }

  // ==================== Error Feedback ====================
  // Render a snackbar only when message exists.
  void _showErrorMessageIfPresent(BuildContext context, String? errorMessage) {
    final bool hasErrorMessage =
        errorMessage != null && errorMessage.isNotEmpty;

    if (!hasErrorMessage) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  // ==================== Add Card Flow ====================
  // Open bottom sheet and send selected card expiry to bloc.
  Future<void> _handleAddCardFlow(
    BuildContext context,
    AutoRenewPrepaidBloc autoRenewPrepaidBloc,
  ) async {
    final AddCardExpiryResult? addCardExpiryResult =
        await AddCardBottomSheet.show(context);

    if (!context.mounted) {
      return;
    }

    if (addCardExpiryResult != null) {
      autoRenewPrepaidBloc.add(
        AutoRenewSaveNewCardPressed(
          month: addCardExpiryResult.month,
          year: addCardExpiryResult.year,
        ),
      );
    }

    autoRenewPrepaidBloc.add(const AutoRenewNavigationConsumed());
  }

  // ==================== Wallet Payment Flow ====================
  // Open wallet payment bottom sheet and clean nav target after close.
  Future<void> _handleWalletPaymentFlow(
    BuildContext context,
    AutoRenewPrepaidBloc autoRenewPrepaidBloc,
    AutoRenewPrepaidState state,
  ) async {
    await WalletPaymentBottomSheet.show(
      context,
      walletBalanceText: state.walletBalanceText,
      amountText: state.walletPaymentAmountText,
    );

    if (!context.mounted) {
      return;
    }

    autoRenewPrepaidBloc.add(const AutoRenewNavigationConsumed());
  }

  // ==================== Home Navigation ====================
  // Keep nav-target lifecycle clean until final route is wired.
  void _consumeHomeNavigation(AutoRenewPrepaidBloc autoRenewPrepaidBloc) {
    // TODO: integrate router/go_router for home navigation.
    autoRenewPrepaidBloc.add(const AutoRenewNavigationConsumed());
  }

  // ==================== Proceed Navigation ====================
  // Keep nav-target lifecycle clean until final route is wired.
  void _consumeProceedNavigation(AutoRenewPrepaidBloc autoRenewPrepaidBloc) {
    // TODO: navigate to next screen.
    autoRenewPrepaidBloc.add(const AutoRenewNavigationConsumed());
  }
}
