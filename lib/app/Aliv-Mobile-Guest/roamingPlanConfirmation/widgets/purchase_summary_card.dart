import 'package:flutter/material.dart';
import '../models/roaming_plan_confirmation_models.dart';
import '../theme/roaming_plan_confirmation_theme.dart';
import 'purchase_item_row.dart';

class PurchaseSummaryCard extends StatelessWidget {
  final RoamingPlanConfirmationData data;
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
        color: RoamingPlanConfirmationTheme.cardWhite,
        borderRadius: BorderRadius.circular(
          RoamingPlanConfirmationTheme.purchaseSummaryCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 10),
            color: RoamingPlanConfirmationTheme.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header block: strict 16/14/16/14 spacing from Figma.
          Padding(
            padding: RoamingPlanConfirmationTheme.purchaseSummaryHeaderPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.headerTitle,
                  style: RoamingPlanConfirmationTheme
                      .purchaseSummaryHeaderTitleTextStyle,
                ),
                const SizedBox(
                  height: RoamingPlanConfirmationTheme
                      .purchaseSummaryHeaderTitleToPhoneGap,
                ),
                Text(
                  data.phoneNumber,
                  style: RoamingPlanConfirmationTheme
                      .purchaseSummaryHeaderPhoneTextStyle,
                ),
              ],
            ),
          ),

          Divider(
            height: RoamingPlanConfirmationTheme.purchaseSummaryDividerHeight,
            thickness:
                RoamingPlanConfirmationTheme.purchaseSummaryDividerThickness,
            color: RoamingPlanConfirmationTheme.purchaseSummaryDividerColor,
          ),

          // Item blocks: strict 16/20/16/20 spacing from Figma.
          for (int i = 0; i < data.items.length; i++) ...[
            Padding(
              padding: RoamingPlanConfirmationTheme
                  .purchaseSummaryItemSectionPadding,
              child: PurchaseItemRow(
                item: data.items[i],
                onRemove: () => onRemoveItem(data.items[i].id),
              ),
            ),
            if (i != data.items.length - 1)
              Divider(
                height:
                    RoamingPlanConfirmationTheme.purchaseSummaryDividerHeight,
                thickness: RoamingPlanConfirmationTheme
                    .purchaseSummaryDividerThickness,
                color: RoamingPlanConfirmationTheme.purchaseSummaryDividerColor,
              ),
          ],
        ],
      ),
    );
  }
}
