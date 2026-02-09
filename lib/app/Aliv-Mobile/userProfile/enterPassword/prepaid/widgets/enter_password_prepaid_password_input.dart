import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/enter_password_prepaid_theme.dart';

class EnterPasswordPrepaidPasswordInput extends StatelessWidget {
  final String value;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;

  const EnterPasswordPrepaidPasswordInput({
    super.key,
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
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: EnterPasswordPrepaidTheme.inputBorder),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 20, color: Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              obscureText: obscure,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Password',
                hintStyle: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  color: Color(0xFF707070),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.43,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 11),
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(999),
            child: SvgPicture.asset(
              obscure ? AssetConstant.hideIconSVG : AssetConstant.viewIconSVG,
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }
}
