import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Runs the hard-logout sequence used by both the user-initiated logout flow
/// and the [BearerAuthInterceptor] session-expired path:
///   1. AuthManager.clearSession — wipes secure storage + memory
///   2. NetworkService — clear cookies + cancel in-flight requests
///   3. LocalStorage — wipe non-auth prefs (account-id shim, cached maps)
///   4. Reset all per-user cubits (account info, plans, balances, offers)
///   5. Navigate to the welcome screen
///
/// Safe to call multiple times — every step is idempotent.
Future<void> performHardLogout() async {
  try {
    await instance<AuthManager>().clearSession();
  } catch (e) {
    if (kDebugMode) debugPrint('hardLogout: clearSession failed — $e');
  }

  try {
    final network = instance<NetworkService>();
    network.cancelAllRequests('logout');
    await network.clearCookies();
  } catch (e) {
    if (kDebugMode) debugPrint('hardLogout: network cleanup failed — $e');
  }

  try {
    await LocalStorage.clearAll();
  } catch (e) {
    if (kDebugMode) debugPrint('hardLogout: LocalStorage.clearAll failed — $e');
  }

  try {
    await instance<AccountInfoCubit>().clearAccountInfo();
    instance<PlansCubit>().reset();
    instance<PlansRepository>().clearCache();
    instance<DeviceLimitsCubit>().reset();
    await instance<BalanceCubit>().clearForLogout();
    instance<BucketUsageSummaryCubit>().reset();
    instance<LimitedOfferCubit>().reset();
    instance<BestPlanCubit>().reset();
    instance<ConsumptionLimitCubit>().reset();
  } catch (e) {
    if (kDebugMode) debugPrint('hardLogout: cubit reset failed — $e');
  }

  final ctx = rootNavigatorKey.currentContext;
  if (ctx != null) {
    ctx.go(AppRoutes.welcome);
  }

  if (kDebugMode) debugPrint('✅ hardLogout complete');
}
