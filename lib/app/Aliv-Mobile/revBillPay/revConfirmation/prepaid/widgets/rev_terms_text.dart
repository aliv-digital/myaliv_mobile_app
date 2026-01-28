import 'package:flutter/material.dart';
import '../theme/rev_confirmation_prepaid_theme.dart';

class RevTermsText extends StatelessWidget {
  const RevTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text('By pressing “continue” you agree to the ', style: RevConfirmationPrepaidTheme.terms),
        Text('Terms &', style: RevConfirmationPrepaidTheme.link),
        const SizedBox(width: 4),
        Text('Conditions.', style: RevConfirmationPrepaidTheme.link),
      ],
    );
  }
}
