import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/login/view/login_page.dart';
import 'package:myaliv_mobile_app/app/loginOtp/view/login_otp_screen.dart';
import 'package:myaliv_mobile_app/app/splash/bloc/splash_state.dart';
import 'package:myaliv_mobile_app/app/welcome/view/welcome_view.dart';
import '../app/splash/view/splash_page.dart';
import 'app_routes.dart';


class AppRouter {


  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.logIn,   // initial Screen
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.logIn,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
          path: AppRoutes.welcome,
          builder: (context,state) => const WelcomeScreen()
      ),
      GoRoute(
        path: AppRoutes.loginOtp,
        builder: (context,state) => const LoginOtpScreen()
      )

    ],
  );
}
