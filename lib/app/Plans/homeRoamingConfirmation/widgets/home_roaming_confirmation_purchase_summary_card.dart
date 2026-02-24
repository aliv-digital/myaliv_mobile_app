import 'package:flutter/material.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../theme/home_roaming_confirmation_theme.dart';
import 'home_roaming_confirmation_purchase_item_row.dart';

class HomeRoamingConfirmationPurchaseSummaryCard extends StatelessWidget {
  final HomeRoamingConfirmationData data;
  final void Function(String itemId) onRemoveItem;

  const HomeRoamingConfirmationPurchaseSummaryCard({
    super.key,
    required this.data,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeRoamingConfirmationTheme.cardWhite,
        borderRadius: BorderRadius.circular(
          HomeRoamingConfirmationTheme.purchaseSummaryCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 10),
            color: HomeRoamingConfirmationTheme.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header block: strict 16/14/16/14 spacing from Figma.
          Padding(
            padding: HomeRoamingConfirmationTheme.purchaseSummaryHeaderPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.headerTitle,
                  style: HomeRoamingConfirmationTheme
                      .purchaseSummaryHeaderTitleTextStyle,
                ),
                const SizedBox(
                  height: HomeRoamingConfirmationTheme
                      .purchaseSummaryHeaderTitleToPhoneGap,
                ),
                Text(
                  data.phoneNumber,
                  style: HomeRoamingConfirmationTheme
                      .purchaseSummaryHeaderPhoneTextStyle,
                ),
              ],
            ),
          ),

          Divider(
            height: HomeRoamingConfirmationTheme.purchaseSummaryDividerHeight,
            thickness:
                HomeRoamingConfirmationTheme.purchaseSummaryDividerThickness,
            color: HomeRoamingConfirmationTheme.purchaseSummaryDividerColor,
          ),

          // Item blocks: strict 16/20/16/20 spacing from Figma.
          for (int i = 0; i < data.items.length; i++) ...[
            Padding(
              padding: HomeRoamingConfirmationTheme
                  .purchaseSummaryItemSectionPadding,
              child: HomeRoamingConfirmationPurchaseItemRow(
                item: data.items[i],
                onRemove: () => onRemoveItem(data.items[i].id),
              ),
            ),
            if (i != data.items.length - 1)
              Divider(
                height:
                    HomeRoamingConfirmationTheme.purchaseSummaryDividerHeight,
                thickness: HomeRoamingConfirmationTheme
                    .purchaseSummaryDividerThickness,
                color: HomeRoamingConfirmationTheme.purchaseSummaryDividerColor,
              ),
          ],
        ],
      ),
    );
  }
}
