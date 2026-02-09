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
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 31, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? HomePlanTheme.brandPurple : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(8, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // ===== Left content =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addon.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HomePlanTheme.addOnTitle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isSvg)
                        SvgPicture.asset(iconPath, width: 16, height: 16)
                      else
                        Image.asset(iconPath, width: 16, height: 16),
                      const SizedBox(width: 6),
                      Text(
                        addon.label, // data balance
                        style: HomePlanTheme.addOnLabel,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          addon.value, // 1gb
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HomePlanTheme.addOnValue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ===== Right side (checkbox + price) =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _CheckBoxSquare(checked: selected, onTap: onToggle),
                const SizedBox(height: 14),
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
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFF645D9C)),
          borderRadius: BorderRadius.circular(5),
        ),
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

  const _CheckBoxSquare({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: checked ? HomePlanTheme.brandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: HomePlanTheme.brandPurple, width: 1),
        ),
        alignment: Alignment.center,
        child: checked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
