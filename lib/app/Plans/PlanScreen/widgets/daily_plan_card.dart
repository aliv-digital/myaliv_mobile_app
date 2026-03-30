import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/data/plan_bucket_icons.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

// Daily plan card — aligned to HomePlanMonthlyPlanCard layout
class HomePlanDailyPlanCard extends StatelessWidget {
  final DailyPlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails;
  final VoidCallback onPurchaseNow;

  const HomePlanDailyPlanCard({
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
                            width: HomePlanTheme.planCardTitleToArrowGap,
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
                        '1 day',
                        style: HomePlanTheme.planCardSubtitleTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
              _PricePill(price: plan.planAmount,vatAmount: plan.vatAmount),
            ],
          ),

          const SizedBox(height: HomePlanTheme.planCardSectionSpacing),

          // Scrollable benefits row + indicator bar
          _PlanBuckets(benefits: plan.planBuckets),

          const SizedBox(height: HomePlanTheme.planCardSectionSpacing),

          // ===== Expanded description =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
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

          // ===== Buttons ALWAYS visible (collapsed + expanded) =====
          Row(
            children: [
              Expanded(
                child: DefaultButton(
                  label: expanded ? HomePlanTheme.planCardHideDetailsLabel : HomePlanTheme.planCardViewDetailsLabel,
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
  final double vatAmount;
  const _PricePill({required this.price,required this.vatAmount});

  @override
  Widget build(BuildContext context) {
    final finalPrice = price+vatAmount;
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
  final List<DailyPlanBucketModel> benefits;
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
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(widget.benefits.length, (i) {
                          final item = widget.benefits[i];
                          Color labelColor;

                          BucketItemType itemType = BucketItemType.whatsApp;

                          if(item.bucketUnit == 'INS_Data' && item.unit == 'GB'){
                            // data icon
                           // labelColor = HomePlanTheme.dataColor;
                            itemType = BucketItemType.data;

                          }else if(item.bucketUnit == 'INS_DATA_UNLIMITED' && item.unit == 'GB'){
                            // data icon
                            //labelColor = HomePlanTheme.dataColor;
                            itemType = BucketItemType.data;
                          }else if(item.bucketUnit == 'INS_Whatsapp_Text_10201' && item.unit == 'Text'){
                            itemType = BucketItemType.whatsApp;
                            // whatsApp icon
                          }else if(item.bucketUnit ==  'INS_Whatsapp_All' && item.unit == 'GB'){
                            itemType = BucketItemType.whatsApp;

                            // whatsapp icon
                          }else if(item.bucketUnit == 'INS_LDI_US_CANADA' && item.unit == 'Minutes'){
                            //BucketUnit  ==   INS_LDI_US_CANADA && unit == Minutes → call icon
                            itemType = BucketItemType.call;
                          }else if(item.bucketUnit == 'INS_LDI_US_CANADA' && item.unit == 'Text'){
                            itemType = BucketItemType.internationalSMS;
                            // BucketUnit  ==   INS_LDI_US_CANADA && unit == Text → message icon
                          }
                          else if(item.bucketUnit == 'INS_Voice_Only_National' && item.unit == 'Minutes'){
                            // BucketUnit  ==   INS_Voice_Only_National && unit == Minutes → call icon
                            itemType = BucketItemType.call;
                            // BucketUnit  ==   INS_Voice_Only_National && unit == Minutes → call icon
                          }else if(item.bucketUnit == 'INS_Voice_Only_National' && item.unit == 'Text'){
                            // BucketUnit  ==   INS_Voice_Only_National && unit == Text → sms icon
                            itemType = BucketItemType.sms;
                           // BucketUnit  ==   INS_Voice_Only_National && unit == Text → sms icon
                           // Unlimited == true → need to show unlimited  else show the amount

                        }else if(item.bucketUnit == 'INS_SMS_Only_National' && item.unit == 'Text'){
                            itemType = BucketItemType.sms;
                            //BucketUnit  ==  INS_SMS_Only_National && unit == Text → sms icon
                            //Unlimited == true → need to show unlimited  else show the amount
                          }else if(item.bucketUnit == 'INS_SMS_US_Canada' && item.unit == 'Text'){
                            itemType = BucketItemType.internationalSMS;
                            //BucketUnit→  INS_SMS_US_Canada && unit == Text → sms icon
                            //Unlimited == true → need to show unlimited  else show the amount
                          }else if(item.bucketUnit == 'INS_Voice_Nat_US' && item.unit == 'Minutes'){
                            itemType = BucketItemType.call;
                            //
                           // BucketUnit→  INS_Voice_Nat_US && unit == Minutes → call icon
                          //  Unlimited == true → need to show unlimited  else show the amount

                          }else if(item.bucketUnit == 'INS_Sms_Nat_US' && item.unit == 'Text'){
                            itemType = BucketItemType.internationalSMS;
                            //BucketUnit→  INS_Sms_Nat_US && unit == Text → sms icon
                            //Unlimited == true → need to show unlimited  else show the amount

                        }else if(item.bucketUnit == 'INS_Voice_Onnet' && item.unit == 'Minutes'){
                            itemType = BucketItemType.call;
                            //BucketUnit→  INS_Voice_Onnet && unit == Minutes → call icon
                            //Unlimited == true → need to show unlimited  else show the amount

                          }else if(item.bucketUnit == 'INS_SMS_Onnet' && item.unit == 'Text'){
                            itemType = BucketItemType.sms;
                            //BucketUnit→  INS_SMS_Onnet && unit == Text → sms icon
                            //Unlimited == true → need to show unlimited  else show the amount
                          }else if(item.bucketUnit == 'INS_MMS_Nat_US' && item.unit == 'Text'){
                            itemType = BucketItemType.internationalSMS;
                            //BucketUnit→  INS_MMS_Nat_US && unit == Text → sms icon
                            //Unlimited == true → need to show unlimited  else show the amount
                          }else if(item.bucketUnit == 'INS_Data_MIFI' && item.unit == 'GB'){
                            itemType = BucketItemType.data;
                            //BucketUnit→  INS_Data_MIFI && unit == GB → data icon
                            //Unlimited == true → need to show unlimited  else show the amount
                          }else if(item.bucketUnit == 'INS_TikTok_10500' && item.unit == 'GB'){
                            itemType = BucketItemType.data;
                            //BucketUnit→  INS_TikTok_10500 && unit == GB → data icon
                            // Unlimited == true → need to show unlimited  else show the amount
                          }else if(item.bucketUnit == 'INS_Facebook_MSG_10403' && item.unit == 'GB'){
                            itemType = BucketItemType.data;
                            //BucketUnit→  INS_Facebook_MSG_10403 && unit == GB → data icon
                            // Unlimited == true → need to show unlimited  else show the amount
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
                                  labelColor:  labelColor,
                                  itemType: itemType,//labelColor,
                                ),
                              ),
                              if (i != widget.benefits.length - 1)
                                Container(
                                  width:HomePlanTheme.planBenefitDividerWidth,
                                  height: HomePlanTheme.planBenefitDividerHeight,
                                  margin: HomePlanTheme.planBenefitDividerHorizontalMargin,
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
              return _indicatorUI(trackW, trackH, thumbW, 0);
            }

            final position = controller.positions.first;
            if (!position.hasContentDimensions) {
              return _indicatorUI(trackW, trackH, thumbW, 0);
            }

            final maxScroll = position.maxScrollExtent;
            if (maxScroll <= 0) {
              return _indicatorUI(trackW, trackH, thumbW, 0);
            }

            final progress = (position.pixels / maxScroll).clamp(0.0, 1.0);
            final maxThumbTravel = (trackW - thumbW).clamp(0.0, trackW);
            final left = progress * maxThumbTravel;

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
    final path = PlanBucketIcons.forType(type);
    final lower = path.toLowerCase();
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
  final DailyPlanBucketModel benefit;
  final Color labelColor;
  const _BucketItem({required this.benefit, required this.labelColor,required this.itemType});

  // API bucket amounts always arrive as doubles, but UI should hide
  // meaningless trailing zero decimals like `3.000000` while preserving
  // real fractional values such as `0.34` or `4.052`.
  String _formatAmount(double amount) {
    final bool hasOnlyZeroFraction = (amount - amount.truncateToDouble()).abs() < 0.0000001;
    if (hasOnlyZeroFraction) {
      return amount.toStringAsFixed(0);
    }
    return amount.toString();
  }

  double _measureTextWidth(BuildContext context, String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    const iconSize = 14.0;
    const iconGap = 4.0;

    final labelStyle = TextStyle(
      fontFamily: 'CircularPro',
      fontSize: 12,
      height: 1.0,
      fontWeight: FontWeight.w500,
      color: labelColor,
    );

    final valueStyle = const TextStyle(
      fontFamily: 'CircularPro',
      fontSize: 16,
      height: 1.0,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    final subStyle = TextStyle(
      fontFamily: 'CircularPro',
      fontSize: 12,
      height: 1.0,
      fontWeight: FontWeight.w400,
      color: HomePlanTheme.subtitleColor,
    );

    final labelW = _measureTextWidth(context, benefit.name, labelStyle);
    final valueW = _measureTextWidth(context, benefit.unit, valueStyle);
    final subW = _measureTextWidth(context, benefit.amount.toString(), subStyle);
    final line1W = iconSize + iconGap + labelW;
    final contentW = [line1W, valueW, subW].reduce((a, b) => a > b ? a : b);
    final dynamicW = contentW + 16;

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
                benefit.unlimited ? "unlimited" : _formatAmount(benefit.amount),
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
