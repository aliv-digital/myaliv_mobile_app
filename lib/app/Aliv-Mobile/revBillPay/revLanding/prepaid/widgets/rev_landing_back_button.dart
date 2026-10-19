import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/theme/rev_landing_prepaid_theme.dart';

class RevLandingBackButton extends StatelessWidget {
  const RevLandingBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RevLandingPrepaidTheme.backButtonBg,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          if (context.canPop()) {
            context.pop();
          }
        },
        child: const SizedBox(
          width: RevLandingPrepaidTheme.backButtonSize,
          height: RevLandingPrepaidTheme.backButtonSize,
          child: Icon(
            Icons.chevron_left_rounded,
            color: RevLandingPrepaidTheme.backIconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
