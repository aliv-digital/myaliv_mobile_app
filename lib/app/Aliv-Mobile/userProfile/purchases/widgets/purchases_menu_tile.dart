import 'package:flutter/material.dart';
import '../theme/purchases_theme.dart';

class PurchasesMenuTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PurchasesMenuTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PurchasesTheme.tileBg,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PurchasesTheme.horizontalPad,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: PurchasesTheme.itemTextStyle()),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: PurchasesTheme.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
