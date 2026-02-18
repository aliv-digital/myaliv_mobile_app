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
        Text(label, style: RevPrepaidTheme.fieldTitle),
        const SizedBox(height: RevPrepaidTheme.labelToFieldGap),
        child,
      ],
    );
  }
}
