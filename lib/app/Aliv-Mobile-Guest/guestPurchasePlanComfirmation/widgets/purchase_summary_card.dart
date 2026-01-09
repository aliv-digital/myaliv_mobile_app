import 'package:flutter/material.dart';
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
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 10),
            color: GuestPurchasePlanConfirmationTheme.shadow,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.headerTitle,
              style: GuestPurchasePlanConfirmationTheme.t(15, weight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              data.phoneNumber,
              style: GuestPurchasePlanConfirmationTheme.t(
                12,
                weight: FontWeight.w700,
                color: GuestPurchasePlanConfirmationTheme.textGrey,
              ),
            ),
            const SizedBox(height: 10),

            const Divider(height: 1),

            const SizedBox(height: 10),

            // Items
            for (int i = 0; i < data.items.length; i++) ...[
              PurchaseItemRow(
                item: data.items[i],
                onRemove: () => onRemoveItem(data.items[i].id),
              ),
              if (i != data.items.length - 1) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
