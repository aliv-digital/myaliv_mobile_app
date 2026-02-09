import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';


class RoamingPlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails; // ✅ use as toggle from button
  final VoidCallback onPurchaseNow;

  const RoamingPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onViewDetails,
    required this.onPurchaseNow,
  });

  @override
  Widget build(BuildContext context) {
    // roaming card center benefit: prefer data benefit if exists
    final PlanBenefit? dataBenefit = plan.benefits
        .where((b) => b.type == PlanBenefitType.data)
        .cast<PlanBenefit?>()
        .firstWhere((b) => b != null, orElse: () => null);

    final PlanBenefit center = dataBenefit ?? plan.benefits.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                          color: GuestPurchasePlanTheme.subtitleColor,
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

          // ===== Expanded description (like other cards) =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
            expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  plan.description,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: 'Circular Pro',
                    fontSize: 10,
                    height: 1.38,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
          ),

          // ===== Buttons (view/hide + purchase) =====
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
                      backgroundColor: GuestPurchasePlanTheme.viewDetailsButtonColor,
                    ),
                    // ✅ this MUST toggle expanded
                    onPressed: onViewDetails,
                    child: Text(
                      expanded ? 'hide details' : 'view details',
                      style: TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: GuestPurchasePlanTheme.brandPurple,
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
                      backgroundColor: GuestPurchasePlanTheme.brandPurple,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: GuestPurchasePlanTheme.brandPurple, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: GuestPurchasePlanTheme.brandPurple,
        ),
      ),
    );
  }
}

class _CenterMetric extends StatelessWidget {
  final PlanBenefit benefit;
  const _CenterMetric({required this.benefit});

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
            const SizedBox(width: 0),
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
            fontSize: 22,
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
