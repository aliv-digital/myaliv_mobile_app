import 'package:flutter/material.dart';
import '../theme/guest_topup_theme.dart';

class FocusedInputBorderWrapper extends StatelessWidget {
  const FocusedInputBorderWrapper({
    super.key,
    required this.child,
    required this.isFocused,
    required this.unfocusedBorderColor,
    this.radius = GuestTopUpTheme.phoneFieldRadius,
    this.borderWidth = GuestTopUpTheme.phoneFieldBorderWidth,
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
        gradient: isFocused ? GuestTopUpTheme.focusedInputBorderGradient : null,
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
