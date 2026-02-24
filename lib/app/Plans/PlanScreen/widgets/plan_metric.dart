import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PlanMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String sub;

  const PlanMetric({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: HomePlanTheme.brandPurple),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: HomePlanTheme.metricTitle,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: HomePlanTheme.metricValue,
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: HomePlanTheme.metricSub,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
