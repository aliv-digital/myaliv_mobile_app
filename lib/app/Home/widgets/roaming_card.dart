import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class RoamingCard extends StatelessWidget {
  final String used;
  final String total;
  final double progress;

  const RoamingCard({
    super.key,
    required this.used,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    const Color roamingColor = Color(0xFFF2994A);

    return Container(
      padding: const EdgeInsets.fromLTRB(24,20,24,20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/Rss.svg', height: 18, width: 18),

              SizedBox(width: 4),
              Text(
                'roaming data',
                style: TextStyle(
                  color: const Color(0xFFFF6C36),
                  fontSize: 12,
                  fontFamily: 'Circular Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '0',
                  style: TextStyle(
                    color: const Color(0xFFFA762B),
                    fontSize: 16,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' of\n2 GB',
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
            'remaining',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF707070),
              fontSize: 12,
              fontFamily: 'Circular Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = 80 * progress.clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // Background
                    Container(
                      height: 6,
                      width: 80,
                      color: Color(0xFFE94408).withOpacity(0.2),
                    ),

                    // Gradient progress (width = percentage)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      width: width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF0D7CE), Color(0xFFE94408)],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
