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
      padding: const EdgeInsets.only(top: 24,bottom: 24,left: 16,right: 16),
      decoration: BoxDecoration(
        color: GuestPayBillConfirmTheme.cardWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serviceName, style: GuestPayBillConfirmTheme.headerTitle()),
                const SizedBox(height: 4),
                Text(
                  '$identifierLabel $identifierValue',
                  style: GuestPayBillConfirmTheme.headerSub(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
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
      padding: const EdgeInsets.only(left: 11,right: 11,top: 5,bottom: 5),
      decoration: BoxDecoration(
        color: GuestPayBillConfirmTheme.amountBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GuestPayBillConfirmTheme.border, width: 1),
      ),
      child: Text(
        _money(amount),
        style:  TextStyle(
          color: GuestPayBillConfirmTheme.amountText,
          fontSize: 16,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';
}
