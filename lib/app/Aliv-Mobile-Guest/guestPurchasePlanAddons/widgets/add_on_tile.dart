import 'package:flutter/material.dart';
import '../model/add_on_models.dart';
import '../theme/guest_purchase_plan_add_ons_theme.dart';

/// AddOnTile
/// - Selected হলে purple border দেখাবে (Figma screenshot)
/// - Unselected হলে border থাকবে না (clean card)
class AddOnTile extends StatelessWidget {
  final AddOnItem item;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const AddOnTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = GuestPurchasePlanAddOnsTheme.outlinePurple;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: GuestPurchasePlanAddOnsTheme.cardWhite,
            borderRadius: BorderRadius.circular(14),
            border: selected ? Border.all(color: borderColor, width: 1.6) : null,
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 10),
                color: GuestPurchasePlanAddOnsTheme.shadow,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + checkbox
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GuestPurchasePlanAddOnsTheme.t(18, weight: FontWeight.w700),
                      ),
                    ),
                    _SquareCheckbox(
                      value: selected,
                      onChanged: onChanged,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.wifi, size: 18, color: GuestPurchasePlanAddOnsTheme.planRed),
                          const SizedBox(width: 8),
                          Text(
                            item.subtitleLabel,
                            style: GuestPurchasePlanAddOnsTheme.t(
                              18,
                              weight: FontWeight.w500,
                              color: GuestPurchasePlanAddOnsTheme.planRed,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item.subtitleValue,
                            style: GuestPurchasePlanAddOnsTheme.t(24, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),

                    // price chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.currencySymbol} ${item.price.toStringAsFixed(2)}',
                        style: GuestPurchasePlanAddOnsTheme.t(
                          16,
                          weight: FontWeight.w900,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SquareCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final borderColor = GuestPurchasePlanAddOnsTheme.outlinePurple;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 1.4),
          color: value ? borderColor : Colors.transparent,
        ),
        child: value
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
