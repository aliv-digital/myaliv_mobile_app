import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';

class MyLimitsTab extends StatelessWidget {
  const MyLimitsTab({super.key});

  static const Color purple = Color(0xFF6C63A6);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFF7A7A7A);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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

        const SizedBox(height: 40),

        // ================= CTA =================
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // UI-only
              context.push(AppRoutes.upgradeCreditLimit);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: const Text(
              'update credit limit',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
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
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    color: Color(0xFF7A7A7A),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentUsed / 100,
                    minHeight: 6,
                    backgroundColor: progressColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$percentUsed% used',
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  color: Color(0xFF7A7A7A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
