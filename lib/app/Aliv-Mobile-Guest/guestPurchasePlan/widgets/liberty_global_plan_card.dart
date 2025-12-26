import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';


class LibertyGlobalPlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails; // toggle expand/collapse
  final VoidCallback onPurchaseNow;

  const LibertyGlobalPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onViewDetails,
    required this.onPurchaseNow,
  });

  static const Color _brand = Color(0xFF5D5A8B);
  static const Color _muted = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    // ✅ liberty global center metric: prefer intl talk benefit
    final PlanBenefit? intlTalk = plan.benefits
        .where((b) => b.type == PlanBenefitType.intlTalkText)
        .cast<PlanBenefit?>()
        .firstWhere((b) => b != null, orElse: () => null);

    final PlanBenefit center = intlTalk ?? plan.benefits.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ===== Header row =====
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.title, // liberty global haiti
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'CircularPro',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 180),
                        turns: expanded ? 0.5 : 0.0,
                        child: const Icon(Icons.keyboard_arrow_down, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
              _PricePill(price: plan.price),
            ],
          ),

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              plan.subtitle, // 365 days
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _muted,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ===== Center metric (intl talk) =====
          _CenterMetric(benefit: center),

          // ===== Expanded description =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
            expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  plan.description,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 12.2,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
          ),

          // ===== Buttons =====
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      backgroundColor: const Color(0xFFF1F1F6),
                    ),
                    onPressed: onViewDetails,
                    child: Text(
                      expanded ? 'hide details' : 'view details',
                      style: const TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _brand,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    onPressed: onPurchaseNow,
                    child: const Text(
                      'purchase now',
                      style: TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: _brand, width: 1.2),
        borderRadius: BorderRadius.circular(8),
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

class _CenterMetric extends StatelessWidget {
  final PlanBenefit benefit;
  const _CenterMetric({required this.benefit});

  static const Color _muted = Color(0xFF8B8B8B);
  static const Color _accent = Color(0xFF00A9D8); // blue-ish like screenshot

  @override
  Widget build(BuildContext context) {
    final iconPath = PlanIconAssets.forType(benefit.type);
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSvg)
              SvgPicture.asset(iconPath, width: 16, height: 16)
            else
              Image.asset(iconPath, width: 16, height: 16),
            const SizedBox(width: 6),
            Text(
              benefit.label, // "int'l talk"
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          benefit.value, // "30"
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 22,
            height: 1.0,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          benefit.sub, // "talk mins"
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 13,
            height: 1.0,
            fontWeight: FontWeight.w400,
            color: _muted,
          ),
        ),
      ],
    );
  }
}
