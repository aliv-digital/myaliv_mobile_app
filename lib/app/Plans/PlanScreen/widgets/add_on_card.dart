import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// for HomePlanBenefitType (data icon)
import '../data/plan_icon_assets.dart';
import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

class HomePlanAddOnCard extends StatelessWidget {
  final HomePlanAddOnModel addon;
  final bool selected;
  final VoidCallback onToggle;

  const HomePlanAddOnCard({
    super.key,
    required this.addon,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = HomePlanIconAssets.forType(HomePlanBenefitType.data);

    debugPrint("----- HomePlanAddOnCard -----");
    debugPrint("HomePlanBenefitType.data: ${HomePlanBenefitType.data}");
    debugPrint("iconPath: $iconPath");

    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(
        HomePlanTheme.addOnCardBorderRadius,
      ),
      child: Container(
        margin: HomePlanTheme.addOnCardOuterMargin,
        padding: HomePlanTheme.addOnCardInnerPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            HomePlanTheme.addOnCardBorderRadius,
          ),
          border: Border.all(
            color: selected
                ? HomePlanTheme.brandPurple
                : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: title on left and checkbox on right.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    addon.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomePlanTheme.addOnTitle,
                  ),
                ),
                _CheckBoxSquare(
                  checked: selected,
                  onTap: onToggle,
                ),
              ],
            ),
            const SizedBox(
                height: HomePlanTheme.addOnCardTitleToDetailsGap),
            // Bottom row: icon + label + value on left and amount pill on right.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isSvg)
                  SvgPicture.asset(
                    iconPath,
                    width: HomePlanTheme.addOnCardInfoIconSize,
                    height: HomePlanTheme.addOnCardInfoIconSize,
                  )
                else
                  Image.asset(
                    iconPath,
                    width: HomePlanTheme.addOnCardInfoIconSize,
                    height: HomePlanTheme.addOnCardInfoIconSize,
                  ),
                const SizedBox(
                    width: HomePlanTheme.addOnCardIconToLabelGap),
                Text(
                  addon.label, // data balance
                  style: HomePlanTheme.addOnLabel,
                ),
                const SizedBox(width: HomePlanTheme.addOnCardLabelToValueGap),
                Expanded(
                  child: Text(
                    addon.value, // 1gb
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomePlanTheme.addOnValue,
                  ),
                ),
                const SizedBox(width: HomePlanTheme.addOnCardValueToPriceGap),
                _PricePill(price: addon.totalPrice),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final double price;
  const _PricePill({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: HomePlanTheme.addOnPricePillBackground,
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: HomePlanTheme.addOnPrice,
      ),
    );
  }
}

class _CheckBoxSquare extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;

  const _CheckBoxSquare({
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        HomePlanTheme.addOnCheckboxRadius,
      ),
      child: Container(
        width: HomePlanTheme.addOnCheckboxSize,
        height: HomePlanTheme.addOnCheckboxSize,
        decoration: BoxDecoration(
          color: checked
              ? HomePlanTheme.addOnCheckboxCheckedFillColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            HomePlanTheme.addOnCheckboxRadius,
          ),
          border: Border.all(
            color: HomePlanTheme.addOnCheckboxBorderColor,
            width: HomePlanTheme.addOnCheckboxBorderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: checked
            ? const Icon(
                Icons.check,
                size: HomePlanTheme.addOnCheckboxCheckIconSize,
                color: HomePlanTheme.addOnCheckboxCheckIconColor,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
