import 'package:flutter/material.dart';
import '../theme/forget_password_theme.dart';

class ForgetPasswordFocusedInputBorderWrapper extends StatelessWidget {
  const ForgetPasswordFocusedInputBorderWrapper({
    super.key,
    required this.child,
    required this.isFocused,
    required this.unfocusedBorderColor,
    this.radius = ForgetPasswordSizes.fieldRadius,
    this.borderWidth = ForgetPasswordSizes.fieldBorderWidth,
  });

  final Widget child;
  final bool isFocused;
  final Color unfocusedBorderColor;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isFocused ? ForgetPasswordGradients.focusedInputBorder : null,
        border: isFocused
            ? null
            : Border.all(
                color: unfocusedBorderColor,
                width: borderWidth,
              ),
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular((radius - borderWidth).clamp(0.0, radius)),
        child: child,
      ),
    );
  }
}
