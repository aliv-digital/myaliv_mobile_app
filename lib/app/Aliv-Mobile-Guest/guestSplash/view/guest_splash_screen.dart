import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../../../welcome/widgets/custom_button.dart';
import '../bloc/guest_splash_bloc.dart';
import '../bloc/guest_splash_event.dart';
import '../bloc/guest_splash_state.dart';
import '../repository/guest_splash_repository.dart';

class GuestSplashScreen extends StatelessWidget {
  const GuestSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return BlocProvider(
      create: (context) =>
      GuestSplashBloc(GuestSplashRepository())..add(GuestSplashLoaded()),
      child: const GuestSplashView(),
    );
  }
}

class GuestSplashView extends StatelessWidget {
  const GuestSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GuestSplashBloc, GuestSplashState>(
        builder: (context, state) {
          if (state is GuestSplashInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GuestSplashLoadedState) {
            return Column(
              children: [
                // Top Half - Background Image with ALIV Logo (stacked section)
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          AssetConstant.guestImagePNG,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // ✅ Back Button (top-left) - same position like screenshot
                      Positioned(
                        top: 12,
                        left: 12,
                        child: SafeArea(
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

                // Bottom Half - Purple Color Block with Buttons
                Expanded(
                  flex: 0,
                  child: Container(
                    height: 350,
                    width: double.infinity,
                    color: ColorManager.welcomeScreenBloc,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
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
                          onPressed: () {},
                        ),
                        const SizedBox(height: 18),
                        CustomButton(
                          label: 'top-up',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 18),
                        CustomButton(
                          label: 'purchase a plan',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 18),
                        CustomButton(
                          label: 'bill pay',
                          onPressed: () {},
                        ),
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
