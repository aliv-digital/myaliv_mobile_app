import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/guest_splash_bloc.dart';
import '../bloc/guest_splash_event.dart';
import '../bloc/guest_splash_state.dart';
import '../repository/guest_splash_repository.dart';
import '../theme/guest_splash_theme.dart';
import '../widgets/guest_splash_button.dart';
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
  static const double _titleOffsetFromPurpleTop = 44;
  static const double _designBottomGapBase = 24;
  static const double _imageBottomMaskHeightBase = 24;
  static const int _topSectionFlex = 60;
  static const int _bottomSectionFlex = 40;
  static const double _logoWidthBase = 192;
  static const double _logoHeightBase = 98;
  static const double _logoBottomOffsetBase = 92;
  static const double _backButtonSizeBase = 36;
  static const double _backIconSizeBase = 26;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.height / _designBaseHeight).clamp(0.85, 1.2);
    final horizontal = _horizontalBase * scale;
    final designBottomGap = _designBottomGapBase * scale;
    final imageBottomMaskHeight = _imageBottomMaskHeightBase * scale;
    // Keep title exactly 44px from the first visible purple start.
    // The top image already draws 24px purple mask, so subtract that here.
    const titleTopPadding =
        _titleOffsetFromPurpleTop - _imageBottomMaskHeightBase;
    final logoWidth = _logoWidthBase * scale;
    final logoHeight = _logoHeightBase * scale;
    // Keep logo exactly 40px above the purple boundary line.
    const logoBottomOffset = _logoBottomOffsetBase;
    final backButtonSize = _backButtonSizeBase * scale;
    final backIconSize = _backIconSizeBase * scale;

    //  ensure status + navigation areas match the screen color (single color look)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,

        //  bottom nav / gesture area same color
        systemNavigationBarColor: GuestSplashTheme.purple,
        systemNavigationBarDividerColor: GuestSplashTheme.purple,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: GuestSplashTheme.purple,

      //  draw body behind nav bar so it blends perfectly
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
                  flex: _topSectionFlex,
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
                                GuestSplashTheme.purple.withValues(alpha: 0.0),
                                GuestSplashTheme.purple,
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
                  flex: _bottomSectionFlex,
                  child: Container(
                    width: double.infinity,
                    color: GuestSplashTheme.purple,
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      titleTopPadding,
                      horizontal,
                      safeBottom + designBottomGap,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Please Select Option',
                          style: GuestSplashTheme.title,
                        ),
                        const SizedBox(height: 27),

                        GuestSplashButton(
                          label: 'why ALIV ?',
                          onPressed: () => context.push(AppRoutes.whyAliv),
                        ),
                        const SizedBox(height: 20),

                        GuestSplashButton(
                          label: 'top-up',
                          onPressed: () => context.push(AppRoutes.guestTopUp),
                        ),
                        const SizedBox(height: 20),

                        GuestSplashButton(
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

                        GuestSplashButton(
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
