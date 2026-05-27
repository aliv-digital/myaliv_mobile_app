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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124, //height: 124,
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
            ],
          ),
          const SizedBox(height: 6),
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
          isPostpaid == false ? _progressBar() : _postpaidprogressBar(),
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  /// Prepaid bar: solid green palette, width = progress (1.0 for unlimited).
  /// Matches the Usage tab `_LimitRow` treatment for prepaid.
  Widget _progressBar() {
    return _bar(
      borderRadius: 6,
      backgroundColor: const Color(0x2617B26A),
      progressGradient: const LinearGradient(
        colors: [Color(0x0017B26A), Color(0xFF17B26A)],
      ),
    );
  }

  /// Postpaid bar: solid red palette, width = progress (1.0 for unlimited).
  /// Matches the Usage tab `_LimitRow` treatment for postpaid.
  Widget _postpaidprogressBar() {
    return _bar(
      borderRadius: 8,
      backgroundColor: const Color(0x26DD3038),
      progressGradient: const LinearGradient(
        colors: [Color(0x00DD3038), Color(0xFFDD3038)],
      ),
    );
  }

  Widget _bar({
    required double borderRadius,
    required Color backgroundColor,
    required LinearGradient progressGradient,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fraction = isUnlimited ? 1.0 : progress.clamp(0.0, 1.0);
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
                  gradient: progressGradient,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
