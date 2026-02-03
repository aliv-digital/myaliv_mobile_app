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

  static const double _horizontal = 25;
  static const double _topPadding = 24;

  // ✅ tweak this if needed (Figma bottom gap feel)
  static const double _designBottomGap = 24;

  @override
  Widget build(BuildContext context) {
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
                            onTap: () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 80,
                        left: MediaQuery.of(context).size.width / 2 - 96,
                        right: MediaQuery.of(context).size.width / 2 - 96,
                        child: SvgPicture.asset(
                          AssetConstant.splashLogoSVG,
                          width: 192,
                          height: 98,
                        ),
                      ),
                    ],
                  ),
                ),

                // -------- Bottom panel (flexible + consistent spacing) --------
                Expanded(
                  flex: 45,
                  child: Container(
                    width: double.infinity,
                    color: ColorManager.welcomeScreenBloc,
                    padding: EdgeInsets.fromLTRB(
                      _horizontal,
                      _topPadding,
                      _horizontal,
                      safeBottom + _designBottomGap,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Please Select Option',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.30,
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomButton(
                          label: 'Why ALIV ?',
                          onPressed: () => context.push(AppRoutes.whyAliv),
                        ),
                        const SizedBox(height: 18),

                        CustomButton(
                          label: 'top-up',
                          onPressed: () => context.push(AppRoutes.guestTopUp),
                        ),
                        const SizedBox(height: 18),

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
                        const SizedBox(height: 18),

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
