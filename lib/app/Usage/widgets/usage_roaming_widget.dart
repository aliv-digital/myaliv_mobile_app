import 'package:flutter/material.dart';

class UsageRoamingPlanCard extends StatelessWidget {
  const UsageRoamingPlanCard({super.key});

  static const Color startColor = Color(0xFF00C4B3);
  static const Color endColor = Color(0xFF00B3E3);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
      ),
      child: Stack(
        children: [
          // -------- watermark --------
          Positioned(
            right: 80,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: Text(
                'aliv',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // -------- content --------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'active plan',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'roameasy usa and can',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  _DateColumn(
                    title: 'active',
                    value: '20/01/25',
                  ),
                  Spacer(),
                  _DateColumn(
                    title: 'expire',
                    value: '19/02/25',
                    alignRight: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _DateColumn extends StatelessWidget {
  final String title;
  final String value;
  final bool alignRight;

  const _DateColumn({
    required this.title,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
