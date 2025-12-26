import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// for PlanBenefitType (data icon)
import '../data/plan_icon_assets.dart';
import '../models/add_on_model.dart';
import '../models/plan_model.dart';

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

  static const Color _brand = Color(0xFF5D5A8B);
  static const Color _bg = Color(0xFFF6F6FB);
  static const Color _accent = Color(0xFFFF5A3C);

  @override
  Widget build(BuildContext context) {
    final iconPath = PlanIconAssets.forType(PlanBenefitType.data);
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _brand, width: 1.2),
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
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      if (isSvg)
                        SvgPicture.asset(iconPath, width: 16, height: 16)
                      else
                        Image.asset(iconPath, width: 16, height: 16),
                      const SizedBox(width: 6),
                      Text(
                        addon.label, // data balance
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          addon.value, // 1gb
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'CircularPro',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
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

  static const Color _brand = Color(0xFF5D5A8B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: _brand, width: 1.2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _brand,
        ),
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

  static const Color _brand = Color(0xFF5D5A8B);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: checked ? _brand : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _brand, width: 1.2),
        ),
        alignment: Alignment.center,
        child: checked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
