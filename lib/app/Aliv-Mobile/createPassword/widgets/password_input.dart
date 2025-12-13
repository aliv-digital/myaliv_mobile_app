import 'package:flutter/material.dart';

import '../../login/theme/login_theme.dart';


class PasswordInput extends StatelessWidget {
  const PasswordInput({
    super.key,
    required this.hint,
    required this.obscureText,
    required this.onChanged,
    required this.onToggle,
  });

  final String hint;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: 1,
          color: AuthModuleColors.textInputBorderColor//const Color(0xFFE6E6EA), // চাইলে #DFDFDF করে দিও
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 18,
            color: AuthModuleColors.lockColor,
          ),
          const SizedBox(width: 10),

          // TextField (no extra padding)
          Expanded(
            child: TextField(
              obscureText: obscureText,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                height: 1.43,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w400,
                color: Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  height: 1.43,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFB7B7C2),
                ),
                border: InputBorder.none,
                isCollapsed: true, // important: removes default vertical padding
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Eye icon (fixed tap area, no IconButton padding issues)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color:AuthModuleColors.lockColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
