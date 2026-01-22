import 'package:flutter/material.dart';
import '../theme/enter_password_autoRenew_prepaid_theme.dart';

class EnterPasswordAutoRenewPrepaidHeader extends StatelessWidget {
  const EnterPasswordAutoRenewPrepaidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Enter Password', style: EnterPasswordAutoRenewPrepaidTheme.title),
        SizedBox(height: 10),
        Text(
          'For security reasons, please enter your\npassword to continue.',
          textAlign: TextAlign.center,
          style: EnterPasswordAutoRenewPrepaidTheme.subtitle,
        ),
      ],
    );
  }
}
