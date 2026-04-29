import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/models/plan_categorization_result.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import 'plans_state.dart';

/// Cubit for managing plan data
///
/// Simplified implementation that:
/// - Fetches ALL plans in a single API call (8x faster than per-tab fetching)
/// - Fetches add-ons in parallel
/// - Uses single flag for race condition protection
/// - Maintains same public API as HomePlanCubit for UI compatibility
class PlansCubit extends Cubit<PlansState> {
  PlansCubit({PlansRepository? repository})
      : _repository = repository ?? PlansRepository(),
        super(const PlansState());

  final PlansRepository _repository;

  /// Single flag to prevent duplicate fetches
  bool _isFetching = false;

  // ═══════════════════════════════════════════════════════════════════
  // PUBLIC API (SAME signatures as HomePlanCubit - UI calls these)
  // ═══════════════════════════════════════════════════════════════════

  /// Called by UI in initState - SAME signature as HomePlanCubit
  Future<void> started({required UserType userType}) async {
    final defaultTab = _defaultTabForUserType(userType);

    if (state.selectedTab != defaultTab) {
      emit(state.copyWith(selectedTab: defaultTab, expandedPlanIds: const {}));
    }

    // Fetch all data if not already loaded
    if (!state.hasData) {
      await _fetchAllPlans();
    }
  }

  /// Called by UI on tab tap - SAME signature as HomePlanCubit
  Future<void> changeTab(HomePlanTab tab) async {
    if (tab == state.selectedTab) return;

    emit(state.copyWith(selectedTab: tab, expandedPlanIds: const {}));

    // Data already loaded in single fetch, no need to fetch per tab
  }

  /// Called by UI on pull-to-refresh - SAME signature as HomePlanCubit
  Future<void> refreshCurrentTab() async {
    await _fetchAllPlans(forceRefresh: true);
  }

  /// Called by UI to expand/collapse plan card - SAME signature
  void toggleExpanded(String planId) {
    final next = Set<String>.from(state.expandedPlanIds);
    if (next.contains(planId)) {
      next.remove(planId);
    } else {
      next.add(planId);
    }
    emit(state.copyWith(expandedPlanIds: next));
  }

  /// Called by UI to select/deselect add-on - SAME signature
  void toggleAddon(HomePlanAddOnModel addOn) {
    final next = Set<String>.from(state.selectedAddOnIds);
    if (next.contains(addOn.id)) {
      next.remove(addOn.id);
    } else {
      next.add(addOn.id);
    }
    emit(state.copyWith(selectedAddOnIds: next));
  }

  /// Called by UI when purchase button pressed - SAME signature
  void purchaseNowPressed(HomePlanModel plan) {
    if (!state.isPurchaseModalOpen) {
      emit(state.copyWith(isPurchaseModalOpen: true));
    }
  }

  /// Called by UI when purchase modal closes - SAME signature
  void purchaseModalClosed() {
    emit(state.copyWith(isPurchaseModalOpen: false));
  }

  /// Called by UI after showing toast - SAME signature
  void toastConsumed() {
    emit(state.copyWith(clearPendingToast: true));
  }

  /// Called on logout - SAME signature as HomePlanCubit
  void reset() {
    _isFetching = false;
    emit(const PlansState());

    if (kDebugMode) {
      debugPrint('✅ PlansCubit.reset(): State reset to initial');
    }
  }

