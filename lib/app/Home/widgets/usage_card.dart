import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UsageCard extends StatelessWidget {
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
          // TODO : 
          isPostpaid == false
              ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isUnlimited ? 'unlimited' : totalValue,

                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: isUnlimited ? '\nlocal' : ' of\n$totalRemaining',
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
              : isUnlimited
              ? const Text(
                  'unlimited',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 16,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$totalRemaining of \n',
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: totalValue,
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
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

  /// Prepaid bar: solid green, width = remaining (1.0 for unlimited).
  /// Matches the Usage tab `_LimitRow` treatment for prepaid.
  Widget _progressBar() {
    return _bar(
      borderRadius: 6,
      backgroundColor: const Color(0x2617B26A),
      progressColor: const Color(0xFF17B26A),
    );
  }

  /// Postpaid bar: width = remaining; color escalates green → yellow → red
  /// as `progress` (fraction used) grows, so a nearly-empty bar reads red.
  Widget _postPaidProgressBar() {
    final style = _resolvePostpaidStyle();
    return _bar(
      borderRadius: 8,
      backgroundColor: style.backgroundColor,
      progressColor: style.color,
    );
  }

  _ProgressStyle _resolvePostpaidStyle() {
    if (isUnlimited) {
      return const _ProgressStyle(
        backgroundColor: Color(0x2617B26A),
        color: Color(0xFF17B26A),
      );
    }

    final clamped = (progress.clamp(0.0, 1.0) * 100).round();

    if (clamped > 80) {
      return const _ProgressStyle(
        backgroundColor: Color(0x26DD3038),
        color: Color(0xFFDD3038),
      );
    }

    if (clamped > 50) {
      return const _ProgressStyle(
        backgroundColor: Color(0x26FFC627),
        color: Color(0xFFFFC627),
      );
    }

    return const _ProgressStyle(
      backgroundColor: Color(0x2617B26A),
      color: Color(0xFF17B26A),
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

class _ProgressStyle {
  final Color backgroundColor;
  final Color color;

  const _ProgressStyle({required this.backgroundColor, required this.color});
}
