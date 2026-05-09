import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/view/guest_pay_bill_confirm_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/view/guest_splash_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/view/guest_top_up_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/addOnsConfirmation/view/add_ons_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/view/roaming_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/view/why_aliv_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revBill/prepaid/view/rev_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/Otp/postpaid/view/otp_postpaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/addOrEditCards/prepaid/view/add_or_edit_cards_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/view/change_password_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/editEmail/prepaid/view/edit_email_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/enterPassword/prepaid/view/enter_password_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/model/reward_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/call_logs_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/plans_entry_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/purchase_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/view/home_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/view/home_plan_purchase_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/home_plans_payment_method_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/view/home_roaming_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/model/plan_purchase_plan_add_ons_route_args.dart';
import 'package:myaliv_mobile_app/app/Support/view/support_screen.dart';
import 'package:myaliv_mobile_app/app/welcome/view/welcome_view.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/confirmation/postpaid/view/make_payment_confirmation_postpaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/view/make_payment_postpaid_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/view/plan_purchase_plan_add_ons_screen.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/model/guest_pay_bill_receipt_args.dart';
import '../app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/view/guest_pay_bill_receipt_screen.dart';
import '../app/Aliv-Mobile-Guest/confirmGuestTopUp/view/confirm_guest_top_up_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPaymentMethod/prepaid/view/guest_payment_method_prepaid_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlan/view/guest_purchase_plan_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanAddons/view/guest_purchase_plan_add_ons_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/view/guest_purchase_plan_confirmation_screen.dart';
import '../app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/view/guest_purchase_plan_receipt_screen.dart';
import '../app/Aliv-Mobile-Guest/guestTopUp/view/guest_topup_screen.dart';
import '../app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import '../app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/view/auto_renew_auth_prepaid_screen.dart';
import '../app/Aliv-Mobile/autoRenew/autoRenewPage/postpaid/view/auto_pay_postpaid_screen.dart';
import '../app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/view/auto_renew_prepaid_screen.dart';
import '../app/Aliv-Mobile/autoRenew/enterPassword/prepaid/view/enter_password_autoRenew_prepaid_screen.dart';
import '../app/Aliv-Mobile/autoRenew/otp/prepaid/view/otp_prepaid_screen.dart';
import '../app/Aliv-Mobile/createPassword/view/create_password_page.dart';
import '../app/Aliv-Mobile/forgetPassOtp/view/forget_password_otp_screen.dart';
import '../app/Aliv-Mobile/forgetPassword/view/forget_password_screen.dart';
import '../app/Aliv-Mobile/login/view/login_page.dart';
import '../app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import '../app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import '../app/Aliv-Mobile/referAFriend/referFriend/prepaid/view/refer_friend_prepaid_screen.dart';
import '../app/Aliv-Mobile/referAFriend/referFriend/prepaid/view/success_screen.dart';
import '../app/Aliv-Mobile/referAFriend/referFriendResponse/prepaid/view/refer_friend_response_prepaid_screen.dart';
import '../app/Aliv-Mobile/revBillPay/paymentMethod/prepaid/view/rev_payment_method_prepaid_screen.dart';
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
import '../app/Aliv-Mobile/userProfile/editEmail/prepaid/view/verify_email_page.dart';
import '../app/Aliv-Mobile/userProfile/purchaseAddOns/view/purchase_add_ons_screen.dart';
import '../app/Aliv-Mobile/userProfile/purchases/prepaid/view/purchase_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/rewards/prepaid/view/reward_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/rewardsDetails/prepaid/view/reward_details_screen.dart';
import '../app/Aliv-Mobile/userProfile/topUpPayment/prepaid/view/top_up_payment_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/topup/postpaid/view/top_up_prepaid_number_postpaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/topup/prepaid/view/top_up_prepaid_screen.dart';
import '../app/Home/home/all_best_plan_screen.dart';
import '../app/Home/home/home_screen.dart';
import '../app/Home/widgets/bottom_shell.dart';
import '../app/Notifications/notification_screen.dart';
//import '../app/Plans/view/home_plan_screen.dart';
//import '../app/Plans/view/plans_entry_screen.dart';
//import '../app/Plans/view/purchase_confirmation_screen.dart';
import '../app/Security/menu_screen.dart';
import '../app/Security/secuirity_common_password_screen.dart';
import '../app/Security/secuirity_common_verification_code_page.dart';
import '../app/Support/view/chatbot_screen.dart';
import '../app/Support/view/quick_help_screen.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/view/upgrade_credit_limit_screen.dart';
import '../app/Usage/usage_screen.dart';
import '../app/Aliv-Mobile/userProfile/myProfile/prepaid/view/my_profile_prepaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/profile/postpaid/view/profile_postpaid_screen.dart';
import '../app/Aliv-Mobile/userProfile/profile/prepaid/view/profile_prepaid_screen.dart';
import '../app/splash/view/splash_page.dart';
import '../resources/widgets/top_toast.dart';
import 'app_routes.dart';

