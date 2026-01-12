import 'package:flutter/material.dart';
import '../theme/change_password_prepaid_theme.dart';

class ChangePasswordPrepaidPasswordField extends StatelessWidget {
  final String hint;
  final String value;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;

  const ChangePasswordPrepaidPasswordField({
    super.key,
    required this.hint,
    required this.value,
    required this.obscure,
    required this.onChanged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: ChangePasswordPrepaidTheme.inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ChangePasswordPrepaidTheme.inputBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 18, color: ChangePasswordPrepaidTheme.brand),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              obscureText: obscure,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ChangePasswordPrepaidTheme.hint,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.visibility_off,
                size: 18,
                color: ChangePasswordPrepaidTheme.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
