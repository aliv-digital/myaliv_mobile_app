import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// for PlanBenefitType (data icon)
import '../data/plan_icon_assets.dart';
import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

class AddOnCard extends StatelessWidget {
  final AddOnModel addon;
  final bool selected;
  final VoidCallback onToggle;

  const AddOnCard({
    super.key,
    required this.addon,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = PlanIconAssets.forType(PlanBenefitType.data);

    debugPrint("----- AddOnCard -----");
    debugPrint("PlanBenefitType.data: ${PlanBenefitType.data}");
    debugPrint("iconPath: $iconPath");

    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: GuestPurchasePlanTheme.addOnCardOuterMargin,
        padding: GuestPurchasePlanTheme.addOnCardInnerPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? GuestPurchasePlanTheme.brandPurple
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
                    style: GuestPurchasePlanTheme.addOnTitle,
                  ),
                ),
                _CheckBoxSquare(
                  checked: selected,
                  onTap: onToggle,
                ),
              ],
            ),
            const SizedBox(
                height: GuestPurchasePlanTheme.addOnCardTitleToDetailsGap),
            // Bottom row: icon + label + value on left and amount pill on right.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isSvg)
                  SvgPicture.asset(
                    iconPath,
                    width: GuestPurchasePlanTheme.addOnCardInfoIconSize,
                    height: GuestPurchasePlanTheme.addOnCardInfoIconSize,
                  )
                else
                  Image.asset(
                    iconPath,
                    width: GuestPurchasePlanTheme.addOnCardInfoIconSize,
                    height: GuestPurchasePlanTheme.addOnCardInfoIconSize,
                  ),
                const SizedBox(
                    width: GuestPurchasePlanTheme.addOnCardIconToLabelGap),
                Text(
                  addon.label, // data balance
                  style: GuestPurchasePlanTheme.addOnLabel,
                ),
                const SizedBox(
                    width: GuestPurchasePlanTheme.addOnCardLabelToValueGap),
                Expanded(
                  child: Text(
                    addon.value, // 1gb
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GuestPurchasePlanTheme.addOnValue,
                  ),
                ),
                const SizedBox(
                    width: GuestPurchasePlanTheme.addOnCardValueToPriceGap),
                _PricePill(price: addon.price),
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
        color: GuestPurchasePlanTheme.addOnPricePillBackground,
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: GuestPurchasePlanTheme.addOnPrice,
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
        GuestPurchasePlanTheme.addOnCheckboxRadius,
      ),
      child: Container(
        width: GuestPurchasePlanTheme.addOnCheckboxSize,
        height: GuestPurchasePlanTheme.addOnCheckboxSize,
        decoration: BoxDecoration(
          color: checked
              ? GuestPurchasePlanTheme.addOnCheckboxCheckedFillColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            GuestPurchasePlanTheme.addOnCheckboxRadius,
          ),
          border: Border.all(
            color: GuestPurchasePlanTheme.addOnCheckboxBorderColor,
            width: GuestPurchasePlanTheme.addOnCheckboxBorderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: checked
            ? const Icon(
                Icons.check,
                size: GuestPurchasePlanTheme.addOnCheckboxCheckIconSize,
                color: GuestPurchasePlanTheme.addOnCheckboxCheckIconColor,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
