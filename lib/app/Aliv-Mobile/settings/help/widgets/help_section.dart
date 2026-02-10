import 'package:flutter/material.dart';
import '../theme/help_theme.dart';

class HelpSection extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const HelpSection({
    super.key,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: HelpTheme.title),
        const SizedBox(height: 16),
        ...paragraphs.map(
              (p) => Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: Text(p, style: HelpTheme.body),
          ),
        ),
      ],
    );
  }
}
