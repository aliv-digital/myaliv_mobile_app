import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../model/plan_purchase_add_on_models.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';
import '../../PlanScreen/data/plan_icon_assets.dart';
import '../../PlanScreen/models/plan_model.dart';
//f ff
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

  // The add-ons API can return compact values like "100minutes".
  // Keep the original number/text intact, and only normalize the unit
  // to the shorter UI label used across the plans cards: "min".
  String _formatSubtitleValue(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return trimmedValue;
    }

    final lowerCasedValue = trimmedValue.toLowerCase();
    const minutesText = 'minutes';
    final minutesIndex = lowerCasedValue.indexOf(minutesText);

    if (minutesIndex == -1) {
      return trimmedValue;
    }

    // Split around the "minutes" token so values like "100minutes"
    // become "100 min" without hardcoding the numeric portion.
    final prefix = trimmedValue.substring(0, minutesIndex).trimRight();
    final suffix = trimmedValue
        .substring(minutesIndex + minutesText.length)
        .trimLeft();

    final parts = <String>[
      if (prefix.isNotEmpty) prefix,
      'min',
      if (suffix.isNotEmpty) suffix,
    ];

    return parts.join('');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = PlanPurchasePlanAddOnsTheme.outlinePurple;
    final cardRadius = BorderRadius.circular(
      PlanPurchasePlanAddOnsTheme.addOnCardRadius,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: cardRadius,
        child: Container(
          decoration: BoxDecoration(
            color: PlanPurchasePlanAddOnsTheme.cardWhite,
            borderRadius: cardRadius,
            border: selected
                ? Border.all(color: borderColor, width: 1.2)
                : null,
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
                    _SquareCheckbox(value: selected, onChanged: onChanged),
                  ],
                ),

                const SizedBox(
                  height:
                      PlanPurchasePlanAddOnsTheme.addOnCardTitleToDetailsGap,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _DataIcon(),
                          const SizedBox(
                            width: PlanPurchasePlanAddOnsTheme
                                .addOnCardIconToLabelGap,
                          ),
                          Text(
                            item.subtitleLabel,
                            style: PlanPurchasePlanAddOnsTheme.addOnLabel,
                          ),
                          const SizedBox(
                            width: PlanPurchasePlanAddOnsTheme
                                .addOnCardLabelToValueGap,
                          ),
                          // Display the API value as-is unless it contains
                          // "minutes", in which case we shorten it to "min".
                          Text(
                            // come here
                            _formatSubtitleValue(item.subtitleValue),
                            style: PlanPurchasePlanAddOnsTheme.addOnValue,
                          ),
                        ],
                      ),
                    ),

                    // price chip
                    _PricePill(
                      price: item.price,
                      vatAmount: item.vatAmount,
                      currencySymbol: item.currencySymbol,
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

class _PricePill extends StatelessWidget {
  const _PricePill({
    required this.price,
    required this.vatAmount,
    required this.currencySymbol,
  });

  final double price;
  final double vatAmount;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final totalPrice = price + vatAmount;

    return Container(
      padding: PlanPurchasePlanAddOnsTheme.addOnAmountChipPadding,
      decoration: BoxDecoration(
        color: PlanPurchasePlanAddOnsTheme.addOnAmountChipColor,
        borderRadius: BorderRadius.circular(
          PlanPurchasePlanAddOnsTheme.addOnAmountChipRadius,
        ),
      ),
      child: Text(
        '$currencySymbol ${totalPrice.toStringAsFixed(2)}',
        style: PlanPurchasePlanAddOnsTheme.addOnPrice,
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
