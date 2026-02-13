import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_confirm_theme.dart';

class GuestPayBillConfirmHeaderCard extends StatelessWidget {
  final String serviceName;
  final String identifierLabel;
  final String identifierValue;
  final double amount;

  const GuestPayBillConfirmHeaderCard({
    super.key,
    required this.serviceName,
    required this.identifierLabel,
    required this.identifierValue,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GuestPayBillConfirmTheme.headerCardPadding,
      decoration: BoxDecoration(
        color: GuestPayBillConfirmTheme.cardWhite,
        borderRadius:
            BorderRadius.circular(GuestPayBillConfirmTheme.headerCardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serviceName, style: GuestPayBillConfirmTheme.headerTitle),
                const SizedBox(
                    height: GuestPayBillConfirmTheme.headerToSubtitleGap),
                Text(
                  '$identifierLabel $identifierValue',
                  style: GuestPayBillConfirmTheme.headerSub,
                ),
              ],
            ),
          ),
          const SizedBox(
              width: GuestPayBillConfirmTheme.headerTextToAmountPillGap),
          _AmountPill(amount: amount),
        ],
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  final double amount;
  const _AmountPill({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GuestPayBillConfirmTheme.amountPillPadding,
      decoration: BoxDecoration(
        color: GuestPayBillConfirmTheme.amountBackground,
        borderRadius:
            BorderRadius.circular(GuestPayBillConfirmTheme.amountPillRadius),
      ),
      child: Text(
        _money(amount),
        textAlign: TextAlign.center,
        style: GuestPayBillConfirmTheme.amountPill,
      ),
    );
  }

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';
}