  /// Called by home screen to preload data - SAME signature as HomePlanCubit
  Future<void> loadInitialPlans({
    bool forceRefresh = false,
    required UserType userType,
  }) async {
    if (!globalState.isAuthenticated) {
      if (kDebugMode) {
        debugPrint('⚠️ loadInitialPlans: Not authenticated, skipping');
      }
      return;
    }

    if (_isFetching) {
      if (kDebugMode) {
        debugPrint('⚠️ loadInitialPlans: Already fetching, skipping');
      }
      return;
    }

    if (!forceRefresh && state.hasData) {
      if (kDebugMode) {
        debugPrint('⚠️ loadInitialPlans: Already loaded, skipping');
      }
      return;
    }

    await _fetchAllPlans(forceRefresh: forceRefresh);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE - SIMPLIFIED IMPLEMENTATION (Single fetch for all data)
  // ═══════════════════════════════════════════════════════════════════

  /// Single method to fetch ALL plans + add-ons in parallel
  Future<void> _fetchAllPlans({bool forceRefresh = false}) async {
    // Prevent duplicate fetches
    if (_isFetching) {
      if (kDebugMode) {
        debugPrint('⚠️ PlansCubit: Already fetching, skipping');
      }
      return;
    }

    // Skip if data exists and cache is fresh (unless forceRefresh)
    if (!forceRefresh && state.hasData && !_shouldRefresh()) {
      if (kDebugMode) {
        debugPrint('⚠️ PlansCubit: Data fresh, skipping fetch');
      }
      return;
    }

    _isFetching = true;
    emit(state.copyWith(status: PlansStatus.loading, errorMessage: null));

    if (kDebugMode) {
      debugPrint('🔄 PlansCubit: Fetching all plans...');
    }

    try {
      // Fetch plans and add-ons in parallel for better performance
      final results = await Future.wait([
        _repository.fetchCategorizedPlans(forceRefresh: forceRefresh),
        _repository.fetchAddOnsData(forceRefresh: forceRefresh),
      ]);

      final plansResult = results[0] as PlanCategorizationResult;
      final addOnsResult = results[1] as AddOnsResult;

      final now = DateTime.now();

      emit(state.copyWith(
        status: PlansStatus.success,
        // Plans data
        dailyApiPlans: plansResult.dailyPlans,
        weeklyApiPlans: plansResult.weeklyPlans,
        monthlyApiPlans: plansResult.monthlyPlans,
        roamingApiPlans: plansResult.roamingPlans,
        roamEasyApiPlans: plansResult.roamEasyPlans,
        mifiApiPlans: plansResult.mifiPlans,
        libertyGlobalApiPlans: plansResult.libertyGlobalPlans,
        postpaidRoamingApiPlans: plansResult.postpaidRoamingPlans,
        // Add-ons data
        addOns: addOnsResult.addOns,
        addOnsApiPrimaryPlans: addOnsResult.primaryPlans,
        standAlonePlans: addOnsResult.standAlonePlans,
        // Timestamps
        lastFetchedAt: now,
        addOnsApiLastSyncedAt: now,
        // Clear error
        errorMessage: null,
      ));
    } catch (e) {
      final errorMsg = _friendlyErrorMessage(e);

      if (kDebugMode) {
        debugPrint('❌ PlansCubit: Error fetching plans - $e');
      }

      // Emit failure with toast
      _emitFailureWithToast(errorMsg);
    } finally {
      _isFetching = false;
    }
  }

  /// Emit failure state with toast message
  void _emitFailureWithToast(String errorMessage) {
    final nextToastId = state.toastSequence + 1;
    final toast = PlansToastMessage(
      id: nextToastId,
      message: errorMessage,
    );

    emit(state.copyWith(
      status: PlansStatus.failure,
      errorMessage: errorMessage,
      pendingToast: toast,
      toastSequence: nextToastId,
    ));
  }

  /// Get default tab based on user type
  HomePlanTab _defaultTabForUserType(UserType userType) {
    return userType == UserType.postpaid
        ? HomePlanTab.postpaidRoaming
        : HomePlanTab.monthly;
  }

  /// Check if cache is stale (1 hour TTL)
  bool _shouldRefresh() {
    if (state.lastFetchedAt == null) return true;
    final age = DateTime.now().difference(state.lastFetchedAt!);
    return age > const Duration(hours: 1);
  }

  /// Convert exception to user-friendly message
  String _friendlyErrorMessage(dynamic error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('socket') ||
        msg.contains('no internet') ||
        msg.contains('network')) {
      return 'No internet connection. Please check and try again.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('unauthorized') || msg.contains('401')) {
      return 'Session expired. Please login again.';
    }
    if (msg.contains('forbidden') || msg.contains('403')) {
      return 'You do not have access to plans right now.';
    }
    if (msg.contains('not found') || msg.contains('404')) {
      return 'Plans are not available right now.';
    }
    if (msg.contains('500') || msg.contains('server')) {
      return 'Plans are temporarily unavailable. Please try again shortly.';
    }

    return 'Something went wrong. Please try again.';
  }
}
