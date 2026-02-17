import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../model/add_on_models.dart';
import '../theme/guest_purchase_plan_add_ons_theme.dart';
import '../../guestPurchasePlan/data/plan_icon_assets.dart';
import '../../guestPurchasePlan/models/plan_model.dart';

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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: GuestPurchasePlanAddOnsTheme.cardWhite,
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: borderColor, width: 1.2) : null,
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 10),
                color: GuestPurchasePlanAddOnsTheme.shadow,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + checkbox
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GuestPurchasePlanAddOnsTheme.addOnTitle,
                      ),
                    ),
                    _SquareCheckbox(
                      value: selected,
                      onChanged: onChanged,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _DataIcon(),
                          const SizedBox(width: 2),
                          Text(
                            item.subtitleLabel,
                            style: GuestPurchasePlanAddOnsTheme.addOnLabel,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.subtitleValue,
                            style: GuestPurchasePlanAddOnsTheme.addOnValue,
                          ),
                        ],
                      ),
                    ),

                    // price chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.currencySymbol} ${item.price.toStringAsFixed(2)}',
                        style: GuestPurchasePlanAddOnsTheme.addOnPrice,
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
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 1),
          color: value ? borderColor : Colors.transparent,
        ),
        child: value
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _DataIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final iconPath = PlanIconAssets.forType(PlanBenefitType.data);
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.asset(
        iconPath,
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(
          GuestPurchasePlanAddOnsTheme.addOnLabelColor,
          BlendMode.srcIn,
        ),
      );
    }
    return Image.asset(
      iconPath,
      width: 18,
      height: 18,
      color: GuestPurchasePlanAddOnsTheme.addOnLabelColor,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
