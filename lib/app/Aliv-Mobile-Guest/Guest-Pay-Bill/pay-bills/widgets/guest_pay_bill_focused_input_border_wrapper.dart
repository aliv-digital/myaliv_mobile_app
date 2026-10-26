import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillFocusedInputBorderWrapper extends StatelessWidget {
  const GuestPayBillFocusedInputBorderWrapper({
    super.key,
    required this.child,
    required this.isFocused,
    this.isError = false,
    this.radius = GuestPayBillTheme.radius,
    this.borderWidth = GuestPayBillTheme.inputFocusBorderWidth,
  });

  final Widget child;
  final bool isFocused;
  final bool isError;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    // Focus wins over error so the user sees normal interaction feedback while
    // typing. An unfocused field with an invalid value gets the solid red
    // border called out in the pay-bills design.
    final bool showErrorBorder = isError && !isFocused;
    return Container(
      decoration: BoxDecoration(
        gradient: isFocused
            ? GuestPayBillTheme.focusedInputBorderGradient
            : null,
        color: showErrorBorder ? GuestPayBillTheme.errorText : null,
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
