import 'package:flutter/material.dart';

import '../theme/change_password_prepaid_theme.dart';

class ChangePasswordPrepaidHeaderText extends StatelessWidget {
  const ChangePasswordPrepaidHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'your password should contain letters and/or numbers and be between 8 to 64 characters long.',
        textAlign: TextAlign.center,
        style: ChangePasswordPrepaidTheme.helper,
      ),
    );
  }
}
