import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/view/guest_splash_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/view/why_aliv_screen.dart';
import 'package:myaliv_mobile_app/app/welcome/view/welcome_view.dart';
import '../app/Aliv-Mobile-Guest/guestTopUp/view/guest_topup_screen.dart';
import '../app/Aliv-Mobile/createPassword/view/create_password_page.dart';
import '../app/Aliv-Mobile/forgetPassOtp/view/forgetPass_screen.dart';
import '../app/Aliv-Mobile/forgetPassword/view/forget_password_screen.dart';
import '../app/Aliv-Mobile/login/view/login_page.dart';
import '../app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import '../app/splash/view/splash_page.dart';
import 'app_routes.dart';


class AppRouter {

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.guestTopUp,   // initial Screen
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
      ),
      GoRoute(
          path: AppRoutes.forgetPassword,
          builder: (context,state) => const ForgetPasswordScreen()
      ),
      GoRoute(
        path: AppRoutes.forgetPasswordOtp,
        builder: (context, state) => const ForgetPasswordOtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.createPassword,
        builder: (context, state) => const CreatePasswordScreen(),
      ),
      GoRoute(
          path: AppRoutes.guestSplash,
          builder: (context,state) => const GuestSplashScreen()
      ),
      GoRoute(
          path: AppRoutes.whyAliv,
          builder: (context,state) => const WhyAlivScreen()
      ),
      GoRoute(
        path: AppRoutes.guestTopUp,
        builder: (context, state) => const GuestTopUpScreen(),
      )
    ],
  );
}
