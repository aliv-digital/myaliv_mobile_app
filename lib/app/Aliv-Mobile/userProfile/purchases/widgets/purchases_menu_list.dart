import 'package:flutter/material.dart';
import '../model/purchases_models.dart';
import '../theme/purchases_theme.dart';
import 'purchases_menu_tile.dart';

class PurchasesMenuList extends StatelessWidget {
  final List<PurchasesMenuItem> items;
  final ValueChanged<PurchasesMenuItem> onTapItem;
  final bool showTopDivider;

  const PurchasesMenuList({
    super.key,
    required this.items,
    required this.onTapItem,
    this.showTopDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PurchasesTheme.tileBg,
      child: Column(
        children: [
          if (showTopDivider)
            const Divider(
              height: 1,
              thickness: 1,
              indent: PurchasesTheme.horizontalPad,
              endIndent: PurchasesTheme.horizontalPad,
              color: PurchasesTheme.divider,
            ),
          for (int i = 0; i < items.length; i++) ...[
            PurchasesMenuTile(
              title: items[i].title,
              onTap: () => onTapItem(items[i]),
            ),
            if (i != items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: PurchasesTheme.horizontalPad,
                endIndent: PurchasesTheme.horizontalPad,
                color: PurchasesTheme.divider,
              ),
          ],
        ],
      ),
    );
  }
}
