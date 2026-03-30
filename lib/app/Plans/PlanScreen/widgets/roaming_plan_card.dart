import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

import '../data/plan_bucket_icons.dart';
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
              _PricePill(
                price: plan.planAmount,
                vatAmount: plan.vatAmount,
              ),
            ],
          ),

          const SizedBox(height: HomePlanTheme.planCardSectionSpacing),

          _PlanBuckets(benefits: plan.planBuckets),

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

}

class _PricePill extends StatelessWidget {
  final double price;
  final double vatAmount;

  const _PricePill({
    required this.price,
    required this.vatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final double finalPrice = price + vatAmount;

    return Container(
      padding: HomePlanTheme.planPricePillPadding,
      decoration: BoxDecoration(
        color: HomePlanTheme.planPricePillBackground,
        borderRadius:
            BorderRadius.circular(HomePlanTheme.planPricePillRadius),
      ),
      child: Text(
        '\$ ${finalPrice.toStringAsFixed(2)}',
        style: HomePlanTheme.planPricePillTextStyle,
      ),
    );
  }
}

class _PlanBuckets extends StatefulWidget {
  final List<RoamingPlanBucketModel> benefits;
  const _PlanBuckets({required this.benefits});

  @override
  State<_PlanBuckets> createState() => _PlanBucketsRowState();
}

class _PlanBucketsRowState extends State<_PlanBuckets> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double rowH = 50;
    const double sidePad = 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: rowH,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: sidePad),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Align(
                      alignment: widget.benefits.length == 1
                          ? Alignment.center
                          : Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(widget.benefits.length, (i) {
                          final RoamingPlanBucketModel item = widget.benefits[i];
                          Color labelColor;
                          BucketItemType itemType = BucketItemType.whatsApp;

                          if (item.bucketUnit == 'INS_Data' && item.unit == 'GB') {
                            itemType = BucketItemType.data;
                          } else if (item.bucketUnit == 'INS_DATA_UNLIMITED' &&
                              item.unit == 'GB') {
                            itemType = BucketItemType.data;
                          } else if (item.bucketUnit == 'INS_Whatsapp_Text_10201' &&
                              item.unit == 'Text') {
                            itemType = BucketItemType.whatsApp;
                          } else if (item.bucketUnit == 'INS_Whatsapp_All' &&
                              item.unit == 'GB') {
                            itemType = BucketItemType.whatsApp;
                          } else if (item.bucketUnit == 'INS_LDI_US_CANADA' &&
                              item.unit == 'Minutes') {
                            itemType = BucketItemType.call;
                          } else if (item.bucketUnit == 'INS_LDI_US_CANADA' &&
                              item.unit == 'Text') {
                            itemType = BucketItemType.internationalSMS;
                          } else if (item.bucketUnit ==
                                  'INS_Voice_Only_National' &&
                              item.unit == 'Minutes') {
                            itemType = BucketItemType.call;
                          } else if (item.bucketUnit ==
                                  'INS_Voice_Only_National' &&
                              item.unit == 'Text') {
                            itemType = BucketItemType.sms;
                          } else if (item.bucketUnit ==
                                  'INS_SMS_Only_National' &&
                              item.unit == 'Text') {
                            itemType = BucketItemType.sms;
                          } else if (item.bucketUnit == 'INS_SMS_US_Canada' &&
                              item.unit == 'Text') {
                            itemType = BucketItemType.internationalSMS;
                          } else if (item.bucketUnit == 'INS_Voice_Nat_US' &&
                              item.unit == 'Minutes') {
                            itemType = BucketItemType.call;
                          } else if (item.bucketUnit == 'INS_Sms_Nat_US' &&
                              item.unit == 'Text') {
                            itemType = BucketItemType.internationalSMS;
                          } else if (item.bucketUnit == 'INS_Voice_Onnet' &&
                              item.unit == 'Minutes') {
                            itemType = BucketItemType.call;
                          } else if (item.bucketUnit == 'INS_SMS_Onnet' &&
                              item.unit == 'Text') {
                            itemType = BucketItemType.sms;
                          } else if (item.bucketUnit == 'INS_MMS_Nat_US' &&
                              item.unit == 'Text') {
                            itemType = BucketItemType.internationalSMS;
                          } else if (item.bucketUnit == 'INS_Data_MIFI' &&
                              item.unit == 'GB') {
                            itemType = BucketItemType.data;
                          } else if (item.bucketUnit == 'INS_TikTok_10500' &&
                              item.unit == 'GB') {
                            itemType = BucketItemType.data;
                          } else if (item.bucketUnit ==
                                  'INS_Facebook_MSG_10403' &&
                              item.unit == 'GB') {
                            itemType = BucketItemType.data;
                          } else if (item.bucketUnit == 'INS_Data_roam_as_home_v2' && item.unit == 'GB') {
                            itemType = BucketItemType.data;
                          }else if(item.bucketUnit == 'INS_Data_roam_as_home' && item.unit == 'GB'){
                            itemType = BucketItemType.data;
                          }

                          switch (itemType) {
                            case BucketItemType.data:
                              labelColor = HomePlanTheme.dataColor;
                              break;
                            case BucketItemType.call:
                              labelColor = HomePlanTheme.talkMinsColor;
                              break;
                            case BucketItemType.sms:
                              labelColor = HomePlanTheme.smsColor;
                              break;
                            case BucketItemType.whatsApp:
                              labelColor = HomePlanTheme.bonusDataColor;
                              break;
                            case BucketItemType.internationalSMS:
                              labelColor = HomePlanTheme.intlTalkTextColor;
                              break;
                          }

                          return Row(
                            children: [
                              SizedBox(
                                height: rowH,
                                child: _BucketItem(
                                  benefit: item,
                                  labelColor: labelColor,
                                  itemType: itemType,
                                ),
                              ),
                              if (i != widget.benefits.length - 1)
                                Container(
                                  width: HomePlanTheme.planBenefitDividerWidth,
                                  height:
                                      HomePlanTheme.planBenefitDividerHeight,
                                  margin: HomePlanTheme
                                      .planBenefitDividerHorizontalMargin,
                                  color: HomePlanTheme.planBenefitDividerColor,
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: sidePad),
          child: _ScrollIndicator(controller: _controller),
        ),
      ],
    );
  }
}

