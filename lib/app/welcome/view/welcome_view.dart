import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/welcome_bloc.dart';
import '../bloc/welcome_event.dart';
import '../bloc/welcome_state.dart';
import '../repository/welcome_repository.dart';
import '../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WelcomeBloc(WelcomeRepository())..add(WelcomeLoaded()),
      child: const WelcomeView(),
    );
  }
}

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  static const double _horizontal = 25;

  // ✅ Figma-like image crop/zoom
  static const double _imageZoom = 1.14;

  // ✅ Bottom panel sizing (device independent feel)
  // - ratio-based but clamped so it never becomes too tall/too short
  static const double _panelMinH = 290;
  static const double _panelMaxH = 330;
  static const double _panelRatio = 0.40;

  // ✅ Panel paddings (Figma-like)
  static const double _panelTopPadding = 22;
  static const double _panelBottomGap = 16;
  static final Uri _alivFbrPortalUri =
      Uri.parse('https://portal.alivfibr.com/myfibr/login.aspx');

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,

        // ✅ single color bottom area
        systemNavigationBarColor: ColorManager.welcomeScreenBloc,
        systemNavigationBarDividerColor: ColorManager.welcomeScreenBloc,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: ColorManager.welcomeScreenBloc,
      extendBody: true,
      body: BlocBuilder<WelcomeBloc, WelcomeState>(
        builder: (context, state) {
          if (state is WelcomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WelcomeLoadedState) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final w = constraints.maxWidth;

                final bottomH = (h * _panelRatio).clamp(_panelMinH, _panelMaxH);
                final topH = h - bottomH;

                return Column(
                  children: [
                    // -------- Top image area (fixed by calculation) --------
                    SizedBox(
                      height: topH,
                      width: w,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRect(
                              child: Transform.scale(
                                scale: _imageZoom,
                                // ✅ Slightly up for nicer crop like Figma
                                alignment: const Alignment(0, -0.05),
                                child: Image.asset(
                                  AssetConstant.welcomeImagePNG,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // ✅ Logo placement responsive (no magic bottom pixels)
                          Align(
                            alignment: const Alignment(0, 0.62),
                            child: SvgPicture.asset(
                              AssetConstant.splashLogoSVG,
                              width: 192,
                              height: 98,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // -------- Bottom purple panel (fixed by calculation) --------
                    SizedBox(
                      height: bottomH,
                      width: double.infinity,
                      child: Container(
                        color: ColorManager.welcomeScreenBloc,
                        padding: EdgeInsets.fromLTRB(
                          _horizontal,
                          _panelTopPadding,
                          _horizontal,
                          safeBottom + _panelBottomGap,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'welcome to ALIV',
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
                              label: 'ALIV Mobile',
                              onPressed: () async {
                                // Ask bloc to decide where to go based on cached ticket.
                                final route = await context
                                    .read<WelcomeBloc>()
                                    .resolveAlivMobileRoute();

                                if (!context.mounted) return;
                                context.go(route);
                              },
                            ),
                            const SizedBox(height: 18),
                            CustomButton(
                              label: 'ALIVfbr',
                              onPressed: () async {
                                final bool isLaunched = await launchUrl(
                                  _alivFbrPortalUri,
                                  mode: LaunchMode.externalApplication,
                                );

                                if (!isLaunched && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not open ALIVfbr portal.',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 18),
                            CustomButton(
                              label: 'ALIV Mobile Guest',
                              onPressed: () =>
                                  context.push(AppRoutes.guestSplash),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
