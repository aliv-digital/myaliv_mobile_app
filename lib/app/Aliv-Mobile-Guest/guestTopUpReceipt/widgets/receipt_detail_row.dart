import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: ReceiptTheme.successDetailRowVerticalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: ReceiptTheme.detailLabel,
            ),
          ),
          Text(
            value,
            style: valueBold
                ? ReceiptTheme.detailValueBold
                : ReceiptTheme.detailValue,
          ),
        ],
      ),
    );
  }
}
