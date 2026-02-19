import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

class HomePlanRoamEasyPlanCard extends StatelessWidget {
  final HomePlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails; // toggle expand/collapse
  final VoidCallback onPurchaseNow;

  const HomePlanRoamEasyPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onViewDetails,
    required this.onPurchaseNow,
  });

  @override
  Widget build(BuildContext context) {
    // same as roaming: prefer data benefit if exists
    final HomePlanBenefit? dataBenefit = plan.benefits
        .where((b) => b.type == HomePlanBenefitType.data)
        .cast<HomePlanBenefit?>()
        .firstWhere((b) => b != null, orElse: () => null);

    final HomePlanBenefit center = dataBenefit ?? plan.benefits.first;

    return Container(
      margin: HomePlanTheme.planCardOuterMargin,
      padding: HomePlanTheme.planCardInnerPadding,
      decoration: BoxDecoration(
        color: HomePlanTheme.planCardBackgroundColor,
        borderRadius:
            BorderRadius.circular(HomePlanTheme.planCardRadius),
        boxShadow: const [
          BoxShadow(
            color: HomePlanTheme.planCardShadowColor,
            blurRadius: HomePlanTheme.planCardShadowBlur,
            offset: HomePlanTheme.planCardShadowOffset,
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
                    HomePlanTheme.planCardHeaderTapRadius,
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
                                  HomePlanTheme.planCardTitleTextStyle,
                            ),
                          ),
                          const SizedBox(
                            width:
                                HomePlanTheme.planCardTitleToArrowGap,
                          ),
                          SizedBox(
                            child: SvgPicture.asset(
                              expanded
                                  ? AssetConstant.upArrowSVG
                                  : AssetConstant.downArrowSVG,
                              width: HomePlanTheme
                                  .planCardToggleArrowWidth,
                              height: HomePlanTheme
                                  .planCardToggleArrowHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        plan.subtitle,
                        style: HomePlanTheme.planCardSubtitleTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
              _PricePill(price: plan.price),
            ],
          ),

          const SizedBox(height: HomePlanTheme.planCardSectionSpacing),

          // ===== Center metric (data) =====
          _CenterMetric(benefit: center),

          const SizedBox(height: HomePlanTheme.planCardSectionSpacing),

          // ===== Expanded description =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                bottom: HomePlanTheme.planCardDescriptionBottomSpacing,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  plan.description,
                  textAlign: TextAlign.start,
                  style: HomePlanTheme.planCardDescriptionTextStyle,
                ),
              ),
            ),
          ),

          // ===== Buttons =====
          Row(
            children: [
              Expanded(
                child: DefaultButton(
                  label: expanded
                      ? HomePlanTheme.planCardHideDetailsLabel
                      : HomePlanTheme.planCardViewDetailsLabel,
                  isLoading: false,
                  onPressed: onViewDetails,
                  height: HomePlanTheme.planCardActionButtonHeight,
                  contentPadding:
                      HomePlanTheme.planCardActionButtonContentPadding,
                  backgroundColor:
                      HomePlanTheme.planCardViewDetailsBackgroundColor,
                  textStyle:
                      HomePlanTheme.planCardViewDetailsTextStyle,
                  borderSide: BorderSide(
                    color:
                        HomePlanTheme.planCardViewDetailsBorderColor,
                  ),
                  borderRadius: BorderRadius.circular(
                    HomePlanTheme.planCardActionButtonRadius,
                  ),
                ),
              ),
              const SizedBox(
                width: HomePlanTheme.planCardActionButtonsGap,
              ),
              Expanded(
                child: DefaultButton(
                  label: HomePlanTheme.planCardPurchaseNowLabel,
                  isLoading: false,
                  onPressed: onPurchaseNow,
                  height: HomePlanTheme.planCardActionButtonHeight,
                  contentPadding:
                      HomePlanTheme.planCardActionButtonContentPadding,
                  backgroundColor:
                      HomePlanTheme.planCardPurchaseNowBackgroundColor,
                  textStyle:
                      HomePlanTheme.planCardPurchaseNowTextStyle,
                  borderRadius: BorderRadius.circular(
                    HomePlanTheme.planCardActionButtonRadius,
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
      padding: HomePlanTheme.planPricePillPadding,
      decoration: BoxDecoration(
        color: HomePlanTheme.planPricePillBackground,
        borderRadius:
            BorderRadius.circular(HomePlanTheme.planPricePillRadius),
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: HomePlanTheme.planPricePillTextStyle,
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
