import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/view/guest_splash_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/view/guest_top_up_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/view/why_aliv_screen.dart';
import 'package:myaliv_mobile_app/app/welcome/view/welcome_view.dart';
import '../app/Aliv-Mobile-Guest/confirmGuestTopUp/view/confirm_guest_top_up_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlan/view/guest_purchase_plan_screen.dart';
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
    initialLocation: AppRoutes.guestPurchasePlan,   // initial Screen
    routes: [
      GoRoute(
        path: AppRoutes.guestPurchasePlan,
        builder: (context, state) => const GuestPurchasePlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.guestTopUpReceipt,
        builder: (context, state) => const GuestTopUpReceiptScreen(
            phoneNumber: '234235454',
            amount:12,
            dateText: '12-23-2025',
            timeText: '08:34'
        ),
      ),
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
      ),
      GoRoute(
          path: AppRoutes.confirmGuestTopUp,
          builder: (context,state) => GuestConfirmTopUpScreen(phoneNumber: '245346-452356', amount: 12)
      )
    ],
  );
}
