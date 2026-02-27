import 'package:flutter/material.dart';
import '../theme/rev_prepaid_theme.dart';

class RevPrimaryButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onTap;

  const RevPrimaryButton({
    super.key,
    required this.text,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 40,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? RevPrepaidTheme.appBarBg : RevPrepaidTheme.proceedDisabled,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: RevPrepaidTheme.button.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}
