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
  final bool showAmount;
  final String title;
  final String submitLabel;

  const CheckoutCardBottomSheet({
    super.key,
    required this.amountText,
  })  : showAmount = true,
        title = 'Checkout',
        submitLabel = 'confirm payment';

  const CheckoutCardBottomSheet.forAddCard({super.key})
      : amountText = '',
        showAmount = false,
        title = 'Add card',
        submitLabel = 'save card';

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

  static Future<NewCardDetails?> showForAddCard(BuildContext context) {
    return showModalBottomSheet<NewCardDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AutoRenewPrepaidTheme.sheetBg,
      shape: AutoRenewPrepaidTheme.walletPaymentSheetShape(),
      builder: (_) => const CheckoutCardBottomSheet.forAddCard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        24,
        16,
        24 + keyboardInset,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Header(
                onClose: () => Navigator.of(context).pop(),
              ),
              if (showAmount) ...[
                const SizedBox(height: 20),
                _AmountRow(amountText: amountText),
                const SizedBox(height: 16),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE9E8EF),
                ),
              ],
              const SizedBox(height: 20),
              CheckoutCardForm(
                onSubmit: (details) => Navigator.of(context).pop(details),
                submitLabel: submitLabel,
                useSavedCardNumberRules: !showAmount,
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
        Container(
          width: 48,
          height: 48,
          decoration: ShapeDecoration(
            color: const Color(0xFFEDEBF7),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 8,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: Color(0xFFF9F5FF),
              ),
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            AssetConstant.creditCardSVG,
            width: 24,
            height: 24,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 26,
          height: 26,
          child: IconButton(
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 26, height: 26),
            icon: SvgPicture.asset(
              AssetConstant.blackRoundedCrossSVG,
              width: 26,
              height: 26,
            ),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
          style: _CheckoutSheetStyles.label,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFECECEF),
            borderRadius: BorderRadius.all(
              Radius.circular(100),
            ),
          ),
          child: Text(
            amountText,
            style: _CheckoutSheetStyles.amount,
          ),
        ),
      ],
    );
  }
}

class _CheckoutSheetStyles {
  const _CheckoutSheetStyles._();

  static const TextStyle label = TextStyle(
    color: Color(0xFF222222),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle amount = TextStyle(
    color: Color(0xFF222222),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );
}
