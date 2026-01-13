import 'package:flutter/material.dart';
import '../theme/change_password_prepaid_theme.dart';

class ChangePasswordPrepaidHeaderText extends StatelessWidget {
  const ChangePasswordPrepaidHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'your new password may contain letters and/or\n'
          'numbers and be at least 4 characters long',
      textAlign: TextAlign.left,
      style: ChangePasswordPrepaidTheme.helper,
    );
  }
}
