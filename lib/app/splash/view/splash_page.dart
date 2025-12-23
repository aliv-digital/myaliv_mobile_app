import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
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
            if(state is SplashLoaded){
              context.go(AppRoutes.welcome);
            }
            // Navigation logic here
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.08, 0), // start point : বাম-উপর
                end: Alignment(0.82, 1),   // end point : ডান-নিচে
                colors: [
                  ColorManager.splashVar1,//Color.fromRGBO(102, 89, 151, 1), // first color : rgb(102, 89, 151)
                  ColorManager.splashVar2//Color.fromRGBO(74, 56, 107, 1),  // second color : rgb(74, 56, 107)
                ],
                stops: [
                  0.0, // first color stop point
                  1.0, // second color stop point
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
