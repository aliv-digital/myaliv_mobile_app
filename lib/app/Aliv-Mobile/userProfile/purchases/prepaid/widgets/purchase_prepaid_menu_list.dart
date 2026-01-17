import 'package:flutter/material.dart';
import '../model/purchase_prepaid_models.dart';
import '../theme/purchase_prepaid_theme.dart';
import 'purchase_prepaid_menu_tile.dart';

class PurchasePrepaidMenuList extends StatelessWidget {
  final List<PurchasePrepaidMenuItem> items;
  final ValueChanged<PurchasePrepaidMenuItem> onTapItem;

  const PurchasePrepaidMenuList({
    super.key,
    required this.items,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PurchasePrepaidTheme.tileBg,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            PurchasePrepaidMenuTile(
              title: items[i].title,
              onTap: () => onTapItem(items[i]),
            ),
            if (i != items.length - 1)
              const Divider(
                  height: 1,
                  thickness: 1,
                  color: PurchasePrepaidTheme.divider
              ),
          ],
        ],
      ),
    );
  }
}
