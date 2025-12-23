import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../data/plan_icon_assets.dart';
import '../models/plan_model.dart';

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

  static const Color _brand = Color(0xFF5D5A8B);
  static const Color _muted = Color(0xFF8B8B8B);
  static const Color _divider = Color(0xFFE9E9EE);

  @override
  Widget build(BuildContext context) {
    // Paste your FULL current PlanCard UI here (monthly version)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                  child: Row(
                    children: [
                      Text(
                        plan.title,
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 180),
                        turns: expanded ? 0.5 : 0.0,
                        child: const Icon(Icons.keyboard_arrow_down, size: 22),
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
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: _muted,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Scrollable benefits row + indicator bar
          _BenefitsRow(benefits: plan.benefits),

          // thin divider line like screenshot
          const SizedBox(height: 10),
          Container(height: 1, color: _divider),
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
                      backgroundColor: const Color(0xFFF1F1F6),
                    ),
                    onPressed: onViewDetails,
                    child: Text(
                      expanded ? 'hide details' : 'view details',
                      style: const TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _brand,
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
                      backgroundColor: _brand,
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

  static const Color _brand = Color(0xFF5D5A8B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: _brand, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\$ ${price.toStringAsFixed(2)}',
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: _brand,
        ),
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
    const double trackH = 6;
    const double thumbW = 58;

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

  Widget _indicatorUI(double trackW, double trackH, double thumbW, double left) {
    return Stack(
      children: [
        Container(
          width: trackW,
          height: trackH,
          decoration: BoxDecoration(
            color: const Color(0xFFE9E9EE),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Positioned(
          left: left,
          child: Container(
            width: thumbW,
            height: trackH,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8E2),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
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
      return SvgPicture.asset(path, width: size, height: size, fit: BoxFit.contain);
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