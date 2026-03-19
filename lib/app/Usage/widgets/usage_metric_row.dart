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
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Row(
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
                        color: const Color(0xFF222222),
                        fontSize: 12,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: const Color(0xFF707070),
                        fontSize: 12,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // RIGHT BAR + % TEXT
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // _ProgressBar(
                  //   progress: progress,
                  //   gradient: gradient,
                  // ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = 80 * percentUsed.clamp(0.0, 1.0);

                        return Stack(
                          children: [
                            // Background
                            Container(
                              height: 6,
                              width: 80,
                              color: Color(0x2617B26A).withValues(alpha: 0.2),
                            ),

                            // Gradient progress (width = percentage)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 8,
                              width: width.toDouble(),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [
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
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
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
