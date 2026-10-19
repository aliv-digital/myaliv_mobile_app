import 'package:flutter/material.dart';
import '../theme/edit_email_prepaid_theme.dart';

class EditEmailPrepaidInfoField extends StatelessWidget {
  final String label;
  final String value;

  const EditEmailPrepaidInfoField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toLowerCase(), style: EditEmailPrepaidTheme.fieldLabel),
        const SizedBox(height: 8),
        Text(value, style: EditEmailPrepaidTheme.fieldValue),
      ],
    );
  }
}
