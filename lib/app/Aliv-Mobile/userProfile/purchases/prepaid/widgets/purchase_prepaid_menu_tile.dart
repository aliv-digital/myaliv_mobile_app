import 'package:flutter/material.dart';
import '../theme/purchase_prepaid_theme.dart';

class PurchasePrepaidMenuTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PurchasePrepaidMenuTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PurchasePrepaidTheme.tileBg,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PurchasePrepaidTheme.horizontalPad,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: PurchasePrepaidTheme.itemTextStyle(),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: PurchasePrepaidTheme.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
