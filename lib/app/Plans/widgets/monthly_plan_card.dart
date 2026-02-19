import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

// Monthly plan card — keep monthly UI here only
class HomePlanMonthlyPlanCard extends StatelessWidget {
  final HomePlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails;
  final VoidCallback onPurchaseNow;

  const HomePlanMonthlyPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onViewDetails,
    required this.onPurchaseNow,
  });

  //final Color _brand = HomePlanTheme.brandPurple;
  //static const Color _muted = Color(0xFF8B8B8B);
  //static const Color _divider = Color(0xFFE9E9EE);

  @override
  Widget build(BuildContext context) {
    // Paste your FULL current PlanCard UI here (monthly version)
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
                        mainAxisSize: MainAxisSize.min, // IMPORTANT
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            fit: FlexFit.loose, // IMPORTANT
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

          // Scrollable benefits row + indicator bar
          _BenefitsRow(benefits: plan.benefits),

          // thin divider line like screenshot
          const SizedBox(height: HomePlanTheme.planCardSectionSpacing),
          //Container(height: 1, color: HomePlanTheme.dividerColor),

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
                  plan.description,
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

  //static const Color _brand = Color(0xFF5D5A8B);

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

class _BenefitsRow extends StatefulWidget {
  final List<HomePlanBenefit> benefits;
  const _BenefitsRow({required this.benefits});

  @override
  State<_BenefitsRow> createState() => _BenefitsRowState();
}

class _BenefitsRowState extends State<_BenefitsRow> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double rowH = 50; // ✅ figma
    const double sidePad = 2; // ✅ screenshot মত margins (22-26 tune)

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: rowH,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: sidePad),
            child: SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(widget.benefits.length, (i) {
                  final b = widget.benefits[i];

                  Color labelColor;
                  switch (b.type) {
                    case HomePlanBenefitType.data:
                      labelColor = HomePlanTheme.dataColor;
                      break;
                    case HomePlanBenefitType.intlTalkText:
                      labelColor = HomePlanTheme.intlTalkTextColor;
                      break;
                    case HomePlanBenefitType.sms:
                      labelColor = HomePlanTheme.smsColor;
                      break;
                    case HomePlanBenefitType.bonusData:
                      labelColor = HomePlanTheme.bonusDataColor;
                      break;
                    case HomePlanBenefitType.mms:
                      labelColor = HomePlanTheme.mmsColor;
                      break;
                    case HomePlanBenefitType.talkMins:
                      labelColor = HomePlanTheme.talkMinsColor;
                      break;
                  }

                  return Row(
                    children: [
                      SizedBox(
                        // width: itemW,
                        height: rowH, //  50
                        child: _BenefitItem(
                          benefit: b,
                          labelColor: labelColor,
                        ),
                      ),
                      if (i != widget.benefits.length - 1)
                        Container(
                          width:
                              HomePlanTheme.planBenefitDividerWidth,
                          height:
                              HomePlanTheme.planBenefitDividerHeight,
                          margin: HomePlanTheme
                              .planBenefitDividerHorizontalMargin,
                          color:
                              HomePlanTheme.planBenefitDividerColor,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        //  indicator same side padding
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
            // No attach yet
            if (!controller.hasClients || controller.positions.isEmpty) {
              return _indicatorUI(trackW, trackH, thumbW, 0);
            }

            // IMPORTANT: avoid controller.position (it asserts if multiple clients)
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
  final HomePlanBenefitType type;
  final double size;

  const _AssetIcon({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = HomePlanIconAssets.forType(type);
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

class _BenefitItem extends StatelessWidget {
  final HomePlanBenefit benefit;
  final Color labelColor;
  const _BenefitItem({required this.benefit, required this.labelColor});

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

    // measure widths
    final labelW = _measureTextWidth(context, benefit.label, labelStyle);
    final valueW = _measureTextWidth(context, benefit.value, valueStyle);
    final subW = _measureTextWidth(context, benefit.sub, subStyle);

    // label line has icon + gap
    final line1W = iconSize + iconGap + labelW;

    // final width depends on longest line
    final contentW = [line1W, valueW, subW].reduce((a, b) => a > b ? a : b);

    // add some horizontal breathing space
    final dynamicW = contentW + 16; // padding feel

    return ConstrainedBox(
      constraints: BoxConstraints(
        // min/max তুমি চাইলে tune করতে পারো
        minWidth: 72,
        maxWidth: 160,
      ),
      child: SizedBox(
        width: dynamicW.clamp(72, 160),
        height: 50, // figma row height
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: iconGap),
                  child: _AssetIcon(type: benefit.type, size: iconSize),
                ),
                Text(
                  benefit.label,
                  maxLines: 1, // dynamic width হলে 1 line better
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ],
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 16,
              child: Text(
                benefit.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 12,
              child: Text(
                benefit.sub,
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
