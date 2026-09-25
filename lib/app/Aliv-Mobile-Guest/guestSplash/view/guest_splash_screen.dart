import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
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

  // The Figma screen is 390 px wide and uses equally sized hero and option
  // sections. Scaling from the screen width keeps that balance across phones.
  static const double _designWidth = 390;
  static const double _designSectionHeight = 421;
  static const double _contentHorizontalPadding = 16;
  static const double _titleTopPadding = 30;
  static const double _bottomTailSpace = 103;
  static const double _titleToFirstButtonGap = 27;
  static const double _buttonVerticalGap = 20;
  static const double _optionButtonWidth = 200;
  static const double _logoWidth = 193;
  static const double _logoHeight = 99;
  static const double _logoBottomOffset = 38;
  static const double _backButtonSize = 36;
  static const double _backIconSize = 26;
  static const double _backButtonTopOffset = 12;
  static const double _backButtonLeftOffset = 12;

  @override
  Widget build(BuildContext context) {
    //  ensure status + navigation areas match the screen color (single color look)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        /*
           statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
         */
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,

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
          final imageUrl = state is GuestSplashLoadedState
              ? state.mobileImageUrl
              : null;

          return LayoutBuilder(
            builder: (context, constraints) {
              final designScale = constraints.maxWidth / _designWidth;
              final heroHeight = _designSectionHeight * designScale;
              final designOptionsHeight = _designSectionHeight * designScale;
              final remainingHeight = (constraints.maxHeight - heroHeight)
                  .clamp(0.0, double.infinity);
              final optionsMinHeight = remainingHeight > designOptionsHeight
                  ? remainingHeight
                  : designOptionsHeight;
              final buttonWidth = (_optionButtonWidth * designScale).clamp(
                180.0,
                240.0,
              );
              final logoWidth = (_logoWidth * designScale).clamp(165.0, 220.0);
              final logoHeight = logoWidth * (_logoHeight / _logoWidth);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      SizedBox(
                        height: heroHeight,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _GuestHeroImage(imageUrl: imageUrl),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.chevron_left,
                                      color: HexColor.fromHex('#645D9C'),
                                      size: _backIconSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: _logoBottomOffset * designScale,
                              child: Center(
                                child: SvgPicture.asset(
                                  AssetConstant.splashLogoSVG,
                                  width: logoWidth,
                                  height: logoHeight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: optionsMinHeight,
                        ),
                        color: GuestSplashTheme.purple,
                        padding: EdgeInsets.fromLTRB(
                          _contentHorizontalPadding,
                          _titleTopPadding * designScale,
                          _contentHorizontalPadding,
                          safeBottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Please Select Option',
                              style: GuestSplashTheme.title,
                            ),
                            SizedBox(
                              height: _titleToFirstButtonGap * designScale,
                            ),
                            GuestSplashButton(
                              width: buttonWidth,
                              label: 'why ALIV ?',
                              onPressed: () => context.push(AppRoutes.whyAliv),
                            ),
                            SizedBox(height: _buttonVerticalGap * designScale),
                            GuestSplashButton(
                              width: buttonWidth,
                              label: 'top-up',
                              onPressed: () =>
                                  context.push(AppRoutes.guestTopUp),
                            ),
                            SizedBox(height: _buttonVerticalGap * designScale),
                            GuestSplashButton(
                              width: buttonWidth,
                              label: 'purchase a plan',
                              onPressed: () async {
                                final result =
                                    await showGuestSplashPurchasePlanBottomSheet(
                                      context,
                                    );
                                if (!context.mounted) return;
                                if (result != null) {
                                  debugPrint(
                                    'PurchasePlan -> ${result.fullPhone}',
                                  );
                                }
                              },
                            ),
                            SizedBox(height: _buttonVerticalGap * designScale),
                            GuestSplashButton(
                              width: buttonWidth,
                              label: 'bill pay',
                              onPressed: () =>
                                  context.push(AppRoutes.guestPayBill),
                            ),
                            SizedBox(height: _bottomTailSpace * designScale),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GuestHeroImage extends StatelessWidget {
  const _GuestHeroImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = imageUrl?.trim() ?? '';
    if (resolvedImageUrl.isEmpty) {
      return _fallbackImage();
    }

    return CachedNetworkImage(
      imageUrl: resolvedImageUrl,
      // Cover keeps the image natural. The slight upward alignment retains
      // the face and shows more of the body than a top-aligned crop.
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.25),
      placeholder: (context, url) => _fallbackImage(),
      errorWidget: (context, url, error) {
        debugPrint('GuestHeroImage load failed: $url -> $error');
        return _fallbackImage();
      },
    );
  }

  Widget _fallbackImage() {
    // Keep the hero area stable while the API image is loading. The previous
    // local fallback path does not exist in the bundled assets.
    return ColoredBox(color: GuestSplashTheme.purple);
  }
}
