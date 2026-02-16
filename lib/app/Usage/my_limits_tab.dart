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
            subtitle: '\$25.00 of \$30.00 remaining',
            percentUsed: 25,
            progressColor: Color(0xFFE07A4E),
          ),
          const Divider(color: divider),

          const _LimitRow(
            title: 'local data',
            subtitle: '\$15.00 of \$30.00 remaining',
            percentUsed: 2,
            progressColor: Color(0xFF6CB7D4),
          ),
          const Divider(color: divider),

          const _LimitRow(
            title: 'local talk mins',
            subtitle: '\$27.00 of \$30.00 remaining',
            percentUsed: 55,
            progressColor: Color(0xFF6B63C5),
          ),
          const Divider(color: divider),

          const _LimitRow(
            title: 'int’l roaming',
            subtitle: '\$0.00 of \$150.00 remaining',
            percentUsed: 0,
            progressColor: Color(0xFFBDBDBD),
          ),
          const Divider(color: divider),

          const _LimitRow(
            title: 'int’l talk mins',
            subtitle: '\$122.00 of \$150.00 remaining',
            percentUsed: 55,
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
                    fontSize: 13,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                child:
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(6),
                    //   child: LinearProgressIndicator(
                    //     value: percentUsed / 100,
                    //     minHeight: 6,
                    //     backgroundColor: progressColor.withOpacity(0.2),
                    //     valueColor: AlwaysStoppedAnimation(progressColor),
                    //   ),
                    // ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = 120 * percentUsed.clamp(0.0, 1.0);

                          return Stack(
                            children: [
                              // Background
                              Container(
                                height: 6,
                                width: 120,
                                color: Color(0x3F808080).withOpacity(0.2),
                              ),

                              // Gradient progress (width = percentage)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 6,
                                width: width.toDouble(),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: title == 'local text'
                                        ? [Color(0xFFF0D7CE), Color(0xFFE94408)]
                                        : title == 'local data'
                                        ? [
                                            const Color(0xFF97E3F8),
                                            const Color(0xFF00627D),
                                          ]
                                        : title == 'local talk mins' ||
                                                title == 'int’l talk mins'
                                        ? [
                                            const Color(0xFFCCC7F8),
                                            const Color(0xFF1F1B41),
                                          ]
                                        : [
                                            const Color(0x3F808080),
                                            const Color(0x3F808080),
                                          ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '$percentUsed% used',
                style: const TextStyle(
                  color: const Color(0xFF707070),
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
