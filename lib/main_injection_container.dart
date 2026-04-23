import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/account_info_injection.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/plan_injection.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/limited_offer_injection.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/best_plan_injection.dart';
import 'package:myaliv_mobile_app/app/Home/balance/balance_injection.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/consumption_limit_injection.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/device_limits_injection.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/call_logs_injection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/rewards_injection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/review_invoice_injection.dart';

/// Main app dependency injection
///
/// Orchestrates initialization of both core and app-specific dependencies.
class AppMainInjection {
  late CoreInjection _coreInjection;

  AppMainInjection() {
    _coreInjection = CoreInjection();
  }

  /// Initialize all dependencies
  ///
  /// Call order:
  /// 1. Core dependencies (with auth loading)
  /// 2. App-specific dependencies (account info, plans, etc.)
  Future<void> initInjection() async {
    // Initialize core with auth loading functions
    await _coreInjection.initInjection(
      getTicket: LocalStorage.getTicket,
      getAccountID: LocalStorage.getAccountID,
      username: userName,
    );

    // Initialize account information feature
    await setupAccountInfoInjection();

    // Initialize plan feature
    await setupPlanInjection();

    // Initialize limited time offer feature
    await setupLimitedOfferInjection();

    // Initialize best plans feature
    await setupBestPlanInjection();

    // Initialize balance feature
    await setupBalanceInjection();

    // Initialize consumption limits (my limits) feature
    await setupConsumptionLimitInjection();

    // Initialize device limits feature (for upgrade credit limit screen)
    await setupDeviceLimitsInjection();

    // Initialize call logs feature
    await setupCallLogsInjection();

    // Initialize rewards feature
    await setupRewardsInjection();

    // Initialize review invoice feature
    await setupReviewInvoiceInjection();
  }
}
