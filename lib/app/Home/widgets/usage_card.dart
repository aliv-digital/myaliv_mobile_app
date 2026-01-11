import 'package:flutter/material.dart';

class UsageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String total;
  final String remainingLabel;
  final double progress;
  final Color color;

  const UsageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.total,
    required this.remainingLabel,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'CircularPro',
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' of\n',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextSpan(
                  text: total,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            remainingLabel,
            style: TextStyle(
              fontFamily: 'CircularPro',
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          _progressBar(),
        ],
      ),
    );
  }

  Widget _progressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: color.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
