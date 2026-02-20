import 'package:flutter/material.dart';
import '../theme/auto_renew_auth_prepaid_theme.dart';

class AuthBodyCard extends StatelessWidget {
  final Widget child;

  const AuthBodyCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AutoRenewAuthPrepaidTheme.cardBackground,
        borderRadius: AutoRenewAuthPrepaidTheme.authBodyCardRadius,
        border: Border.all(color: AutoRenewAuthPrepaidTheme.cardBorder),
      ),
      padding: AutoRenewAuthPrepaidTheme.authBodyCardPadding,
      child: child,
    );
  }
}
