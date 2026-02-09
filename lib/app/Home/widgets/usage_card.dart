import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UsageCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final String total;
  final String remainingLabel;
  final double progress;
  final Color color;

  const UsageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.total,
    required this.remainingLabel,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154, //height: 124,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          // BoxShadow(
          //   color: Colors.black12,
          //   blurRadius: 14,
          //   offset: Offset(0, 6),
          // ),
        ],
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
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontFamily: 'Circular Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title == 'data' ? '2.4 GB' : 'unlimited',
                  style: TextStyle(
                    color: const Color(0xFFFA762B),
                    fontSize: 16,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: title == 'data' ? ' of\n14 GB' : '\nlocal',
                  style: TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 16,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            remainingLabel,
            style: TextStyle(
              color: const Color(0xFF707070),
              fontSize: 12,
              fontFamily: 'Circular Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _progressBar(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }


  // Widget _progressBar() {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(6),
  //     child: LinearProgressIndicator(
  //       value: progress,
  //       minHeight: 6,
  //       backgroundColor: color.withOpacity(0.2),
  //       valueColor: AlwaysStoppedAnimation(color),
  //     ),
  //   );
  // }
  Widget _progressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * progress.clamp(0.0, 1.0);

          return Stack(
            children: [
              // Background
              Container(height: 6, color: color.withOpacity(0.2)),

              // Gradient progress (width = percentage)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: title == 'data'
                        ? [Color(0xFFF0D7CE), Color(0xFFE94408)]
                        : title == 'sms'
                        ? [const Color(0xFFCCC7F8), const Color(0xFF1F1B41)]
                        : [const Color(0xFF97E3F8), const Color(0xFF00627D)],
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