//I/flutter (24566): Login API status: 202, body: {"TwoFactorKey":"b5aa1c17-10a9-48b9-9370-b0653917f888"}
class AppRouter {
  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey, // ✅ REQUIRED
    initialLocation: AppRoutes.splash, //autoRenewPrepaidScreen,
    routes: [
      GoRoute(
        path: AppRoutes.homePlanConfirmationScreen,
        builder: (context, state) {
          final extra = state.extra;
          final HomePlanConfirmationRouteArgs args;
          if (extra is HomePlanConfirmationRouteArgs) {
            args = extra;
          } else {
            args = const HomePlanConfirmationRouteArgs(
              phoneNumber: '242-801-1616',
              accountHolderName: 'Jade Turnquest',
              primaryPlanName: 'liberty70',
              primaryPlanPrice: 70,
              flow: HomePlanConfirmationEntryFlow.proceed,
              selectedAddOns: <HomePlanConfirmationSelectedAddOn>[
                HomePlanConfirmationSelectedAddOn(
                  id: 'addon1',
                  title: 'liberty data 1',
                  price: 5,
                ),
              ],
            );
          }
          return HomePlanConfirmationScreen(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.addOnsConfirmation,
        builder: (context, state) =>
            const AddOnsConfirmationScreen(phoneNumber: '242-801-1616'),
      ),
      GoRoute(
        path: AppRoutes.roamingPlanConfirmation,
        builder: (context, state) {
          // Read optional route flag from navigation extras.
          final extra = state.extra;
          bool showDateField = true;
          if (extra is Map<String, dynamic>) {
            final value = extra['showDateField'];
            if (value is bool) {
              showDateField = value;
            } else if (value is String) {
              showDateField = value.toLowerCase() == 'true';
            }
          }

          return RoamingPlanConfirmationScreen(
            phoneNumber: '242-801-1616',
            showDateField: showDateField,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.homeRoamingConfirmation,
        builder: (context, state) {
          // Read optional route flag from navigation extras.
          final extra = state.extra;
          bool showDateField = true;
          if (extra is Map<String, dynamic>) {
            final value = extra['showDateField'];
            if (value is bool) {
              showDateField = value;
            } else if (value is String) {
              showDateField = value.toLowerCase() == 'true';
            }
          }

          return HomeRoamingConfirmationScreen(
            phoneNumber: '242-801-1616',
            showDateField: showDateField,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.revPaymentMethodPrepaidScreen,
        builder: (context, state) => const REVPaymentMethodPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.faceIdSecurityScreen,
        builder: (context, state) => const FaceIdSecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.fingerPrintSecurityScreen,
        builder: (context, state) => const FingerPrintSecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpScreen,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyScreen,
        builder: (context, state) => const PrivacyScreen(),
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
        path: AppRoutes.makePaymentConfirmationPostpaidScreen,
        builder: (context, state) =>
            const MakePaymentConfirmationPostPaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.makePaymentPostpaidScreen,
        builder: (context, state) => const MakePaymentPostPaidScreen(),
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
        builder: (context, state) => const OtpAutoRenewPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.enterPasswordAutoRenewPrepaidScreen,
        builder: (context, state) =>
            const EnterPasswordAutoRenewPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.autoRenewAuthPrepaidScreen,
        builder: (context, state) {
          final extra = state.extra;
          AutoRenewPaymentMethodType paymentMethod =
              AutoRenewPaymentMethodType.wallet;
          String? cardToken;
          if (extra is AutoRenewAuthArgs) {
            paymentMethod = extra.paymentMethod;
            cardToken = extra.cardToken;
          } else if (extra is AutoRenewPaymentMethodType) {
            paymentMethod = extra;
          }
          return AutoRenewAuthPrepaidScreen(
            paymentMethod: paymentMethod,
            cardToken: cardToken,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.autoRenewPrepaidScreen,
        builder: (context, state) => const AutoRenewPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.autoPayPostpaidScreen,
        builder: (context, state) => const AutoPayPostpaidScreen(),
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
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialTab = int.tryParse(tabParam ?? '0') ?? 0;

          return TopUpPrepaidScreen(initialTab: initialTab);
        },
      ),
      // GoRoute(
      //   path: AppRoutes.topUpPrepaidScreen,
      //   builder: (context, state) => const TopUpPrepaidScreen(),
      // ),
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
        builder: (context, state) {
          final reward = state.extra as RewardModel?;
          return RewardDetailsPrepaidScreen(reward: reward);
        },
      ),
      GoRoute(
        path: AppRoutes.rewardPrepaidScreen,
        builder: (context, state) => const RewardPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpProfilePrepaidScreen,
        builder: (context, state) => const OtpProfilePrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePasswordPrepaidScreen,
        builder: (context, state) => const ChangePasswordPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.enterPassWordPrepaidScreen,
        builder: (context, state) => const EnterPasswordPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.editEmailPrepaidScreen,
        builder: (context, state) => const EditEmailPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.myProfilePrepaidScreen,
        builder: (context, state) => const MyProfilePrepaidScreen(),
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
        path: AppRoutes.callLogs,
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];

          final initialTab = tabParam == 'call_logs'
              ? CallLogsTabType.callLogs
              : CallLogsTabType.transactions;

          return CallLogsScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: AppRoutes.guestPurchasePlanReceipt,
        builder: (context, state) => const GuestPurchasePlanReceiptScreen(
          phoneNumber: '242-801-1616',
          amount: 75,
          dateText: 'Mar 12,2023',
          timeText: '446332',
        ),
      ),
      GoRoute(
        path: AppRoutes.homePlanPurchaseReceiptScreen,
        builder: (context, state) {
          final Object? extra = state.extra;
          bool hideSaveCreditCard = false;

          if (extra is Map<String, dynamic>) {
            final dynamic value = extra['hideSaveCreditCard'];
            if (value is bool) {
              hideSaveCreditCard = value;
            } else if (value is String) {
              hideSaveCreditCard = value.toLowerCase() == 'true';
            }
          }

          return HomePlanPurchaseReceiptScreen(
            phoneNumber: '242-801-1616',
            amount: 75,
            dateText: 'Mar 12, 2023',
            timeText: '7:30 am',
            hideSaveCreditCard: hideSaveCreditCard,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.guestPurchasePlanConfirmation,
        builder: (context, state) {
          final Object? extra = state.extra;
          final GuestPurchasePlanConfirmationRouteArgs args;

          if (extra is GuestPurchasePlanConfirmationRouteArgs) {
            args = extra;
          } else {
            args = const GuestPurchasePlanConfirmationRouteArgs(
              phoneNumber: '242-801-1616',
              accountHolderName: 'guest purchase a plan',
              primaryPlanName: 'liberty70',
              primaryPlanPrice: 70,
              flow: GuestPurchasePlanConfirmationEntryFlow.proceed,
              selectedAddOns: <GuestPurchasePlanConfirmationSelectedAddOn>[
                GuestPurchasePlanConfirmationSelectedAddOn(
                  id: 'a1',
                  title: 'liberty data 1',
                  price: 5.00,
                ),
              ],
            );
          }

          return GuestPurchasePlanConfirmationScreen(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.guestPurchasePlanAddOns,
        builder: (context, state) => const GuestPurchasePlanAddOnsScreen(),
      ),
      GoRoute(
        path: AppRoutes.homePurchasePlanAddOns,
        builder: (context, state) {
          final extra = state.extra;
          final routeArgs = extra is PlanPurchasePlanAddOnsRouteArgs
              ? extra
              : null;

          return PlanPurchasePlanAddOnsScreen(routeArgs: routeArgs);
        },
      ),
      GoRoute(
        path: AppRoutes.purchaseAddOns,
        builder: (context, state) => const PurchaseAddOnsScreen(),
      ),
      GoRoute(
        //
        path: AppRoutes.guestPayBillReceipt,
        builder: (context, state) {
          final receiptArgs = state.extra;

          if (receiptArgs is GuestPayBillReceiptArgs) {
            return GuestPayBillReceiptScreen(args: receiptArgs);
          }

          return const GuestPayBillReceiptScreen(
            args: GuestPayBillReceiptArgs(
              serviceName: 'ALIV Postpaid',
              identifierLabel: 'phone no.',
              identifierValue: '242-801-0000',
              amount: 200.00,
              dateText: 'Mar 22, 2023',
              timeText: '07:30 am',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.guestPayBillConfirm,
        builder: (context, state) {
          final confirmArgs = state.extra;

          if (confirmArgs is GuestPayBillConfirmArgs) {
            return GuestPayBillConfirmScreen(args: confirmArgs);
          }

          // Fallback for direct route access without navigation args.
          return const GuestPayBillConfirmScreen(
            args: GuestPayBillConfirmArgs(
              serviceName: 'ALIV Postpaid',
              identifierLabel: 'phone no.',
              identifierValue: '242-801-0000',
              amount: 200.00,
            ),
          );
        },
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
          phoneNumber: '234-235-454',
          amount: 12,
          dateText: 'Mar 22, 2023',
          timeText: '8:34 am',
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
        builder: (context, state) {
          // Typed route payload keeps navigation data explicit and safe.
          final extra = state.extra;
          final args = extra is LoginOtpRouteArgs
              ? extra
              : const LoginOtpRouteArgs(
                  twoFactorKey: '',
                  phoneNumber: '',
                  apiPhoneNumber: '',
                );

          return LoginOtpScreen(
            initialTwoFactorKey: args.twoFactorKey,
            initialPhoneNumber: args.phoneNumber,
            initialApiPhoneNumber: args.apiPhoneNumber,
          );
        },
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
            GuestConfirmTopUpScreen(phoneNumber: '245-346-452356', amount: 15),
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
          // GoRoute(
          //   path: AppRoutes.usage,
          //   builder: (context, state) => const UsageScreen(),
          // ),
          //
          GoRoute(
            path: AppRoutes.usage,
            builder: (context, state) => const UsageScreen(),
          ),

          GoRoute(
            path: AppRoutes.upgradeCreditLimit,
            builder: (context, state) {
              return const UpgradeCreditLimitScreen();
            },
          ),

          // GoRoute(
          //   path: AppRoutes.plans,
          //   builder: (context, state) => const HomePlanScreen(),
          // ),
          // need to change here
          GoRoute(
            path: AppRoutes.plans,
            builder: (context, state) {
              final tabParam = state.uri.queryParameters['tab'];
              return PlansEntryScreen(initialTab: _parsePlanTab(tabParam));
            },
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

      GoRoute(
        path: AppRoutes.notificationScreen,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.supportScreen,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatScreen,
        builder: (context, state) => const ChatBotScreen(),
      ),

      GoRoute(
        path: AppRoutes.callSupportScreen,
        builder: (context, state) => const QuickHelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.enterPassword,
        pageBuilder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'enter password';
          final continueRoute =
              state.uri.queryParameters['continue'] ?? AppRoutes.home;

          return MaterialPage(
            key: ValueKey(state.uri.toString()),
            child: CommonEnterPasswordPage(
              appBarTitle: title,
              continueRoute: continueRoute,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.verificationCode,
        pageBuilder: (context, state) {
          final nextRoute = state.uri.queryParameters['next'] ?? AppRoutes.home;

          return MaterialPage(
            key: ValueKey(state.uri.toString()),
            child: VerificationCodePage(nextRoute: nextRoute),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.verifyEmail,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';

          return MaterialPage(
            key: ValueKey(state.uri.toString()),
            child: VerifyEmailPage(email: email),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.guestPaymentMethodScreen,
        builder: (context, state) => const GuestPaymentMethodPrepaidScreen(),
      ),
      GoRoute(
        path: AppRoutes.homePlansPaymentMethodScreen,
        builder: (context, state) {
          final Object? extra = state.extra;

          HomePlansPaymentMethodRouteArgs routeArgs =
              const HomePlansPaymentMethodRouteArgs();
          if (extra is HomePlansPaymentMethodRouteArgs) {
            routeArgs = extra;
          }

          return HomePlansPaymentMethodScreen(args: routeArgs);
        },
      ),
      GoRoute(
        path: AppRoutes.confirmation,
        pageBuilder: (context, state) {
          final showBeginOn = state.uri.queryParameters['showBeginOn'] == 'true';
          final extra = state.extra;
          final postpaidPlan = extra is HomePlansPostPaidPlanModel ? extra : null;

          final beginDateString = state.uri.queryParameters['beginDate'];

          DateTime? beginDate;
          if (beginDateString != null) {
            beginDate = DateTime.tryParse(beginDateString);
          }

          return MaterialPage(
            key: ValueKey(state.uri.toString()),
            child: ConfirmationScreen(
              showBeginOn: showBeginOn,
              beginDate: beginDate,
              plan: postpaidPlan,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.invitingSuccess,
        pageBuilder: (context, state) {
          final referralCode = state.uri.queryParameters['code'] ?? '';

          return MaterialPage(
            key: ValueKey(state.uri.toString()),
            child: InvitingSuccessScreen(referralCode: referralCode),
          );
        },
      ),
    ],
  );
}

HomePlanTab? _parsePlanTab(String? value) {
  if (value == null || value.isEmpty) return null;
  for (final tab in HomePlanTab.values) {
    if (tab.name == value) return tab;
  }
  return null;
}
