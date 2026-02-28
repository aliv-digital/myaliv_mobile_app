import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../home/data/home_ui_config.dart';
import '../home/home_screen.dart';

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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 14,
        //     offset: Offset(0, 6),
        //   ),
        // ],
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
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            config.userType == UserType.postpaid
                ? '0.6 GB of\n0.25 GB'
                : '1.5 of\n2 GB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF222222),
              fontSize: 16,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'remaining',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF707070),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = 80 * progress.clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // Background
                    Container(
                      height: 6,
                      width: 80,
                      color: config.userType == UserType.postpaid
                          ? Color(0x26DD3038)
                          : Color(0xFF17B26A).withOpacity(0.2),
                    ),

                    // Gradient progress (width = percentage)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),

                        gradient: LinearGradient(
                          colors: config.userType == UserType.postpaid
                              ? [Color(0x00DD3038), const Color(0xFFDD3038)]
                              : [
                                  const Color(0x0017B26A),
                                  const Color(0xFF17B26A),
                                ],
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
