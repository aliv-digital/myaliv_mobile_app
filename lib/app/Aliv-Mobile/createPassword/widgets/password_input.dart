import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../../login/theme/login_theme.dart';
import '../theme/create_password_theme.dart';


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
          SvgPicture.asset(
            AssetConstant.lockPassSVG,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              AuthModuleColors.lockColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),

          // TextField (no extra padding)
          Expanded(
            child: TextField(
              obscureText: obscureText,
              onChanged: onChanged,
              style: CreatePasswordTheme.inputText,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: CreatePasswordTheme.inputHint,
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
