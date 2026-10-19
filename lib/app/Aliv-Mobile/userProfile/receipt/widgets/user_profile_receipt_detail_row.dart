import 'package:flutter/material.dart';

import '../theme/user_profile_receipt_theme.dart';

class UserProfileReceiptDetailRow extends StatelessWidget {
  const UserProfileReceiptDetailRow({
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
        vertical: UserProfileReceiptTheme.detailRowVerticalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: UserProfileReceiptTheme.detailLabel),
          ),
          Text(
            value,
            style: valueBold
                ? UserProfileReceiptTheme.detailValueBold
                : UserProfileReceiptTheme.detailValue,
          ),
        ],
      ),
    );
  }
}
