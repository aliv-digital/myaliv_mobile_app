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
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? GuestPurchasePlanTheme.brandPurple : Colors.transparent,
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
                    style: GuestPurchasePlanTheme.addOnTitle,
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
                        style: GuestPurchasePlanTheme.addOnLabel,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          addon.value, // 1gb
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GuestPurchasePlanTheme.addOnValue,
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
                _CheckBoxSquare(
                  checked: selected,
                  onTap: onToggle,
                ),
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
      decoration: BoxDecoration(
        border: Border.all(color: GuestPurchasePlanTheme.brandPurple, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
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
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: checked ? GuestPurchasePlanTheme.brandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: GuestPurchasePlanTheme.brandPurple, width: 1),
        ),
        alignment: Alignment.center,
        child: checked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
