import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewDetails;
  final VoidCallback onPurchaseNow;

  const PlanCard({
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
                  child: Row(
                    children: [
                      Text(
                        plan.title,
                        style: GuestPurchasePlanTheme.planCardTitleTextStyle,
                      ),
                      const SizedBox(
                        width: GuestPurchasePlanTheme.planCardTitleToArrowGap,
                      ),
                      SizedBox(
                        child: SvgPicture.asset(
                          expanded
                              ? AssetConstant.upArrowSVG
                              : AssetConstant.downArrowSVG,
                          width:
                              GuestPurchasePlanTheme.planCardToggleArrowWidth,
                          height:
                              GuestPurchasePlanTheme.planCardToggleArrowHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _PricePill(price: plan.price),
            ],
          ),

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              plan.subtitle,
              style: GuestPurchasePlanTheme.planCardSubtitleTextStyle,
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Scrollable benefits row + indicator bar
          _BenefitsRow(benefits: plan.benefits),

          // thin divider line like screenshot
          const SizedBox(height: 10),
          Container(height: 1, color: GuestPurchasePlanTheme.dividerColor),
          const SizedBox(height: 10),

          // ===== Expanded description =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                plan.description,
                style: GuestPurchasePlanTheme.planCardDescriptionTextStyle,
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
              const SizedBox(width: 12),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 66,
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(widget.benefits.length, (i) {
                final b = widget.benefits[i];

                return Row(
                  children: [
                    SizedBox(
                      width: 112,
                      height: 66,
                      child: _BenefitItem(benefit: b),
                    ),
                    if (i != widget.benefits.length - 1)
                      Container(
                        width: 1,
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: const Color(0xFFE6E6EC),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ✅ Horizontal scroll indicator (like screenshot)
        _ScrollIndicator(controller: _controller),
      ],
    );
  }
}

class _ScrollIndicator extends StatelessWidget {
  final ScrollController controller;

  const _ScrollIndicator({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const double trackW = 260;
    const double trackH = GuestPurchasePlanTheme.scrollBarThumbHeight;
    const double thumbW = GuestPurchasePlanTheme.scrollBarThumbWidth;

    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.hasClients) {
            return _indicatorUI(trackW, trackH, thumbW, 0);
          }

          final position = controller.position;

          // ✅ CRITICAL: maxScrollExtent safe only after content dimensions are ready
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
      ),
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
      return SvgPicture.asset(path,
          width: size, height: size, fit: BoxFit.contain);
    }
    return Image.asset(path, width: size, height: size, fit: BoxFit.contain);
  }
}

class _BenefitItem extends StatelessWidget {
  final PlanBenefit benefit;
  const _BenefitItem({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _AssetIcon(type: benefit.type, size: 16),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 28,
                  child: Text(
                    benefit.label,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 11.5,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D5A8B),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 16,
                  child: Text(
                    benefit.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 14,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 12,
                  child: Text(
                    benefit.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 10.2,
                      height: 1.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8B8B8B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
