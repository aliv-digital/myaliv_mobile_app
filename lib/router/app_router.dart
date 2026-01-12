import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/view/guest_pay_bill_confirm_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/view/guest_splash_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/view/guest_top_up_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/view/why_aliv_screen.dart';
import 'package:myaliv_mobile_app/app/welcome/view/welcome_view.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/view/guest_pay_bill_receipt_screen.dart';
import '../app/Aliv-Mobile-Guest/confirmGuestTopUp/view/confirm_guest_top_up_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlan/view/guest_purchase_plan_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanAddons/view/guest_purchase_plan_add_ons_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/view/guest_purchase_plan_confirmation_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/view/guest_purchase_plan_receipt_screen.dart';
import '../app/Aliv-Mobile-Guest/guestTopUp/view/guest_topup_screen.dart';
import '../app/Aliv-Mobile/createPassword/view/create_password_page.dart';
import '../app/Aliv-Mobile/forgetPassOtp/view/forgetPass_screen.dart';
import '../app/Aliv-Mobile/forgetPassword/view/forget_password_screen.dart';
import '../app/Aliv-Mobile/login/view/login_page.dart';
import '../app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import '../app/Aliv-Mobile/userProfile/myProfile/prepaid/view/my_profile_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/profile/postpaid/view/profile_postpaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/profile/prepaid/view/profile_prepaid_screen.dart';
import '../app/splash/view/splash_page.dart';
import 'app_routes.dart';


class AppRouter {

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.myProfilePrepaidScreen,//guestPayBillConfirm,//guestPurchasePlan,
    routes: [

      GoRoute(
          path: AppRoutes.myProfilePrepaidScreen,
          builder: (context,state) => const MyProfilePrepaidScreen()
      ),
      GoRoute(
        path: AppRoutes.profilePostpaidScreen,
        builder: (context, state) => const ProfilePostpaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.profilePrepaidScreen,
        builder: (context, state) => const ProfilePrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.guestPurchasePlanReceipt,
        builder: (context, state) => const GuestPurchasePlanReceiptScreen(
          phoneNumber: '242-801-1616',
          amount: 75,
          dateText: 'Mar 12,2023',
          timeText: '446332'
        )
      ),
      GoRoute(
        path: AppRoutes.guestPurchasePlanConfirmation,
        builder: (context, state) => const GuestPurchasePlanConfirmationScreen(phoneNumber: '23434545',)
      ),
      GoRoute(
          path: AppRoutes.guestPurchasePlanAddOns,
          builder: (context,state) => const GuestPurchasePlanAddOnsScreen()
      ),
      GoRoute(
        path: AppRoutes.guestPayBillReceipt,
        builder: (context, state) => const GuestPayBillReceiptScreen(
            phoneNumber: '234235454',
            amount:12,
            dateText: '12-23-2025',
            timeText: '08:34'
        ),
      ),
      GoRoute(
        path: AppRoutes.guestPayBillConfirm,
        builder: (context, state) => const GuestPayBillConfirmScreen(
            args: GuestPayBillConfirmArgs(
              serviceName: 'ALIV Postpaid',
              identifierLabel: 'mobile no.',
              identifierValue: '242-801-0000',
              amount: 200.00,
            )
        ),
      ),
      GoRoute(
        path: AppRoutes.guestPayBill,
        builder: (context, state) => const GuestPayBillScreen(),
      ),
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
