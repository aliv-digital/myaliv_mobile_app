import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import '../../../../core/localStorage/localStorage.dart';
import '../../../../core/networkService/api_paths.dart';
import '../../../../core/networkService/app_http_client.dart';
import '../../account-information/cubit/account_info_cubit.dart';

class LogoutRepository {
  LogoutRepository({ApiService? apiService})
    : _api = apiService ?? ApiService();

  final ApiService _api;

  /// Calls logout endpoint and clears all auth state
  ///
  /// This method:
  /// 1. Reads auth from GlobalState (fast, in-memory)
  /// 2. Calls logout API endpoint
  /// 3. Uses AuthManager to clear both SharedPreferences and GlobalState
  /// 4. Clears NetworkService auth headers and cookies
  /// 5. Clears AccountInfoCubit (HydratedBloc persisted account data)
  ///
  /// Backend success response can be `{}` (or empty body), so this returns
  /// true for successful 2xx responses when no fields are present.
  Future<dynamic> logout() async {
    try {
      // Get auth from GlobalState (in-memory, fast)
      final auth = globalState.authContext;

      if (auth == null || !auth.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('⚠️ No active session found, clearing local data only');
        }
        // Still clear local data even if no active session
        await _clearAllAuthData();
        return true;
      }

      if (kDebugMode) {
        debugPrint('Logout request initiated for user: ${auth.username}');
      }

      // Call logout API with auth token from GlobalState
      final response = await _api.postJson(
        Api.logOutUrl,
        headers: <String, String>{
          'Authorization': 'Basic ${auth.basicAuthToken}',
        },
      );

      if (kDebugMode) {
        debugPrint(
          'Logout status: ${response.statusCode}, body: ${response.responseJson}',
        );
      }

      final parsedJson = _tryDecodeMap(response.responseJson);

      if (ApiService.isSuccessStatusCode(response.statusCode)) {
        // ========== Clear all auth data using AuthManager ==========
        await _clearAllAuthData();

        if (kDebugMode) {
          debugPrint('✅ Logout: All auth data cleared');
        }

        return true;
      }

      // If API call failed but we want to logout anyway, still clear local data
      // Uncomment the line below if you want to force logout even on API failure
      // await _clearAllAuthData();

      throw Exception(
        ApiService.friendlyErrorFromResponse(
              response,
              backendMessage: _extractBackendMessage(parsedJson),
            ) ??
            'Could not logout. Please try again.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Logout failed: $e');
      }
      rethrow;
    }
  }

  /// Clear all authentication data from all layers
  Future<void> _clearAllAuthData() async {
    // 1. Use AuthManager to clear SharedPreferences + GlobalState
    final authManager = instance<AuthManager>();
    await authManager.clearAuth(clearAllPreferences: LocalStorage.clearAll);

    // 2. Clear NetworkService auth and cookies
    final networkService = instance<NetworkService>();
    networkService.clearAuthHeaders();
    await networkService.clearCookies();

    // 3. Clear AccountInfoCubit (HydratedBloc persisted data)
    final accountInfoCubit = instance<AccountInfoCubit>();
    await accountInfoCubit.clearAccountInfo();

    // 4. Reset PlansCubit state to clear cached plans
    // This fixes the issue where switching from prepaid to postpaid (or vice versa)
    // would skip API calls because old plan data was still marked as loaded
    final plansCubit = instance<PlansCubit>();
    plansCubit.reset();

    // 5. Clear PlansRepository cache (in-memory plan data)
    final plansRepository = instance<PlansRepository>();
    plansRepository.clearCache();

    // 6. Reset home-screen cubits that hold per-user data
    // These are GetIt singletons, so without reset() the previous user's
    // device limits, balance, offers, plans, and limits would persist
    // across account switches.
    instance<DeviceLimitsCubit>().reset();
    instance<BalanceCubit>().reset();
    instance<BucketUsageSummaryCubit>().reset();
    instance<LimitedOfferCubit>().reset();
    instance<BestPlanCubit>().reset();
    instance<ConsumptionLimitCubit>().reset();

    // Note: AppUiConfigCubit is NOT reset here because:
    // - It's not registered in DI (created in main.dart with BlocProvider)
    // - It gets reset anyway during login via _setLoggedInUserUiConfig()

    if (kDebugMode) {
      debugPrint(
        '✅ All auth data cleared (SharedPreferences + GlobalState + NetworkService + HydratedBloc + Plans + PlansCache + HomeCubits)',
      );
    }
  }

  Map<String, dynamic>? _tryDecodeMap(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        final mapped = <String, dynamic>{};
        for (final entry in decoded.entries) {
          mapped[entry.key.toString()] = entry.value;
        }
        return mapped;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractBackendMessage(Map<String, dynamic>? json) {
    if (json == null) return null;
    final message =
        json['message'] ??
        json['Message'] ??
        json['error'] ??
        json['Error'] ??
        json['detail'] ??
        json['Detail'] ??
        json['reason'] ??
        json['Reason'];
    return message?.toString();
  }
}
