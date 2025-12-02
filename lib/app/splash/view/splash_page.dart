import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../resources/color_manager.dart';
import '../../../resources/constants/asset_constants.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,  // Background transparent
        statusBarIconBrightness: Brightness.light, // ANDROID → white icons
        statusBarBrightness: Brightness.dark,       // iOS → white icons
      ),
    );
    return BlocProvider(
      create: (_) => SplashBloc()..add(SplashStarted()),
      child: Scaffold(
        body: BlocListener<SplashBloc, SplashState>(
          listener: (context, state) {
            // Navigation logic here
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  //ColorManager.splashScreenTop,
                  //ColorManager.splashScreenMiddle,
                  //ColorManager.splashScreenBottom
                  ColorManager.splashVar1,
                  ColorManager.splashVar2,
                  ColorManager.splashVar3
                  // Middle blend
                  // Bottom purple
                ],
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                AssetConstant.splashLogoSVG,
                height: 98,
                width: 192,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
