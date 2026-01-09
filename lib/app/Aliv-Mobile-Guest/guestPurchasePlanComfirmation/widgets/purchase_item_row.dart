import 'package:flutter/material.dart';
import '../models/guest_purchase_plan_confirmation_models.dart';
import '../theme/guest_purchase_plan_confirmation_theme.dart';


class PurchaseItemRow extends StatelessWidget {
  final PurchaseLineItem item;
  final VoidCallback onRemove;

  const PurchaseItemRow({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: GuestPurchasePlanConfirmationTheme.t(
                  11,
                  weight: FontWeight.w700,
                  color: GuestPurchasePlanConfirmationTheme.textGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.title,
                style: GuestPurchasePlanConfirmationTheme.t(
                  18,
                  weight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: GuestPurchasePlanConfirmationTheme.t(
                  11,
                  weight: FontWeight.w700,
                  color: GuestPurchasePlanConfirmationTheme.textGrey,
                ),
              ),
            ],
          ),
        ),

        // Price pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: GuestPurchasePlanConfirmationTheme.outlinePurple,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '\$ ${item.price.toStringAsFixed(2)}',
            style: GuestPurchasePlanConfirmationTheme.t(
              14,
              weight: FontWeight.w900,
              color: GuestPurchasePlanConfirmationTheme.outlinePurple,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Trash
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.delete_outline, size: 18),
          ),
        ),
      ],
    );
  }
}
