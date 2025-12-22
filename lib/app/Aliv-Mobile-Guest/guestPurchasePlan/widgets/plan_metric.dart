import 'package:flutter/material.dart';

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
          Icon(icon, size: 16, color: const Color(0xFF5D5A8B)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D5A8B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8B8B8B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
