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
    final cardRadius =
        BorderRadius.circular(GuestPurchasePlanAddOnsTheme.addOnCardRadius);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: cardRadius,
        child: Container(
          decoration: BoxDecoration(
            color: GuestPurchasePlanAddOnsTheme.cardWhite,
            borderRadius: cardRadius,
            border:
                selected ? Border.all(color: borderColor, width: 1.2) : null,
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 10),
                color: GuestPurchasePlanAddOnsTheme.shadow,
              ),
            ],
          ),
          child: Padding(
            padding: GuestPurchasePlanAddOnsTheme.addOnCardPadding,
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

                const SizedBox(
                    height: GuestPurchasePlanAddOnsTheme
                        .addOnCardTitleToDetailsGap),

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _DataIcon(),
                          const SizedBox(
                              width: GuestPurchasePlanAddOnsTheme
                                  .addOnCardIconToLabelGap),
                          Text(
                            item.subtitleLabel,
                            style: GuestPurchasePlanAddOnsTheme.addOnLabel,
                          ),
                          const SizedBox(
                              width: GuestPurchasePlanAddOnsTheme
                                  .addOnCardLabelToValueGap),
                          Text(
                            item.subtitleValue,
                            style: GuestPurchasePlanAddOnsTheme.addOnValue,
                          ),
                        ],
                      ),
                    ),

                    // price chip
                    Container(
                      padding:
                          GuestPurchasePlanAddOnsTheme.addOnAmountChipPadding,
                      decoration: BoxDecoration(
                        color:
                            GuestPurchasePlanAddOnsTheme.addOnAmountChipColor,
                        borderRadius: BorderRadius.circular(
                          GuestPurchasePlanAddOnsTheme.addOnAmountChipRadius,
                        ),
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
    final checkboxRadius = BorderRadius.circular(
      GuestPurchasePlanAddOnsTheme.addOnCheckboxRadius,
    );

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: checkboxRadius,
      child: Container(
        width: GuestPurchasePlanAddOnsTheme.addOnCheckboxSize,
        height: GuestPurchasePlanAddOnsTheme.addOnCheckboxSize,
        decoration: BoxDecoration(
          borderRadius: checkboxRadius,
          border: Border.all(color: borderColor, width: 1),
          color: value ? borderColor : Colors.transparent,
        ),
        child: value
            ? const Icon(
                Icons.check,
                size: GuestPurchasePlanAddOnsTheme.addOnCheckboxIconSize,
                color: Colors.white,
              )
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
