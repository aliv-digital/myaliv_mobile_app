import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../../../../router/app_routes.dart';
import '../theme/login_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final sideSlotWidth = AuthModuleSizes.backLeft + AuthModuleSizes.backIconWidth;

    return Padding(
      padding: EdgeInsets.only(top: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: sideSlotWidth,
            child: DefaultBackButton(
              padding: EdgeInsets.only(
                left: AuthModuleSizes.backLeft,
                // top: ,
              ),
              iconWidth: AuthModuleSizes.backIconWidth,
              iconHeight: AuthModuleSizes.backIconHeight,
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.splash); // or do nothing
                }              },
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 24),
              child: const _LogoTitle(),
            ),
          ),
          SizedBox(width: sideSlotWidth),
        ],
      ),
    );
  }
}

class _LogoTitle extends StatelessWidget {
  const _LogoTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AssetConstant.alivBlackLogoSVG,
          width: AuthModuleSizes.logoWidth,
          height: AuthModuleSizes.logoHeight,
        ),
        const SizedBox(height: AuthModuleSizes.logoToTitleGap),
        const Text(
          'welcome back',
          style: AuthModuleTextStyles.welcomeBack,
        ),
      ],
    );
  }
}
