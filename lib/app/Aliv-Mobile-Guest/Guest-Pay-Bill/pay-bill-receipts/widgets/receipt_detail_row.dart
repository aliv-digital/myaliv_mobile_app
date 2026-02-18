import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/theme/theme.dart';

class ReceiptDetailRow extends StatelessWidget {
  const ReceiptDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    final valueStyle = valueBold
        ? GuestPayBillReceiptTheme.detailValueBold
        : GuestPayBillReceiptTheme.detailValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GuestPayBillReceiptTheme.detailLabel,
            ),
          ),
          Text(
            value,
            style: valueStyle,
          ),
        ],
      ),
    );
  }
}
