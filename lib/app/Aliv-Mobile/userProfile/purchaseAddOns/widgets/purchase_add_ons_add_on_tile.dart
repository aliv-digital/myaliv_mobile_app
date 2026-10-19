// __PARKED_PURCHASE_ADD_ONS__
// Parked: superseded by PlanScreen widgets reused via PurchaseAddOnsScreen.
// Kept (commented-out) for reversibility; safe to delete after QA.
/*
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/purchase_add_ons_models.dart';
import '../theme/purchase_add_ons_theme.dart';

/// Selectable add-on tile copied from PlanScreen add-ons UI.
///
/// API values can arrive as compact strings like `100minutes`; the formatter
/// keeps the amount intact and only shortens the unit label for display.
class PurchaseAddOnsAddOnTile extends StatelessWidget {
  final PurchaseAddOnsItem item;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const PurchaseAddOnsAddOnTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onChanged,
  });

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

    final prefix = trimmedValue.substring(0, minutesIndex).trimRight();
    final suffix = trimmedValue
        .substring(minutesIndex + minutesText.length)
        .trimLeft();

    final parts = <String>[
      if (prefix.isNotEmpty) prefix,
      'min',
      if (suffix.isNotEmpty) suffix,
    ];

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = PurchaseAddOnsTheme.outlinePurple;
    final cardRadius = BorderRadius.circular(
      PurchaseAddOnsTheme.addOnCardRadius,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: cardRadius,
        child: Container(
          decoration: BoxDecoration(
            color: PurchaseAddOnsTheme.cardWhite,
            borderRadius: cardRadius,
            border: selected
                ? Border.all(color: borderColor, width: 1.2)
                : null,
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 10),
                color: PurchaseAddOnsTheme.shadow,
              ),
            ],
          ),
          child: Padding(
            padding: PurchaseAddOnsTheme.addOnCardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: PurchaseAddOnsTheme.addOnTitle,
                      ),
                    ),
                    _SquareCheckbox(value: selected, onChanged: onChanged),
                  ],
                ),
                const SizedBox(
                  height: PurchaseAddOnsTheme.addOnCardTitleToDetailsGap,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _DataIcon(),
                          const SizedBox(
                            width: PurchaseAddOnsTheme.addOnCardIconToLabelGap,
                          ),
                          Text(
                            item.subtitleLabel,
                            style: PurchaseAddOnsTheme.addOnLabel,
                          ),
                          const SizedBox(
                            width: PurchaseAddOnsTheme.addOnCardLabelToValueGap,
                          ),
                          Text(
                            _formatSubtitleValue(item.subtitleValue),
                            style: PurchaseAddOnsTheme.addOnValue,
                          ),
                        ],
                      ),
                    ),
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
      padding: PurchaseAddOnsTheme.addOnAmountChipPadding,
      decoration: BoxDecoration(
        color: PurchaseAddOnsTheme.addOnAmountChipColor,
        borderRadius: BorderRadius.circular(
          PurchaseAddOnsTheme.addOnAmountChipRadius,
        ),
      ),
      child: Text(
        '$currencySymbol ${totalPrice.toStringAsFixed(2)}',
        style: PurchaseAddOnsTheme.addOnPrice,
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
    final borderColor = PurchaseAddOnsTheme.outlinePurple;
    final checkboxRadius = BorderRadius.circular(
      PurchaseAddOnsTheme.addOnCheckboxRadius,
    );

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: checkboxRadius,
      child: Container(
        width: PurchaseAddOnsTheme.addOnCheckboxSize,
        height: PurchaseAddOnsTheme.addOnCheckboxSize,
        decoration: BoxDecoration(
          borderRadius: checkboxRadius,
          border: Border.all(color: borderColor, width: 1),
          color: value ? borderColor : Colors.transparent,
        ),
        child: value
            ? const Icon(
                Icons.check,
                size: PurchaseAddOnsTheme.addOnCheckboxIconSize,
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
    const iconPath = AssetConstant.wifiIconSVG;
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.asset(
        iconPath,
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(
          PurchaseAddOnsTheme.addOnLabelColor,
          BlendMode.srcIn,
        ),
      );
    }
    return Image.asset(
      iconPath,
      width: 18,
      height: 18,
      color: PurchaseAddOnsTheme.addOnLabelColor,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}

*/
