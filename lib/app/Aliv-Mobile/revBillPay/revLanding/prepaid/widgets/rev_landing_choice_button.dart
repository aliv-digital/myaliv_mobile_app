import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/theme/rev_landing_prepaid_theme.dart';

class RevLandingChoiceButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const RevLandingChoiceButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final targetWidth = (screenWidth * RevLandingPrepaidTheme.buttonWidthFactor)
        .clamp(
          RevLandingPrepaidTheme.buttonMinWidth,
          RevLandingPrepaidTheme.buttonMaxWidth,
        );

    return SizedBox(
      width: targetWidth,
      height: RevLandingPrepaidTheme.buttonHeight,
      child: Material(
        color: RevLandingPrepaidTheme.buttonBg,
        borderRadius: BorderRadius.circular(
          RevLandingPrepaidTheme.buttonRadius,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            RevLandingPrepaidTheme.buttonRadius,
          ),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: RevLandingPrepaidTheme.buttonLabel,
            ),
          ),
        ),
      ),
    );
  }
}
