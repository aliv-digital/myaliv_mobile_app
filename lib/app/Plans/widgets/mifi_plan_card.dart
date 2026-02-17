import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

class HomePlanMifiPlanCard extends StatelessWidget {
  final HomePlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails; // toggle expand/collapse
  final VoidCallback onPurchaseNow;

  const HomePlanMifiPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onViewDetails,
    required this.onPurchaseNow,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ mifi card center metric: data benefit prefer
    final HomePlanBenefit? dataBenefit = plan.benefits
        .where((b) => b.type == HomePlanBenefitType.data)
        .cast<HomePlanBenefit?>()
        .firstWhere((b) => b != null, orElse: () => null);

    final HomePlanBenefit center = dataBenefit ?? plan.benefits.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 31, vertical: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(8, 10),
            spreadRadius: 0,
          )
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              plan.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'CircularPro',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 0),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 180),
                            turns: expanded ? 0.5 : 0.0,
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        plan.subtitle,
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: HomePlanTheme.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _PricePill(price: plan.price),
            ],
          ),

          const SizedBox(height: 16),

          // ===== Center metric (data only) =====
          _CenterMetric(benefit: center),

          const SizedBox(height: 16),

          // ===== Expanded description =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 12),
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

          // ===== Buttons =====
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      backgroundColor: HomePlanTheme.viewDetailsButtonColor,
                    ),
                    onPressed: onViewDetails,
                    child: Text(
                      expanded ? 'hide details' : 'view details',
                      style: TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: HomePlanTheme.brandPurple,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HomePlanTheme.brandPurple,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: onPurchaseNow,
                    child: const Text(
                      'purchase now',
                      style: TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: HomePlanTheme.brandPurple, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: HomePlanTheme.brandPurple,
        ),
      ),
    );
  }
}

class _CenterMetric extends StatelessWidget {
  final HomePlanBenefit benefit;
  const _CenterMetric({required this.benefit});

  @override
  Widget build(BuildContext context) {
    final iconPath = HomePlanIconAssets.forType(benefit.type);
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
            const SizedBox(width: 2),
            Text(
              benefit.label.toLowerCase(),
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 12,
                height: 1.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFF6C36),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          benefit.value,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            height: 1.0,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          benefit.sub,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 12,
            height: 1.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF707070),
          ),
        ),
      ],
    );
  }
}
