import 'package:flutter/material.dart';
import '../theme/forget_password_theme.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Icon prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final Function()? onTap;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.onTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ForgetPasswordSizes.fieldRadius),
          border: Border.fromBorderSide(ForgetPasswordDecorations.genericInputBorder),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: ForgetPasswordPaddings.genericInputContent,
          ),
        ),
      ),
    );
  }
}
