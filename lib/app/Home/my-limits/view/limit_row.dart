import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/models/consumption_limit_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/animated_usage_progress.dart';

class LimitRow extends StatelessWidget {
  final ConsumptionLimitModel limit;

  const LimitRow({super.key, required this.limit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  limit.displayName,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${limit.remainingAmount.toStringAsFixed(2)} of '
                  '\$${limit.initialAmount.toStringAsFixed(2)} remaining',
                  style: const TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          AnimatedUsageProgress(percent: limit.percentUsed, width: 120),
        ],
      ),
    );
  }
}
