import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/widgets/usage_progress_bar.dart';

class UsageCard extends StatelessWidget {
  static const double _valueTextSlotHeight = 40;

  final String icon;
  final String title;
  final String totalValue;
  final String totalRemaining;
  final String remainingLabel;
  final double progress;
  final Color color;
  final bool isPostpaid;
  final bool isUnlimited;
  final VoidCallback? onTap;
  final double width;

  const UsageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.totalValue,
    required this.totalRemaining,
    required this.remainingLabel,
    required this.progress,
    required this.color,
    required this.isPostpaid,
    this.isUnlimited = false,
    this.onTap,
    this.width = 124,
  });

  @override
  Widget build(BuildContext context) {
    final card = _cardContent();
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: card,
      ),
    );
  }

  Widget _cardContent() {
    return Container(
      width: width, //height: 124,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // boxShadow: const [
        //   // BoxShadow(
        //   //   color: Colors.black12,
        //   //   blurRadius: 14,
        //   //   offset: Offset(0, 6),
        //   // ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(icon, color: color, height: 18, width: 18),
              const SizedBox(width: 4),
              Flexible(
                fit: FlexFit.loose,
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: Text(
                    title,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: _valueTextSlotHeight,
            child: Center(child: _buildValueText()),
          ),
          const SizedBox(height: 16),
          Text(
            remainingLabel,
            style: TextStyle(
              color: const Color(0xFF707070),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          isPostpaid == false ? _progressBar() : _postPaidProgressBar(),
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _buildValueText() {
    if (!isPostpaid) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: isUnlimited ? 'unlimited' : totalValue,
              style: _valueTextStyle(),
            ),
            TextSpan(
              text: isUnlimited ? '\nlocal' : ' of\n$totalRemaining',
              style: _valueTextStyle(),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    if (isUnlimited) {
      return Text(
        'unlimited',
        textAlign: TextAlign.center,
        style: _valueTextStyle(),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$totalRemaining of \n', style: _valueTextStyle()),
          TextSpan(text: totalValue, style: _valueTextStyle()),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  TextStyle _valueTextStyle() {
    return const TextStyle(
      color: Color(0xFF222222),
      fontSize: 16,
      fontFamily: 'CircularPro',
      fontWeight: FontWeight.w700,
    );
  }

  /// Prepaid bar: solid green, width = remaining (1.0 for unlimited).
  /// Matches the Usage tab `_LimitRow` treatment for prepaid.
  Widget _progressBar() {
    final style = resolveUsageBarStyle(
      isPostpaid: false,
      progressUsed: progress,
      isUnlimited: isUnlimited,
    );
    return _bar(
      borderRadius: 6,
      backgroundColor: style.background,
      progressColor: style.fill,
    );
  }

  /// Postpaid bar: width = remaining; color escalates green → yellow → red
  /// as `progress` (fraction used) grows, so a nearly-empty bar reads red.
  Widget _postPaidProgressBar() {
    final style = resolveUsageBarStyle(
      isPostpaid: true,
      progressUsed: progress,
      isUnlimited: isUnlimited,
    );
    return _bar(
      borderRadius: 8,
      backgroundColor: style.background,
      progressColor: style.fill,
    );
  }

  /// Bar length encodes **remaining** (`1 - progress`) so the visible fill
  /// matches the "remaining" label and the "X of Y" copy: a brand-new plan
  /// shows a solid full bar; an exhausted plan shows only the faded
  /// background.
  Widget _bar({
    required double borderRadius,
    required Color backgroundColor,
    required Color progressColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fraction = isUnlimited ? 1.0 : (1.0 - progress.clamp(0.0, 1.0));
          final width = constraints.maxWidth * fraction;

          return Stack(
            children: [
              Container(height: 6, color: backgroundColor),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    colors: [progressColor.withValues(alpha: 0), progressColor],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
