import 'package:flutter/material.dart';

class UsageMetricRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final int percentUsed;
  final List<Color> gradient;

  const UsageMetricRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.percentUsed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT BAR + % TEXT
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ProgressBar(
                  progress: progress,
                  gradient: gradient,
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentUsed% used',
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1),
        const SizedBox(height: 14),
      ],
    );
  }
}
class _ProgressBar extends StatelessWidget {
  final double progress;
  final List<Color> gradient;

  const _ProgressBar({
    required this.progress,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey.shade200,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(colors: gradient),
          ),
        ),
      ),
    );
  }
}
