import 'package:flutter/material.dart';
import '../theme/rev_prepaid_theme.dart';

class RevReadonlyField extends StatelessWidget {
  final String text;

  const RevReadonlyField({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.all( 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: RevPrepaidTheme.fieldBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: RevPrepaidTheme.input),
    );
  }
}
