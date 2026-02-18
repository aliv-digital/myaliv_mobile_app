import 'package:flutter/material.dart';
import '../theme/security_theme.dart';

class SecuritySection extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const SecuritySection({
    super.key,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: SecurityTheme.title),
        const SizedBox(height: 10),
        ...paragraphs.map(
              (p) => Padding(
            padding: const EdgeInsets.only(bottom: 34),
            child: Text(p, style: SecurityTheme.body),
          ),
        ),
      ],
    );
  }
}
