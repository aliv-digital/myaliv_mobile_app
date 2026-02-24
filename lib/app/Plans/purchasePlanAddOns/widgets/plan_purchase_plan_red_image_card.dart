import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';

/// Reusable red plan card using design image background.
/// Texts are drawn on top of the image using fixed, pixel-safe positions.
class PlanPurchasePlanRedImageCard extends StatelessWidget {
  const PlanPurchasePlanRedImageCard({
    super.key,
    required this.planLabel,
    required this.planName,
    required this.activeLabel,
    required this.activeDate,
    required this.expireLabel,
    required this.expireDate,
    this.topRight,
    this.maxWidth = 340,
    this.height = 150,
    this.borderRadius = 12,
  });

  final String planLabel;
  final String planName;
  final String activeLabel;
  final String activeDate;
  final String expireLabel;
  final String expireDate;
  final Widget? topRight;

  final double maxWidth;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AssetConstant.planRedCardPNG,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: PlanPurchasePlanAddOnsTheme.planRed,
                  ),
                ),
                Padding(
                  padding: PlanPurchasePlanAddOnsTheme.planRedCardContentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            planLabel,
                            style: PlanPurchasePlanAddOnsTheme.t(
                              12,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          if (topRight != null) topRight!,
                        ],
                      ),
                      Text(
                        planName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PlanPurchasePlanAddOnsTheme.t(
                          24,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _DateBlock(
                              label: activeLabel,
                              value: activeDate,
                              alignEnd: false),
                          const Spacer(),
                          _DateBlock(
                              label: expireLabel,
                              value: expireDate,
                              alignEnd: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.label,
    required this.value,
    required this.alignEnd,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: PlanPurchasePlanAddOnsTheme.t(
            12,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: PlanPurchasePlanAddOnsTheme.t(
            15,
            weight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
          ).copyWith(letterSpacing: 2.25),
        ),
      ],
    );
  }
}
