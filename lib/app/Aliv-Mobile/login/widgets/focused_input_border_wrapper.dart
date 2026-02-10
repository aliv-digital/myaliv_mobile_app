import 'package:flutter/material.dart';
import '../theme/login_theme.dart';

class FocusedInputBorderWrapper extends StatelessWidget {
  const FocusedInputBorderWrapper({
    super.key,
    required this.child,
    required this.isFocused,
    required this.unfocusedBorderColor,
    this.radius = AuthModuleSizes.fieldRadius,
    this.borderWidth = AuthModuleSizes.fieldBorderWidth,
  });

  final Widget child;
  final bool isFocused;
  final Color unfocusedBorderColor;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    // Keep a stable wrapper structure; only border paint changes with focus.
    return Container(
      decoration: BoxDecoration(
        gradient: isFocused ? AuthModuleGradients.focusedInputBorder : null,
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
        borderRadius: BorderRadius.circular((radius - borderWidth).clamp(0.0, radius)),
        child: child,
      ),
    );
  }
}
