import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillInlineVerifyField extends StatelessWidget {
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const GuestPayBillInlineVerifyField({
    super.key,
    required this.hint,
    required this.keyboardType,
    required this.enabled,
    required this.loading,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: GuestPayBillTheme.fieldBg,
        borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: keyboardType,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                  color: GuestPayBillTheme.placeholder,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ).copyWith(hintText: hint),
            ),
          ),
          const SizedBox(width: 8),
          GuestPayBillInlineSubmitButton(
            loading: loading,
            enabled: enabled,
            onTap: onSubmit,
          ),
        ],
      ),
    );
  }
}

class GuestPayBillInlineSubmitButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const GuestPayBillInlineSubmitButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Keep the button visually active from initial state, then guard invalid submits.
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: GuestPayBillTheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        onPressed: loading
            ? null
            : () {
                if (enabled) {
                  onTap();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter required details first.'),
                  ),
                );
              },
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
