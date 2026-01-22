import 'package:flutter/material.dart';
import '../theme/enter_password_postpaid_theme.dart';

class EnterPasswordPostpaidHeader extends StatelessWidget {
  const EnterPasswordPostpaidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Enter Password', style: EnterPasswordPostpaidTheme.title),
        SizedBox(height: 10),
        Text(
          'For security reasons, please enter your\npassword to continue.',
          textAlign: TextAlign.center,
          style: EnterPasswordPostpaidTheme.subtitle,
        ),
      ],
    );
  }
}
