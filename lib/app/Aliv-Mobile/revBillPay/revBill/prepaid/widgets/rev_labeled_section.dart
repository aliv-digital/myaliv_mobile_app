import 'package:flutter/material.dart';
import '../theme/rev_prepaid_theme.dart';

class RevLabeledSection extends StatelessWidget {
  final String label;
  final Widget child;

  const RevLabeledSection({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextStyle(
            color: const Color(0xFF1C1C1C) /* Black-100% */,
            fontSize: 14,
            fontFamily: 'Circular Pro',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
            // style: RevPrepaidTheme.label
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
