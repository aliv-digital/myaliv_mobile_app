import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';
import '../theme/theme.dart';

// Daily plan card — aligned to HomePlanMonthlyPlanCard layout
class HomePlanDailyPlanCard extends StatelessWidget {
  final HomePlanModel plan;
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
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                          color: HomePlanTheme.subtitleColor,
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

          // Scrollable benefits row + indicator bar
          _BenefitsRow(benefits: plan.benefits),

          const SizedBox(height: 16),

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
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 12.2,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ),
          ),

          // ===== Buttons ALWAYS visible (collapsed + expanded) =====
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
                      backgroundColor: HomePlanTheme.viewDetailsButtonColor,
                    ),
                    onPressed: onViewDetails,
                    child: Text(
                      expanded ? 'hide details' : 'view details',
                      style: TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: HomePlanTheme.brandPurple,
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
                      backgroundColor: HomePlanTheme.brandPurple,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(
          color: HomePlanTheme.brandPurple,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: HomePlanTheme.brandPurple,
        ),
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
                                height: rowH,
                                child: _BenefitItem(
                                  benefit: b,
                                  labelColor: labelColor,
                                ),
                              ),
                              if (i != widget.benefits.length - 1)
                                Container(
                                  width: 1,
                                  height: 34,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  color: HomePlanTheme.dividerColor,
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
    const double trackH = 6;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackW = constraints.maxWidth;
        final double thumbW = (trackW * 0.22).clamp(78.0, 140.0);

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
    const double inset = 2;
    final double innerH = (trackH - inset * 2).clamp(0.0, trackH);

    return SizedBox(
      width: trackW,
      height: trackH + 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HomePlanTheme.scrollBarBackgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.all(inset),
          child: Stack(
            children: [
              Positioned(
                left: left,
                top: 0,
                bottom: 0,
                child: Container(
                  width: thumbW,
                  height: innerH + 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
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

    final labelW = _measureTextWidth(context, benefit.label, labelStyle);
    final valueW = _measureTextWidth(context, benefit.value, valueStyle);
    final subW = _measureTextWidth(context, benefit.sub, subStyle);
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
                  child: _AssetIcon(type: benefit.type, size: iconSize),
                ),
                Text(
                  benefit.label,
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
