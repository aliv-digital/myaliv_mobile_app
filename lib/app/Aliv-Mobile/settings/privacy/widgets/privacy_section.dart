import 'package:flutter/material.dart';
import '../theme/privacy_theme.dart';

class PrivacySection extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const PrivacySection({
    super.key,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: PrivacyTheme.title),
        const SizedBox(height: 16),
        ...paragraphs.map(
              (p) => Padding(
            padding: const EdgeInsets.only(bottom: 48),
            child: Text(p, style: PrivacyTheme.body),
          ),

        ),

      ],
    );
  }
}
