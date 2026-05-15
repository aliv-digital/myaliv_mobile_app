import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/theme/rev_landing_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/widgets/rev_landing_back_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/widgets/rev_landing_bottom_decoration.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/widgets/rev_landing_choice_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/widgets/rev_landing_hero_image.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class RevLandingPrepaidScreen extends StatelessWidget {
  const RevLandingPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RevLandingPrepaidTheme.background,
      body: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: const RevLandingBottomDecoration(),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const RevLandingHeroImage(),
                          const SizedBox(
                            height: RevLandingPrepaidTheme.heroToQuestionGap,
                          ),
                          Text(
                            'How would you like to pay?',
                            textAlign: TextAlign.center,
                            style: RevLandingPrepaidTheme.question,
                          ),
                          const SizedBox(
                            height: RevLandingPrepaidTheme
                                .questionToFirstButtonGap,
                          ),
                          Center(
                            child: RevLandingChoiceButton(
                              label: 'Pay as a Guest',
                              onPressed: () =>
                                  context.push(AppRoutes.guestPayBill),
                            ),
                          ),
                          const SizedBox(
                            height: RevLandingPrepaidTheme.betweenButtonsGap,
                          ),
                          Center(
                            child: RevLandingChoiceButton(
                              label: 'Log in to Pay',
                              onPressed: () => context.push(AppRoutes.logIn),
                            ),
                          ),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: RevLandingPrepaidTheme.backButtonTop,
            left: RevLandingPrepaidTheme.backButtonLeft,
            child: SafeArea(child: const RevLandingBackButton()),
          ),
        ],
      ),
    );
  }
}
