import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/theme/rev_landing_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/widgets/rev_landing_back_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/widgets/rev_landing_bottom_decoration.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/widgets/rev_landing_choice_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revLanding/prepaid/widgets/rev_landing_hero_image.dart';
import 'package:url_launcher/url_launcher.dart';

class RevLandingPrepaidScreen extends StatelessWidget {
  const RevLandingPrepaidScreen({super.key});

  static const _payAsGuestUrl = 'https://my.rev.bs/guest/payment';
  static const _loginToPayUrl = 'https://my.rev.bs/';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: RevLandingPrepaidTheme.background,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: const RevLandingBottomDecoration(),
            ),
            LayoutBuilder(
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
                              onPressed: () => _openUrl(_payAsGuestUrl),
                            ),
                          ),
                          const SizedBox(
                            height: RevLandingPrepaidTheme.betweenButtonsGap,
                          ),
                          Center(
                            child: RevLandingChoiceButton(
                              label: 'Log in to Pay',
                              onPressed: () => _openUrl(_loginToPayUrl),
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
            Positioned(
              top: RevLandingPrepaidTheme.backButtonTop,
              left: RevLandingPrepaidTheme.backButtonLeft,
              child: SafeArea(child: const RevLandingBackButton()),
            ),
          ],
        ),
      ),
    );
  }
}
