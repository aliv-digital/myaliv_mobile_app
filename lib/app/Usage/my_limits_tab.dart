import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';

class MyLimitsTab extends StatelessWidget {
  const MyLimitsTab({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFF7A7A7A);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const _LimitRow(
            title: 'local text',
            subtitle: '\10.00 of \$30.00 remaining',
            percentUsed: 50,
            progressColor: Color(0xFFE07A4E),
          ),
          const Divider(color: divider),

          const _LimitRow(
            title: 'local data',
            subtitle: '\$15.00 of \$30.00 remaining',
            percentUsed: 50,
            progressColor: Color(0xFF6CB7D4),
          ),
          const Divider(color: divider),

          const _LimitRow(
            title: 'local talk mins',
            subtitle: '\$27.00 of \$30.00 remaining',
            percentUsed: 70,
            progressColor: Color(0xFF6B63C5),
          ),
          const Divider(color: divider),

          const _LimitRow(
            title: 'int’l roaming',
            subtitle: '\$0.00 of \$150.00 remaining',
            percentUsed: 100,
            progressColor: Color(0xFFBDBDBD),
          ),
          const Divider(color: divider),

          const _LimitRow(
            title: 'int’l talk mins',
            subtitle: '\$122.00 of \$150.00 remaining',
            percentUsed: 79,
            progressColor: Color(0xFF6B63C5),
          ),

          const SizedBox(height: 24),

          // ================= CTA =================
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(left: 38.0, right: 38),
              child: ElevatedButton(
                onPressed: () {
                  // UI-only
                  context.push(AppRoutes.upgradeCreditLimit);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'update credit limit',
                  style: TextStyle(
                    color: const Color(0xFFF1F1F8),
                    fontSize: 15,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int percentUsed;
  final Color progressColor;

  const _LimitRow({
    required this.title,
    required this.subtitle,
    required this.percentUsed,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    Color mainColor = Color(0x3F808080);
    LinearGradient gradient = LinearGradient(
      colors: [const Color(0x00DD3038), const Color(0xFFDD3038)],
    );
    if (percentUsed > 80) {
      mainColor = Color(0x26DD3038);
      gradient = LinearGradient(
        colors: [const Color(0x00DD3038), const Color(0xFFDD3038)],
      );
    } else if (percentUsed > 50) {
      mainColor = Color(0x26FFC627);
      gradient = LinearGradient(colors: [Color(0xFFFFC627), Color(0x26FFC627)]);
    } else {
      mainColor = Color(0x2617B26A);
      gradient = LinearGradient(colors: [const Color(0x0017B26A), const Color(0xFF17B26A)]);

    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
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
                const SizedBox(height: 6),
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

          // RIGHT PROGRESS
          AnimatedUsageProgress(percent: percentUsed,width: 120,),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     SizedBox(
          //       width: 120,
          //       child:
          //
          //           ClipRRect(
          //             borderRadius: BorderRadius.circular(6),
          //             child: LayoutBuilder(
          //               builder: (context, constraints) {
          //                 final progress =
          //                     (percentUsed.clamp(0, 100)) / 100; // convert to 0–1
          //                 final width = 120 * progress;
          //                 return Stack(
          //                   children: [
          //                     // Background
          //                     Container(
          //                       height: 6,
          //                       width: 120,
          //                       color: mainColor,
          //                     ),
          //
          //                     // Gradient progress (width = percentage)
          //                     AnimatedContainer(
          //                       duration: const Duration(milliseconds: 300),
          //                       height: 6,
          //                       width: width.toDouble(),
          //                       decoration: BoxDecoration(
          //                         gradient: gradient
          //
          //                       ),
          //                     ),
          //                   ],
          //                 );
          //               },
          //             ),
          //           ),
          //     ),
          //     const SizedBox(height: 8),
          //     Text(
          //       '$percentUsed% used',
          //       style: const TextStyle(
          //         color: const Color(0xFF707070),
          //         fontSize: 12,
          //         fontFamily: 'CircularPro',
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

class AnimatedUsageProgress extends StatelessWidget {
  final int percent; // 0–100
  final double width;
  final double height;

  const AnimatedUsageProgress({
    super.key,
    required this.percent,
    this.width = 120,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0, 100);
    final progress = clamped / 100;

    final _ProgressStyle style = _resolveStyle(clamped);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                children: [
                  // Background
                  Container(
                    width: width,
                    height: height,
                    color: style.backgroundColor,
                  ),

                  // Animated fill
                  Container(
                    width: width * value,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: style.gradient,
                      borderRadius: BorderRadius.circular(30),

                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "$clamped% used",
          style: const TextStyle(
            color: Color(0xFF707070),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  _ProgressStyle _resolveStyle(int percent) {
    if (percent == 0) {
      return _ProgressStyle(
        backgroundColor: const Color(0x3F808080),
        gradient: const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        ),
      );
    }

    if (percent > 80) {
      return _ProgressStyle(
        backgroundColor: const Color(0x26DD3038),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0x00DD3038),
            Color(0xFFDD3038),
          ],
        ),
      );
    }

    if (percent > 50) {
      return _ProgressStyle(
        backgroundColor: const Color(0x26FFC627),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0x00FFC627),
            Color(0xFFFFC627),
          ],
        ),
      );
    }

    return _ProgressStyle(
      backgroundColor: const Color(0x2617B26A),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0x0017B26A),
          Color(0xFF17B26A),
        ],
      ),
    );
  }
}

class _ProgressStyle {
  final Color backgroundColor;
  final LinearGradient gradient;

  _ProgressStyle({
    required this.backgroundColor,
    required this.gradient,
  });
}

