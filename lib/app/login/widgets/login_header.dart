import 'package:flutter/material.dart';
import '../theme/login_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _BackButtonRow(),
        SizedBox(height: 24),
        _LogoTitle(),
      ],
    );
  }
}

class _BackButtonRow extends StatelessWidget {
  const _BackButtonRow();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.arrow_back, size: 22),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class _LogoTitle extends StatelessWidget {
  const _LogoTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'aliv',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'welcome back',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: LoginColors.textBlack,
          ),
        ),
      ],
    );
  }
}
