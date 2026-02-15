import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

// Monthly plan card — keep monthly UI here only
class MonthlyPlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails;
  final VoidCallback onPurchaseNow;

  const MonthlyPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onViewDetails,
    required this.onPurchaseNow,
  });

  //final Color _brand = GuestPurchasePlanTheme.brandPurple;
  //static const Color _muted = Color(0xFF8B8B8B);
  //static const Color _divider = Color(0xFFE9E9EE);

  @override
  Widget build(BuildContext context) {
    // Paste your FULL current PlanCard UI here (monthly version)
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
                                  GuestPurchasePlanTheme.planCardTitleTextStyle,
                            ),
                          ),
                          const SizedBox(
                            width:
                                GuestPurchasePlanTheme.planCardTitleToArrowGap,
                          ),
                          SizedBox(
                            child: SvgPicture.asset(
                              expanded
                                  ? AssetConstant.upArrowSVG
                                  : AssetConstant.downArrowSVG,
                              width: GuestPurchasePlanTheme
                                  .planCardToggleArrowWidth,
                              height: GuestPurchasePlanTheme
                                  .planCardToggleArrowHeight,
                              fit: BoxFit.contain,
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

          // Scrollable benefits row + indicator bar
          _BenefitsRow(benefits: plan.benefits),

          // thin divider line like screenshot
          const SizedBox(height: GuestPurchasePlanTheme.planCardSectionSpacing),
          //Container(height: 1, color: GuestPurchasePlanTheme.dividerColor),

          // ===== Expanded description =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
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

          // ===== Buttons ALWAYS visible (collapsed + expanded) =====
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

  //static const Color _brand = Color(0xFF5D5A8B);

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

class _BenefitsRow extends StatefulWidget {
  final List<PlanBenefit> benefits;
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
                    case PlanBenefitType.data:
                      labelColor = GuestPurchasePlanTheme.dataColor;
                      break;
                    case PlanBenefitType.intlTalkText:
                      labelColor = GuestPurchasePlanTheme.intlTalkTextColor;
                      break;
                    case PlanBenefitType.sms:
                      labelColor = GuestPurchasePlanTheme.smsColor;
                      break;
                    case PlanBenefitType.bonusData:
                      labelColor = GuestPurchasePlanTheme.bonusDataColor;
                      break;
                    case PlanBenefitType.mms:
                      labelColor = GuestPurchasePlanTheme.mmsColor;
                      break;
                    case PlanBenefitType.talkMins:
                      labelColor = GuestPurchasePlanTheme.talkMinsColor;
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
                          width: 1,
                          height: 34, // 50 row এর ভিতরে balanced
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: GuestPurchasePlanTheme.dividerColor,
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
    const double trackH = GuestPurchasePlanTheme.scrollBarThumbHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackW = constraints.maxWidth;
        const double thumbW = GuestPurchasePlanTheme.scrollBarThumbWidth;

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
      height: GuestPurchasePlanTheme.scrollBarRenderBoxHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: (GuestPurchasePlanTheme.scrollBarRenderBoxHeight - trackH) / 2,
            child: Container(
              width: trackW,
              height: trackH,
              decoration: BoxDecoration(
                color: GuestPurchasePlanTheme.scrollBarBackgroundColor,
                borderRadius: BorderRadius.circular(
                  GuestPurchasePlanTheme.scrollBarThumbRadius,
                ),
              ),
            ),
          ),
          Positioned(
            left: left,
            top: (GuestPurchasePlanTheme.scrollBarRenderBoxHeight - trackH) / 2,
            child: Container(
              width: thumbW,
              height: trackH,
              decoration: BoxDecoration(
                color: GuestPurchasePlanTheme.scrollBarThumbColor,
                borderRadius: BorderRadius.circular(
                  GuestPurchasePlanTheme.scrollBarThumbRadius,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: GuestPurchasePlanTheme.scrollBarThumbShadowColor,
                    blurRadius: GuestPurchasePlanTheme.scrollBarShadowBlur,
                    offset: Offset(
                      GuestPurchasePlanTheme.scrollBarShadowOffsetX,
                      GuestPurchasePlanTheme.scrollBarShadowOffsetY,
                    ),
                    spreadRadius: GuestPurchasePlanTheme.scrollBarShadowSpread,
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
  final PlanBenefitType type;
  final double size;

  const _AssetIcon({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = PlanIconAssets.forType(type);
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
  final PlanBenefit benefit;
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
      color: GuestPurchasePlanTheme.subtitleColor,
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
