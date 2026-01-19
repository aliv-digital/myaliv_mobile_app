import 'package:flutter/material.dart';
import '../theme/top_up_prepaid_theme.dart';

class TopUpPrepaidPlaceholderTab extends StatelessWidget {
  final String title;

  const TopUpPrepaidPlaceholderTab({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title (coming soon)',
        style: const TextStyle(
          fontFamily: TopUpPrepaidTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TopUpPrepaidTheme.textMuted,
        ),
      ),
    );
  }
}
