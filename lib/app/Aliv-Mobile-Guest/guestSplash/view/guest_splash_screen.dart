import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../welcome/widgets/custom_button.dart';
import '../bloc/guest_splash_bloc.dart';
import '../bloc/guest_splash_event.dart';
import '../bloc/guest_splash_state.dart';
import '../repository/guest_splash_repository.dart';
import '../theme/guest_splash_theme.dart';
import '../widgets/guest_purchase_plan_bottom_sheet.dart';

class GuestSplashScreen extends StatelessWidget {
  const GuestSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      GuestSplashBloc(GuestSplashRepository())..add(GuestSplashLoaded()),
      child: const GuestSplashView(),
    );
  }
}

class GuestSplashView extends StatelessWidget {
  const GuestSplashView({super.key});

  // Design reference: tuned on A52 logical height (~915)
  static const double _designBaseHeight = 915;
  static const double _horizontalBase = 25;
  static const double _titleOffsetFromPurpleTopBase = 44;
  static const double _designBottomGapBase = 24;
  static const double _imageBottomMaskHeightBase = 24;
  static const double _logoWidthBase = 192;
  static const double _logoHeightBase = 98;
  static const double _logoBottomOffsetBase = 80;
  static const double _backButtonSizeBase = 36;
  static const double _backIconSizeBase = 26;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.height / _designBaseHeight).clamp(0.85, 1.2);
    final horizontal = _horizontalBase * scale;
    final titleOffsetFromPurpleTop = _titleOffsetFromPurpleTopBase * scale;
    final designBottomGap = _designBottomGapBase * scale;
    final imageBottomMaskHeight = _imageBottomMaskHeightBase * scale;
    final titleTopPadding = (titleOffsetFromPurpleTop - imageBottomMaskHeight).clamp(0.0, double.infinity);
    final logoWidth = _logoWidthBase * scale;
    final logoHeight = _logoHeightBase * scale;
    final logoBottomOffset = _logoBottomOffsetBase * scale;
    final backButtonSize = _backButtonSizeBase * scale;
    final backIconSize = _backIconSizeBase * scale;

    // ✅ ensure status + navigation areas match the screen color (single color look)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,

        // ✅ bottom nav / gesture area same color
        systemNavigationBarColor: ColorManager.welcomeScreenBloc,
        systemNavigationBarDividerColor: ColorManager.welcomeScreenBloc,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: ColorManager.welcomeScreenBloc,

      // ✅ draw body behind nav bar so it blends perfectly
      extendBody: true,

      body: BlocBuilder<GuestSplashBloc, GuestSplashState>(
        builder: (context, state) {
          if (state is GuestSplashInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GuestSplashLoadedState) {
            return Column(
              children: [
                // -------- Top image area (flexible) --------
                Expanded(
                  flex: 55,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          AssetConstant.guestImagePNG,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: SafeArea(
                          bottom: false,
                          child: InkWell(
                            onTap: () {
                              context.pop();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: backButtonSize,
                              height: backButtonSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                                size: backIconSize,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: logoBottomOffset,
                        left: size.width / 2 - (logoWidth / 2),
                        right: size.width / 2 - (logoWidth / 2),
                        child: SvgPicture.asset(
                          AssetConstant.splashLogoSVG,
                          width: logoWidth,
                          height: logoHeight,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: imageBottomMaskHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                ColorManager.welcomeScreenBloc.withValues(alpha: 0.0),
                                ColorManager.welcomeScreenBloc,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // -------- Bottom panel (flexible + consistent spacing) --------
                Expanded(
                  flex: 44,
                  child: Container(
                    width: double.infinity,
                    color: ColorManager.welcomeScreenBloc,
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      titleTopPadding,
                      horizontal,
                      safeBottom + designBottomGap,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Please Select Option',
                          style: GuestSplashTheme.title,
                        ),
                        const SizedBox(height: 20),

                        CustomButton(
                          label: 'Why ALIV ?',
                          onPressed: () => context.push(AppRoutes.whyAliv),
                        ),
                        const SizedBox(height: 20),

                        CustomButton(
                          label: 'top-up',
                          onPressed: () => context.push(AppRoutes.guestTopUp),
                        ),
                        const SizedBox(height: 20),

                        CustomButton(
                          label: 'purchase a plan',
                          onPressed: () async {
                            final result =
                            await showGuestSplashPurchasePlanBottomSheet(
                                context);

                            if (!context.mounted) return;

                            if (result != null) {
                              debugPrint('PurchasePlan -> ${result.fullPhone}');
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        CustomButton(
                          label: 'bill pay',
                          onPressed: () => context.push(AppRoutes.guestPayBill),
                        ),

                        // ✅ fills remaining space so layout looks consistent on all devices
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
