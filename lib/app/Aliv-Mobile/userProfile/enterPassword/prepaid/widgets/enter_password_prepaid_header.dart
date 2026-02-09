import 'package:flutter/material.dart';
import '../theme/enter_password_prepaid_theme.dart';

class EnterPasswordPrepaidHeader extends StatelessWidget {
  const EnterPasswordPrepaidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('Enter Password', style: EnterPasswordPrepaidTheme.title),
        SizedBox(height: 4),
        Text(
          'For security reasons, please enter your\npassword to continue.',
          textAlign: TextAlign.center,
          style: EnterPasswordPrepaidTheme.subtitle,
        ),
      ],
    );
  }
}
