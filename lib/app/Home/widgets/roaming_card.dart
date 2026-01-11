import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(IconsaxPlusLinear.wifi, color: roamingColor),
              SizedBox(width: 6),
              Text(
                'roaming data',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  color: roamingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'CircularPro',
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: used,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' of\n'),
                TextSpan(
                  text: total,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'remaining',
            style: TextStyle(
              fontFamily: 'CircularPro',
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: roamingColor.withOpacity(0.2),
              valueColor:
              const AlwaysStoppedAnimation(roamingColor),
            ),
          ),
        ],
      ),
    );
  }
}
