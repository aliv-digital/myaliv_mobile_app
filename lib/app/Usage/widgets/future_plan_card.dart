import 'package:flutter/material.dart';

class FuturePlanCard extends StatelessWidget {
  final String title;
  final String startDate;
  final String endDate;
  final List<Color> gradient;

  const FuturePlanCard({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // watermark
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
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _DateBlock(title: 'starts', value: startDate),
                  const Spacer(),
                  _DateBlock(
                    title: 'expire',
                    value: endDate,
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
class _DateBlock extends StatelessWidget {
  final String title;
  final String value;
  final bool alignRight;

  const _DateBlock({
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

