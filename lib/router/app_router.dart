import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/view/guest_pay_bill_confirm_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/view/guest_splash_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/view/guest_top_up_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/view/why_aliv_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revBill/prepaid/view/rev_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/Otp/postpaid/view/otp_postpaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/addOrEditCards/prepaid/view/add_or_edit_cards_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/view/change_password_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/editEmail/prepaid/view/edit_email_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/enterPassword/prepaid/view/enter_password_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/welcome/view/welcome_view.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/view/guest_pay_bill_receipt_screen.dart';
import '../app/Aliv-Mobile-Guest/confirmGuestTopUp/view/confirm_guest_top_up_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlan/view/guest_purchase_plan_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanAddons/view/guest_purchase_plan_add_ons_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/view/guest_purchase_plan_confirmation_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/view/guest_purchase_plan_receipt_screen.dart';
import '../app/Aliv-Mobile-Guest/guestTopUp/view/guest_topup_screen.dart';
import '../app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/view/auto_renew_auth_prepaid_screen.dart';
import '../app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/view/auto_renew_prepaid_screen.dart';
import '../app/Aliv-Mobile/autoRenew/enterPassword/prepaid/view/enter_password_autoRenew_prepaid_screen.dart';
import '../app/Aliv-Mobile/autoRenew/otp/prepaid/view/otp_prepaid_screen.dart';
import '../app/Aliv-Mobile/createPassword/view/create_password_page.dart';
import '../app/Aliv-Mobile/forgetPassOtp/view/forgetPass_screen.dart';
import '../app/Aliv-Mobile/forgetPassword/view/forget_password_screen.dart';
import '../app/Aliv-Mobile/login/view/login_page.dart';
import '../app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import '../app/Aliv-Mobile/referAFriend/referFriend/prepaid/view/refer_friend_prepaid_screen.dart';
import '../app/Aliv-Mobile/referAFriend/referFriendResponse/prepaid/view/refer_friend_response_prepaid_screen.dart';
import '../app/Aliv-Mobile/revBillPay/revConfirmation/prepaid/view/rev_confirmation_prepaid_screen.dart';
import '../app/Aliv-Mobile/reviewInvoices/enterPassword/postpaid/view/enter_password_postpaid_screen.dart';
import '../app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/view/review_invoice_postpaid_screen.dart';
import '../app/Aliv-Mobile/settings/faceIdSecurity/view/face_id_security_screen.dart';
import '../app/Aliv-Mobile/settings/fingerPrintSecurity/view/fingerprint_security_screen.dart';
import '../app/Aliv-Mobile/settings/help/view/help_screen.dart';
import '../app/Aliv-Mobile/settings/privacy/view/privacy_screen.dart';
import '../app/Aliv-Mobile/settings/security/view/security_screen.dart';
import '../app/Aliv-Mobile/settings/settingScreen/view/settings_screen.dart';
import '../app/Aliv-Mobile/userProfile/Otp/prepaid/view/otp_profile_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/confirmTopUp/prepaid/view/confirm_top_up_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/purchases/prepaid/view/purchase_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/rewards/prepaid/view/reward_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/rewardsDetails/prepaid/view/reward_details_screen.dart';
import '../app/Aliv-Mobile/userProfile/topUpPayment/prepaid/view/top_up_payment_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/topup/postpaid/view/top_up_prepaid_number_postpaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/topup/prepaid/view/top_up_prepaid_screen.dart';
import '../app/Home/home/all_best_plan_screen.dart';
import '../app/Home/home/home_screen.dart';
import '../app/Home/widgets/bottom_shell.dart';
import '../app/Menu/menu_screen.dart';
import '../app/Plans/view/home_plan_screen.dart';
import '../app/Usage/usage_screen.dart';
import '../app/Aliv-Mobile/userProfile/myProfile/prepaid/view/my_profile_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/profile/postpaid/view/profile_postpaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/profile/prepaid/view/profile_prepaid_screen.dart';
import '../app/splash/view/splash_page.dart';
import 'app_routes.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.otpProfilePrepaidScreen,//guestPurchasePlanConfirmation,//confirmTopUpPrepaidScreen,//confirmTopUpPrepaidScreen,//.addOrEditCardsPrepaidScreen, // initial Screen

    routes: [
      GoRoute(
        path: AppRoutes.faceIdSecurityScreen,
        builder: (context, state) => const FaceIdSecurityScreen(),
      ),
      GoRoute(
        path:AppRoutes.fingerPrintSecurityScreen,
        builder: (context, state) => const FingerPrintSecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpScreen,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
         path: AppRoutes.privacyScreen,
         builder: (context,state) => const PrivacyScreen()
      ),
      GoRoute(
        path: AppRoutes.securityScreen,
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsScreen,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.revConfirmationPrepaidScreen,
        builder: (context, state) => const RevConfirmationPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.revBillPayPrepaidScreen,
        builder: (context, state) => const RevPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.referFriendResponsePrepaidScreen,
        builder: (context, state) => const ReferFriendResponsePrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.referFriendPrepaidScreen,
        builder: (context, state) => const ReferFriendPrepaidScreen(),
      ),
      GoRoute(
          path: AppRoutes.otpAutoRenewPrepaidScreen,
          builder: (context,state) => const OtpAutoRenewPrepaidScreen()
      ),
      GoRoute(
        path: AppRoutes.enterPasswordAutoRenewPrepaidScreen,
        builder: (context, state) => const EnterPasswordAutoRenewPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.autoRenewAuthPrepaidScreen,
        builder: (context, state) => const AutoRenewAuthPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.autoRenewPrepaidScreen,
        builder: (context, state) => const AutoRenewPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpReviewInvoicePostPaidScreen,
        builder: (context, state) => const OtpPostpaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.enterPasswordReviewInvoicePostpaidScreen,
        builder: (context, state) => const EnterPasswordPostpaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.reviewInvoicePostPaidScreen,
        builder: (context, state) => const ReviewInvoicePostpaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.topUpPaymentPrepaidScreen,
        builder: (context, state) => const TopUpPaymentPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.confirmTopUpPrepaidScreen,
        builder: (context, state) => const ConfirmTopUpPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.topUpPrepaidNumberPostpaidScreen,
        builder: (context, state) => const TopUpPrepaidNumberPostPaid(),
      ),

      GoRoute(
        path: AppRoutes.topUpPrepaidScreen,
        builder: (context, state) => const TopUpPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.addOrEditCardsPrepaidScreen,
        builder: (context, state) => const AddOrEditCardsPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.purchasesPrepaidScreen,
        builder: (context, state) => const PurchasesPrepaidScreen(),
      ),
      GoRoute(
          path: AppRoutes.rewardDetailsPrepaidScreen,
          builder: (context,state) => const RewardDetailsPrepaidScreen()
      ),
      GoRoute(
          path: AppRoutes.rewardPrepaidScreen,
          builder: (context,state) => const RewardPrepaidScreen()
      ),
      GoRoute(
          path: AppRoutes.otpProfilePrepaidScreen,
          builder: (context,state) => const OtpProfilePrepaidScreen()
      ),
      GoRoute(
          path: AppRoutes.changePasswordPrepaidScreen,
          builder: (context,state) => const ChangePasswordPrepaidScreen()
      ),
      GoRoute(
          path: AppRoutes.enterPassWordPrepaidScreen,
          builder: (context,state) => const EnterPasswordPrepaidScreen()
      ),
      GoRoute(
          path: AppRoutes.editEmailPrepaidScreen,
          builder: (context,state) => const EditEmailPrepaidScreen()
      ),
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
          ),
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
          amount: 12,
          dateText: '12-23-2025',
          timeText: '08:34',
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
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginOtp,
        builder: (context, state) => const LoginOtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgetPassword,
        builder: (context, state) => const ForgetPasswordScreen(),
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
        builder: (context, state) => const GuestSplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.whyAliv,
        builder: (context, state) => const WhyAlivScreen(),
      ),
      GoRoute(
        path: AppRoutes.guestTopUp,
        builder: (context, state) => const GuestTopUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.confirmGuestTopUp,
        builder: (context, state) =>
            GuestConfirmTopUpScreen(phoneNumber: '245346-452356', amount: 12),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return BottomShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.usage,
            builder: (context, state) => const UsageScreen(),
          ),
          GoRoute(
            path: AppRoutes.plans,
            builder: (context, state) => const HomePlanScreen(),
          ),
          GoRoute(
            path: AppRoutes.menu,
            builder: (context, state) => const MenuScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.allBestPlans,
        builder: (context, state) => const AllBestPlansScreen(),
      ),
    ],
  );
}
