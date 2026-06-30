import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/theme/auto_renew_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/checkout_card_form.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// Bottom sheet that collects a new Visa card's details and returns a
/// [NewCardDetails] on confirm (or `null` on dismiss).
///
/// Reusable across the app — pass an [amountText] to display, nothing else.
class CheckoutCardBottomSheet extends StatelessWidget {
  final String amountText;

  const CheckoutCardBottomSheet({super.key, required this.amountText});

  static Future<NewCardDetails?> show(
    BuildContext context, {
    required String amountText,
  }) {
    return showModalBottomSheet<NewCardDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AutoRenewPrepaidTheme.sheetBg,
      shape: AutoRenewPrepaidTheme.walletPaymentSheetShape(),
      builder: (_) => CheckoutCardBottomSheet(amountText: amountText),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Header(onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: 12),
              _AmountRow(amountText: amountText),
              const SizedBox(height: 20),
              CheckoutCardForm(
                onSubmit: (details) => Navigator.of(context).pop(details),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: onClose,
          child: const Icon(
            Icons.arrow_back,
            size: AutoRenewPrepaidTheme.walletPaymentBackIconSize,
            color: AutoRenewPrepaidTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Checkout',
          style: AutoRenewPrepaidTheme.walletPaymentTitleStyle,
        ),
        const Spacer(),
        SizedBox(
          width: AutoRenewPrepaidTheme.cardLogoWidth,
          height: AutoRenewPrepaidTheme.cardLogoHeight,
          child: SvgPicture.asset(
            AssetConstant.visaCardSVG,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String amountText;
  const _AmountRow({required this.amountText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Text(
          'amount',
          style: AutoRenewPrepaidTheme.walletPaymentAmountLabelStyle,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AutoRenewPrepaidTheme.walletChipHorizontalPadding,
            vertical: AutoRenewPrepaidTheme.walletChipVerticalPadding,
          ),
          decoration: const BoxDecoration(
            color: AutoRenewPrepaidTheme.walletChipBackground,
            borderRadius: BorderRadius.all(
              Radius.circular(AutoRenewPrepaidTheme.walletChipCornerRadius),
            ),
          ),
          child: Text(
            amountText,
            style: AutoRenewPrepaidTheme.walletPaymentWalletAmountStyle,
          ),
        ),
      ],
    );
  }
}
