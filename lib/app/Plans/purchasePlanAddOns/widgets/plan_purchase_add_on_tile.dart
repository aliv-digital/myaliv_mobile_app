import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../model/plan_purchase_add_on_models.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';
import '../../PlanScreen/data/plan_icon_assets.dart';
import '../../PlanScreen/models/plan_model.dart';

/// PlanPurchaseAddOnTile
/// - Selected হলে purple border দেখাবে (Figma screenshot)
/// - Unselected হলে border থাকবে না (clean card)
class PlanPurchaseAddOnTile extends StatelessWidget {
  final PlanPurchaseAddOnItem item;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const PlanPurchaseAddOnTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = PlanPurchasePlanAddOnsTheme.outlinePurple;
    final cardRadius =
        BorderRadius.circular(PlanPurchasePlanAddOnsTheme.addOnCardRadius);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: cardRadius,
        child: Container(
          decoration: BoxDecoration(
            color: PlanPurchasePlanAddOnsTheme.cardWhite,
            borderRadius: cardRadius,
            border:
                selected ? Border.all(color: borderColor, width: 1.2) : null,
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 10),
                color: PlanPurchasePlanAddOnsTheme.shadow,
              ),
            ],
          ),
          child: Padding(
            padding: PlanPurchasePlanAddOnsTheme.addOnCardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + checkbox
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: PlanPurchasePlanAddOnsTheme.addOnTitle,
                      ),
                    ),
                    _SquareCheckbox(
                      value: selected,
                      onChanged: onChanged,
                    ),
                  ],
                ),

                const SizedBox(
                    height: PlanPurchasePlanAddOnsTheme
                        .addOnCardTitleToDetailsGap),

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _DataIcon(),
                          const SizedBox(
                              width: PlanPurchasePlanAddOnsTheme
                                  .addOnCardIconToLabelGap),
                          Text(
                            item.subtitleLabel,
                            style: PlanPurchasePlanAddOnsTheme.addOnLabel,
                          ),
                          const SizedBox(
                              width: PlanPurchasePlanAddOnsTheme
                                  .addOnCardLabelToValueGap),
                          Text(
                            item.subtitleValue,
                            style: PlanPurchasePlanAddOnsTheme.addOnValue,
                          ),
                        ],
                      ),
                    ),

                    // price chip
                    Container(
                      padding:
                          PlanPurchasePlanAddOnsTheme.addOnAmountChipPadding,
                      decoration: BoxDecoration(
                        color:
                            PlanPurchasePlanAddOnsTheme.addOnAmountChipColor,
                        borderRadius: BorderRadius.circular(
                          PlanPurchasePlanAddOnsTheme.addOnAmountChipRadius,
                        ),
                      ),
                      child: Text(
                        '${item.currencySymbol} ${item.price.toStringAsFixed(2)}',
                        style: PlanPurchasePlanAddOnsTheme.addOnPrice,
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
    final borderColor = PlanPurchasePlanAddOnsTheme.outlinePurple;
    final checkboxRadius = BorderRadius.circular(
      PlanPurchasePlanAddOnsTheme.addOnCheckboxRadius,
    );

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: checkboxRadius,
      child: Container(
        width: PlanPurchasePlanAddOnsTheme.addOnCheckboxSize,
        height: PlanPurchasePlanAddOnsTheme.addOnCheckboxSize,
        decoration: BoxDecoration(
          borderRadius: checkboxRadius,
          border: Border.all(color: borderColor, width: 1),
          color: value ? borderColor : Colors.transparent,
        ),
        child: value
            ? const Icon(
                Icons.check,
                size: PlanPurchasePlanAddOnsTheme.addOnCheckboxIconSize,
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
    final iconPath = HomePlanIconAssets.forType(HomePlanBenefitType.data);
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.asset(
        iconPath,
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(
          PlanPurchasePlanAddOnsTheme.addOnLabelColor,
          BlendMode.srcIn,
        ),
      );
    }
    return Image.asset(
      iconPath,
      width: 18,
      height: 18,
      color: PlanPurchasePlanAddOnsTheme.addOnLabelColor,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
