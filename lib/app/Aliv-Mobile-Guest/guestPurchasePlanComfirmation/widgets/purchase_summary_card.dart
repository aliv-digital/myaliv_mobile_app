import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import '../models/guest_purchase_plan_confirmation_models.dart';
import '../theme/guest_purchase_plan_confirmation_theme.dart';
import 'purchase_item_row.dart';

class PurchaseSummaryCard extends StatelessWidget {
  final GuestPurchasePlanConfirmationData data;
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
        color: GuestPurchasePlanConfirmationTheme.cardWhite,
        borderRadius: BorderRadius.circular(
          GuestPurchasePlanConfirmationTheme.purchaseSummaryCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 10),
            color: GuestPurchasePlanConfirmationTheme.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header block: strict 16/14/16/14 spacing from Figma.
          Padding(
            padding:
                GuestPurchasePlanConfirmationTheme.purchaseSummaryHeaderPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (AppSession.appRoute == 'prepaidPlan')? Text(
                  'Jade Turnquest',
                  style: GuestPurchasePlanConfirmationTheme
                      .purchaseSummaryHeaderTitleTextStyle,
                ): Text(
                  data.headerTitle,
                  style: GuestPurchasePlanConfirmationTheme
                      .purchaseSummaryHeaderTitleTextStyle,
                ),
                const SizedBox(
                  height: GuestPurchasePlanConfirmationTheme
                      .purchaseSummaryHeaderTitleToPhoneGap,
                ),
                Text(
                  data.phoneNumber,
                  style: GuestPurchasePlanConfirmationTheme
                      .purchaseSummaryHeaderPhoneTextStyle,
                ),
              ],
            ),
          ),

          Divider(
            height:
                GuestPurchasePlanConfirmationTheme.purchaseSummaryDividerHeight,
            thickness: GuestPurchasePlanConfirmationTheme
                .purchaseSummaryDividerThickness,
            color:
                GuestPurchasePlanConfirmationTheme.purchaseSummaryDividerColor,
          ),

          // Item blocks: strict 16/20/16/20 spacing from Figma.
          for (int i = 0; i < data.items.length; i++) ...[
            Padding(
              padding: GuestPurchasePlanConfirmationTheme
                  .purchaseSummaryItemSectionPadding,
              child: PurchaseItemRow(
                item: data.items[i],
                onRemove: () => onRemoveItem(data.items[i].id),
              ),
            ),
            if (i != data.items.length - 1)
              Divider(
                height: GuestPurchasePlanConfirmationTheme
                    .purchaseSummaryDividerHeight,
                thickness: GuestPurchasePlanConfirmationTheme
                    .purchaseSummaryDividerThickness,
                color: GuestPurchasePlanConfirmationTheme
                    .purchaseSummaryDividerColor,
              ),
          ],
        ],
      ),
    );
  }
}
