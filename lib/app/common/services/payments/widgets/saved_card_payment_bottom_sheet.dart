import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/theme/auto_renew_prepaid_theme.dart';

/// Confirmation sheet shown before charging a saved card via
/// `Order/change-bundle`. Visually mirrors `WalletPaymentBottomSheet`.
///
/// Pure presentation: takes display strings only, no model dependency.
/// Returns `true` if the user confirms.
class SavedCardPaymentBottomSheet extends StatelessWidget {
  final String cardLabel;
  final String amountText;

  const SavedCardPaymentBottomSheet({
    super.key,
    required this.cardLabel,
    required this.amountText,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String cardLabel,
    required String amountText,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AutoRenewPrepaidTheme.sheetBg,
      shape: AutoRenewPrepaidTheme.walletPaymentSheetShape(),
      builder: (_) => SavedCardPaymentBottomSheet(
        cardLabel: cardLabel,
        amountText: amountText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AutoRenewPrepaidTheme.walletPaymentHorizontalPadding,
        AutoRenewPrepaidTheme.walletPaymentTopPadding,
        AutoRenewPrepaidTheme.walletPaymentHorizontalPadding,
        AutoRenewPrepaidTheme.walletPaymentBottomPadding + keyboardInset,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _BackButton(onTap: () => Navigator.of(context).pop()),
            const SizedBox(height: AutoRenewPrepaidTheme.walletPaymentBackToTitleGap),
            const Text(
              'pay with card',
              style: AutoRenewPrepaidTheme.walletPaymentTitleStyle,
            ),
            const SizedBox(height: AutoRenewPrepaidTheme.walletPaymentTitleToBalanceGap),
            _CardRow(label: cardLabel),
            const SizedBox(height: AutoRenewPrepaidTheme.walletPaymentBalanceToAmountGap),
            const Text(
              'amount',
              style: AutoRenewPrepaidTheme.walletPaymentAmountLabelStyle,
            ),
            const SizedBox(height: AutoRenewPrepaidTheme.walletPaymentAmountLabelToFieldGap),
            _AmountField(amountText: amountText),
            const SizedBox(height: AutoRenewPrepaidTheme.walletPaymentAmountFieldToButtonGap),
            _ConfirmButton(onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const SizedBox(
        width: AutoRenewPrepaidTheme.walletPaymentBackButtonSize,
        height: AutoRenewPrepaidTheme.walletPaymentBackButtonSize,
        child: Icon(
          Icons.arrow_back,
          size: AutoRenewPrepaidTheme.walletPaymentBackIconSize,
          color: AutoRenewPrepaidTheme.textSecondary,
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final String label;
  const _CardRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.credit_card,
          size: AutoRenewPrepaidTheme.walletPaymentWalletIconSize,
          color: AutoRenewPrepaidTheme.textSecondary,
        ),
        const SizedBox(width: AutoRenewPrepaidTheme.walletPaymentWalletIconToTextGap),
        Text(
          label,
          style: AutoRenewPrepaidTheme.walletPaymentWalletLabelStyle,
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  final String amountText;
  const _AmountField({required this.amountText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AutoRenewPrepaidTheme.walletPaymentAmountFieldHeight,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AutoRenewPrepaidTheme.walletPaymentAmountFieldBackground,
        borderRadius: BorderRadius.circular(
          AutoRenewPrepaidTheme.walletPaymentAmountFieldRadius,
        ),
      ),
      child: Text(
        amountText,
        style: AutoRenewPrepaidTheme.walletPaymentAmountValueStyle,
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ConfirmButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AutoRenewPrepaidTheme.walletPaymentConfirmButtonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AutoRenewPrepaidTheme.primaryPillButtonStyle(
          backgroundColor: AutoRenewPrepaidTheme.primary,
        ),
        child: const Text(
          'confirm payment',
          style: AutoRenewPrepaidTheme.walletPaymentConfirmButtonTextStyle,
        ),
      ),
    );
  }
}
