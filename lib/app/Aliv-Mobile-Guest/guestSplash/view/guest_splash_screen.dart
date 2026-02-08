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

  // Fixed design tokens from Figma.
  static const double _heroHeight = 460;
  static const double _heroBottomPurpleMaskHeight = 36;
  static const double _horizontalPadding = 25;
  static const double _titleTopPadding = 6;
  static const double _bottomTailSpace = 103;
  static const double _titleToFirstButtonGap = 27;
  static const double _buttonVerticalGap = 20;
  static const double _logoTopOffset = _heroHeight - _logoHeight - 80;
  static const double _logoWidth = 193;
  static const double _logoHeight = 99;
  static const double _backButtonSize = 36;
  static const double _backIconSize = 26;
  static const double _backButtonTopOffset = 12;
  static const double _backButtonLeftOffset = 12;

  @override
  Widget build(BuildContext context) {
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
            return LayoutBuilder(
              builder: (context, constraints) {
                final minPurpleHeight =
                    (constraints.maxHeight - _heroHeight).clamp(
                  0.0,
                  double.infinity,
                );

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        SizedBox(
                          height: _heroHeight,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  AssetConstant.guestImagePNG,
                                  fit: BoxFit.cover,
                                  alignment: const Alignment(0, -0.9),
                                ),
                              ),
                              Positioned(
                                top: _backButtonTopOffset,
                                left: _backButtonLeftOffset,
                                child: SafeArea(
                                  bottom: false,
                                  child: InkWell(
                                    onTap: () {
                                      context.pop();
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: _backButtonSize,
                                      height: _backButtonSize,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.chevron_left,
                                        color: Colors.black,
                                        size: _backIconSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: _logoTopOffset,
                                left:
                                    constraints.maxWidth / 2 - (_logoWidth / 2),
                                right:
                                    constraints.maxWidth / 2 - (_logoWidth / 2),
                                child: SvgPicture.asset(
                                  AssetConstant.splashLogoSVG,
                                  width: _logoWidth,
                                  height: _logoHeight,
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: -6,
                                child: Container(
                                  height: _heroBottomPurpleMaskHeight,
                                  color: GuestSplashTheme.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          constraints:
                              BoxConstraints(minHeight: minPurpleHeight),
                          color: GuestSplashTheme.purple,
                          padding: EdgeInsets.fromLTRB(
                            _horizontalPadding,
                            _titleTopPadding,
                            _horizontalPadding,
                            safeBottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Please Select Option',
                                style: GuestSplashTheme.title,
                              ),
                              const SizedBox(height: _titleToFirstButtonGap),
                              GuestSplashButton(
                                label: 'why ALIV ?',
                                onPressed: () =>
                                    context.push(AppRoutes.whyAliv),
                              ),
                              const SizedBox(height: _buttonVerticalGap),
                              GuestSplashButton(
                                label: 'top-up',
                                onPressed: () =>
                                    context.push(AppRoutes.guestTopUp),
                              ),
                              const SizedBox(height: _buttonVerticalGap),
                              GuestSplashButton(
                                label: 'purchase a plan',
                                onPressed: () async {
                                  final result =
                                      await showGuestSplashPurchasePlanBottomSheet(
                                    context,
                                  );
                                  if (!context.mounted) return;
                                  if (result != null) {
                                    debugPrint(
                                        'PurchasePlan -> ${result.fullPhone}');
                                  }
                                },
                              ),
                              const SizedBox(height: _buttonVerticalGap),
                              GuestSplashButton(
                                label: 'bill pay',
                                onPressed: () =>
                                    context.push(AppRoutes.guestPayBill),
                              ),
                              const SizedBox(height: _bottomTailSpace),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
