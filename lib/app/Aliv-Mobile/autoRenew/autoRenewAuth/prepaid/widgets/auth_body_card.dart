import 'package:flutter/material.dart';
import '../theme/auto_renew_auth_prepaid_theme.dart';

class AuthBodyCard extends StatelessWidget {
  final Widget child;

  const AuthBodyCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AutoRenewAuthPrepaidTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AutoRenewAuthPrepaidTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
