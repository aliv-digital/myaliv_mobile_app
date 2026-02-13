import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillFocusedInputBorderWrapper extends StatelessWidget {
  const GuestPayBillFocusedInputBorderWrapper({
    super.key,
    required this.child,
    required this.isFocused,
    required this.unfocusedBorderColor,
    this.radius = GuestPayBillTheme.radius,
    this.borderWidth = GuestPayBillTheme.inputFocusBorderWidth,
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
        gradient:
            isFocused ? GuestPayBillTheme.focusedInputBorderGradient : null,
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
        borderRadius: BorderRadius.circular(
          (radius - borderWidth).clamp(0.0, radius),
        ),
        child: child,
      ),
    );
  }
}
