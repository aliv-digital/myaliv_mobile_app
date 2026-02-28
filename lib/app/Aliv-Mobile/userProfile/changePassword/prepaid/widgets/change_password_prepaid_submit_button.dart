import 'package:flutter/material.dart';
import '../theme/change_password_prepaid_theme.dart';

class ChangePasswordPrepaidSubmitButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const ChangePasswordPrepaidSubmitButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ChangePasswordPrepaidTheme.brand,
          disabledBackgroundColor: ChangePasswordPrepaidTheme.brand.withValues(alpha: 0.35),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Text(
          label,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF1F1F8),
          ),
        ),
      ),
    );
  }
}
