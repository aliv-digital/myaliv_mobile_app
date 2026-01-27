import 'package:flutter/material.dart';
import '../theme/enter_password_autoRenew_prepaid_theme.dart';

class EnterPasswordAutoRenewPrepaidContinueButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const EnterPasswordAutoRenewPrepaidContinueButton({
    super.key,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: EnterPasswordAutoRenewPrepaidTheme.brand,
          disabledBackgroundColor:
          EnterPasswordAutoRenewPrepaidTheme.brand.withValues(alpha: 0.35),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'Continue',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