class _ScrollIndicator extends StatelessWidget {
  final ScrollController controller;
  const _ScrollIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    const double trackH = HomePlanTheme.scrollBarThumbHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackW = constraints.maxWidth;
        const double thumbW = HomePlanTheme.scrollBarThumbWidth;

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (!controller.hasClients || controller.positions.isEmpty) {
              return const SizedBox.shrink();
            }

            final ScrollPosition position = controller.positions.first;
            if (!position.hasContentDimensions) {
              return const SizedBox.shrink();
            }

            final double maxScroll = position.maxScrollExtent;
            if (maxScroll <= 0) {
              return const SizedBox.shrink();
            }

            final double progress =
                (position.pixels / maxScroll).clamp(0.0, 1.0);
            final double maxThumbTravel = (trackW - thumbW).clamp(0.0, trackW);
            final double left = progress * maxThumbTravel;

            return _indicatorUI(trackW, trackH, thumbW, left);
          },
        );
      },
    );
  }

  Widget _indicatorUI(
      double trackW, double trackH, double thumbW, double left) {
    return SizedBox(
      width: trackW,
      height: HomePlanTheme.scrollBarRenderBoxHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: (HomePlanTheme.scrollBarRenderBoxHeight - trackH) / 2,
            child: Container(
              width: trackW,
              height: trackH,
              decoration: BoxDecoration(
                color: HomePlanTheme.scrollBarBackgroundColor,
                borderRadius: BorderRadius.circular(
                  HomePlanTheme.scrollBarThumbRadius,
                ),
              ),
            ),
          ),
          Positioned(
            left: left,
            top: (HomePlanTheme.scrollBarRenderBoxHeight - trackH) / 2,
            child: Container(
              width: thumbW,
              height: trackH,
              decoration: BoxDecoration(
                color: HomePlanTheme.scrollBarThumbColor,
                borderRadius: BorderRadius.circular(
                  HomePlanTheme.scrollBarThumbRadius,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: HomePlanTheme.scrollBarThumbShadowColor,
                    blurRadius: HomePlanTheme.scrollBarShadowBlur,
                    offset: Offset(
                      HomePlanTheme.scrollBarShadowOffsetX,
                      HomePlanTheme.scrollBarShadowOffsetY,
                    ),
                    spreadRadius: HomePlanTheme.scrollBarShadowSpread,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetIcon extends StatelessWidget {
  final BucketItemType type;
  final double size;

  const _AssetIcon({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final String path = PlanBucketIcons.forType(type);
    final String lower = path.toLowerCase();
    if (lower.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(path, width: size, height: size, fit: BoxFit.contain);
  }
}

class _BucketItem extends StatelessWidget {
  final BucketItemType itemType;
  final RoamingPlanBucketModel benefit;
  final Color labelColor;

  const _BucketItem({
    required this.benefit,
    required this.labelColor,
    required this.itemType,
  });

  String _formatAmount(double amount) {
    final bool hasOnlyZeroFraction = (amount - amount.truncateToDouble()).abs() < 0.0000001;
    if (hasOnlyZeroFraction) {
      return amount.toStringAsFixed(0);
    }
    return amount.toString();
  }

  double _measureTextWidth(BuildContext context, String text, TextStyle style) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 14.0;
    const double iconGap = 4.0;

    final TextStyle labelStyle = TextStyle(
      fontFamily: 'CircularPro',
      fontSize: 12,
      height: 1.0,
      fontWeight: FontWeight.w500,
      color: labelColor,
    );

    final TextStyle valueStyle = const TextStyle(
      fontFamily: 'CircularPro',
      fontSize: 16,
      height: 1.0,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    final TextStyle subStyle = TextStyle(
      fontFamily: 'CircularPro',
      fontSize: 12,
      height: 1.0,
      fontWeight: FontWeight.w400,
      color: HomePlanTheme.subtitleColor,
    );

    final double labelW = _measureTextWidth(context, benefit.name, labelStyle);
    final double valueW = _measureTextWidth(
      context,
      benefit.unlimited ? 'unlimited' : _formatAmount(benefit.amount),
      valueStyle,
    );
    final double subW =
        _measureTextWidth(context, benefit.unit.toLowerCase(), subStyle);
    final double line1W = iconSize + iconGap + labelW;
    final double contentW = [line1W, valueW, subW].reduce(
      (a, b) => a > b ? a : b,
    );
    final double dynamicW = contentW + 16;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 72,
        maxWidth: 160,
      ),
      child: SizedBox(
        width: dynamicW.clamp(72, 160),
        height: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: iconGap),
                  child: _AssetIcon(type: itemType, size: iconSize),
                ),
                Text(
                  benefit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ],
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 16,
              child: Text(
                benefit.unlimited ? 'unlimited' : _formatAmount(benefit.amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 12,
              child: Text(
                benefit.unit.toLowerCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
