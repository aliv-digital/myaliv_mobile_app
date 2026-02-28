import 'package:flutter/material.dart';
import '../models/home_plan_confirmation_models.dart';
import '../theme/home_plan_confirmation_theme.dart';
import 'purchase_item_row.dart';

class PurchaseSummaryCard extends StatelessWidget {
  final HomePlanConfirmationData data;
  final void Function(String itemId) onRemoveItem;

  const PurchaseSummaryCard({
    super.key,
    required this.data,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomePlanConfirmationTheme.cardWhite,
        borderRadius: BorderRadius.circular(
          HomePlanConfirmationTheme.purchaseSummaryCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 10),
            color: HomePlanConfirmationTheme.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header block: strict 16/14/16/14 spacing from Figma.
          Padding(
            padding: HomePlanConfirmationTheme.purchaseSummaryHeaderPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.headerTitle,
                  style: HomePlanConfirmationTheme
                      .purchaseSummaryHeaderTitleTextStyle,
                ),
                const SizedBox(
                  height: HomePlanConfirmationTheme
                      .purchaseSummaryHeaderTitleToPhoneGap,
                ),
                Text(
                  data.phoneNumber,
                  style: HomePlanConfirmationTheme
                      .purchaseSummaryHeaderPhoneTextStyle,
                ),
              ],
            ),
          ),

          Divider(
            height: HomePlanConfirmationTheme.purchaseSummaryDividerHeight,
            thickness:
                HomePlanConfirmationTheme.purchaseSummaryDividerThickness,
            color: HomePlanConfirmationTheme.purchaseSummaryDividerColor,
          ),

          // Item blocks: strict 16/20/16/20 spacing from Figma.
          for (int i = 0; i < data.items.length; i++) ...[
            Padding(
              padding: HomePlanConfirmationTheme
                  .purchaseSummaryItemSectionPadding,
              child: PurchaseItemRow(
                item: data.items[i],
                onRemove: () => onRemoveItem(data.items[i].id),
              ),
            ),
            if (i != data.items.length - 1)
              Divider(
                height:
                    HomePlanConfirmationTheme.purchaseSummaryDividerHeight,
                thickness: HomePlanConfirmationTheme
                    .purchaseSummaryDividerThickness,
                color: HomePlanConfirmationTheme.purchaseSummaryDividerColor,
              ),
          ],
        ],
      ),
    );
  }
}
