import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/theme/rev_landing_prepaid_theme.dart';

class RevLandingBottomDecoration extends StatelessWidget {
  const RevLandingBottomDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = (screenWidth *
            RevLandingPrepaidTheme.bottomDecorationWidthFactor)
        .clamp(0.0, RevLandingPrepaidTheme.bottomDecorationMaxWidth);

    return IgnorePointer(
      child: Image.asset(
        'assets/images/rev_bottom_right.png',
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
