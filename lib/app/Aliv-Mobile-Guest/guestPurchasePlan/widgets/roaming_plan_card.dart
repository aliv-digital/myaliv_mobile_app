import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

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
      margin: GuestPurchasePlanTheme.planCardOuterMargin,
      padding: GuestPurchasePlanTheme.planCardInnerPadding,
      decoration: BoxDecoration(
        color: GuestPurchasePlanTheme.planCardBackgroundColor,
        borderRadius:
            BorderRadius.circular(GuestPurchasePlanTheme.planCardRadius),
        boxShadow: const [
          BoxShadow(
            color: GuestPurchasePlanTheme.planCardShadowColor,
            blurRadius: GuestPurchasePlanTheme.planCardShadowBlur,
            offset: GuestPurchasePlanTheme.planCardShadowOffset,
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
                  borderRadius: BorderRadius.circular(
                    GuestPurchasePlanTheme.planCardHeaderTapRadius,
                  ),
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
                              style:
                                  GuestPurchasePlanTheme.planCardTitleTextStyle,
                            ),
                          ),
                          const SizedBox(
                            width:
                                GuestPurchasePlanTheme.planCardTitleToArrowGap,
                          ),
                          Transform.translate(
                            offset: Offset(
                              -GuestPurchasePlanTheme
                                  .planCardArrowVisualInsetCompensation,
                              0,
                            ),
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 180),
                              turns: expanded ? 0.5 : 0.0,
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        plan.subtitle,
                        style: GuestPurchasePlanTheme.planCardSubtitleTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
              _PricePill(price: plan.price),
            ],
          ),

          const SizedBox(height: GuestPurchasePlanTheme.planCardSectionSpacing),

          // ===== Center metric (data only) =====
          _CenterMetric(benefit: center),

          const SizedBox(height: GuestPurchasePlanTheme.planCardSectionSpacing),

          // ===== Expanded description (like other cards) =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                bottom: GuestPurchasePlanTheme.planCardDescriptionBottomSpacing,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  plan.description,
                  textAlign: TextAlign.start,
                  style: GuestPurchasePlanTheme.planCardDescriptionTextStyle,
                ),
              ),
            ),
          ),

          // ===== Buttons (view/hide + purchase) =====
          Row(
            children: [
              Expanded(
                child: DefaultButton(
                  label: expanded
                      ? GuestPurchasePlanTheme.planCardHideDetailsLabel
                      : GuestPurchasePlanTheme.planCardViewDetailsLabel,
                  isLoading: false,
                  onPressed: onViewDetails,
                  height: GuestPurchasePlanTheme.planCardActionButtonHeight,
                  contentPadding:
                      GuestPurchasePlanTheme.planCardActionButtonContentPadding,
                  backgroundColor:
                      GuestPurchasePlanTheme.planCardViewDetailsBackgroundColor,
                  textStyle:
                      GuestPurchasePlanTheme.planCardViewDetailsTextStyle,
                  borderSide: BorderSide(
                    color:
                        GuestPurchasePlanTheme.planCardViewDetailsBorderColor,
                  ),
                  borderRadius: BorderRadius.circular(
                    GuestPurchasePlanTheme.planCardActionButtonRadius,
                  ),
                ),
              ),
              const SizedBox(
                width: GuestPurchasePlanTheme.planCardActionButtonsGap,
              ),
              Expanded(
                child: DefaultButton(
                  label: GuestPurchasePlanTheme.planCardPurchaseNowLabel,
                  isLoading: false,
                  onPressed: onPurchaseNow,
                  height: GuestPurchasePlanTheme.planCardActionButtonHeight,
                  contentPadding:
                      GuestPurchasePlanTheme.planCardActionButtonContentPadding,
                  backgroundColor:
                      GuestPurchasePlanTheme.planCardPurchaseNowBackgroundColor,
                  textStyle:
                      GuestPurchasePlanTheme.planCardPurchaseNowTextStyle,
                  borderRadius: BorderRadius.circular(
                    GuestPurchasePlanTheme.planCardActionButtonRadius,
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
      padding: GuestPurchasePlanTheme.planPricePillPadding,
      decoration: BoxDecoration(
        color: GuestPurchasePlanTheme.planPricePillBackground,
        borderRadius:
            BorderRadius.circular(GuestPurchasePlanTheme.planPricePillRadius),
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: GuestPurchasePlanTheme.planPricePillTextStyle,
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
