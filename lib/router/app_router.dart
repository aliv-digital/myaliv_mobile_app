import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/splash/view/splash_page.dart';
import 'app_routes.dart';


class AppRouter {


  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,   // initial Screen
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),




    ],
  );
}
