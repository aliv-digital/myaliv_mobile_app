import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillPrimarySubmitButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const GuestPayBillPrimarySubmitButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        enabled ? GuestPayBillTheme.primary : GuestPayBillTheme.disabledBtn;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: enabled && !loading ? onTap : null,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'submit',
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
