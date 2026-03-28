import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

import '../data/plan_icon_assets.dart';
import '../models/roaming_plan_model.dart';
import '../theme/theme.dart';

class HomePlanRoamingPlanCard extends StatelessWidget {
  final RoamingPlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails;
  final VoidCallback onPurchaseNow;

  const HomePlanRoamingPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onViewDetails,
    required this.onPurchaseNow,
  });

  @override
  Widget build(BuildContext context) {
    final RoamingPlanBucketModel? center = _preferredCenterBucket(
      plan.planBuckets,
    );

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
                              plan.planName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HomePlanTheme.planCardTitleTextStyle,
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
                        _durationText(plan),
                        style: HomePlanTheme.planCardSubtitleTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
              _PricePill(price: plan.planAmount),
            ],
          ),

          const SizedBox(height: HomePlanTheme.planCardSectionSpacing),

          // ===== Center metric (data only) =====
          if (center != null) _CenterMetric(bucket: center),

          const SizedBox(height: HomePlanTheme.planCardSectionSpacing),

          // ===== Expanded description (like other cards) =====
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
                  plan.planDescription,
                  textAlign: TextAlign.start,
                  style: HomePlanTheme.planCardDescriptionTextStyle,
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

  RoamingPlanBucketModel? _preferredCenterBucket(
    List<RoamingPlanBucketModel> buckets,
  ) {
    if (buckets.isEmpty) return null;

    for (final RoamingPlanBucketModel bucket in buckets) {
      if (bucket.unit.trim().toUpperCase() == 'GB') {
        return bucket;
      }
    }

    return buckets.first;
  }

  String _durationText(RoamingPlanModel plan) {
    if(plan.frequency == 'W'){
      return '7 days';
    }
    if(plan.frequency == 'M'){
      return '30 days';
    }
    if(plan.frequency == 'D'){
      return '1 day';
    }
    if(plan.frequency == 'H'){
      return '15 days';
    }
    if(plan.frequency == 'T'){
      return '10 days';
    }
    if(plan.frequency == 'S'){
      return '60 days';
    }
    if(plan.frequency == 'N'){
      return '90 days';
    }
    if(plan.frequency == 'B'){
      return '15 days';
    }
    if(plan.frequency == '3'){
      return '3 days';
    }
    if(plan.frequency == '5'){
      return '5 days';
    }
    if(plan.frequency == 'A'){
      return '1 year';
    }

    /*
    {
       "Key": "daily",
       "Value": "D"
   },
   {
       "Key": "3-day",
       "Value": "3"
   },
   {
       "Key": "5-day",
       "Value": "5"
   },
   {
       "Key": "weekly",
       "Value": "W"
   },
   {
       "Key": "10-day",
       "Value": "T"
   },
   {
       "Key": "biweekly",
       "Value": "B"
   },
   {
       "Key": "15-day",
       "Value": "H"
   },
   {
       "Key": "monthly",
       "Value": "M"
   },
   {
       "Key": "60-day",
       "Value": "S"
   },
   {
       "Key": "90-day",
       "Value": "N"
   },
   {
       "Key": "annually",
       "Value": "A"
   }
     */

    // final int? daysFromName = _extractDayCount(plan.planName);
    // if (daysFromName != null) {
    //   return '$daysFromName day${daysFromName == 1 ? '' : 's'}';
    // }
    //
    // final int? daysFromDescription = _extractDayCount(plan.planDescription);
    // if (daysFromDescription != null) {
    //   return '$daysFromDescription day${daysFromDescription == 1 ? '' : 's'}';
    // }

    return '';
  }

  int? _extractDayCount(String text) {
    String normalized = text.toLowerCase().replaceAll('-', ' ').trim();
    while (normalized.contains('  ')) {
      normalized = normalized.replaceAll('  ', ' ');
    }

    final List<String> tokens = normalized.isEmpty ? const <String>[] : normalized.split(' ');

    for (int i = 0; i < tokens.length - 1; i++) {
      final int? days = int.tryParse(tokens[i]);
      if (days != null && tokens[i + 1].startsWith('day')) {
        return days;
      }
    }

    return null;
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
  final RoamingPlanBucketModel bucket;
  const _CenterMetric({required this.bucket});

  String _formatAmount(double amount) {
    final bool hasOnlyZeroFraction = (amount - amount.truncateToDouble()).abs() < 0.0000001;
    if (hasOnlyZeroFraction) {
      return amount.toStringAsFixed(0);
    }
    return amount.toString();
  }

  String _labelText(RoamingPlanBucketModel bucket) {
    if (bucket.unit.trim().toUpperCase() == 'GB') {
      return 'data';
    }
    return bucket.name.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final String iconPath = HomePlanIconAssets.data;
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
              _labelText(bucket),
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
          bucket.unlimited ? 'unlimited' : _formatAmount(bucket.amount),
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
          bucket.unit.toLowerCase(),
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
