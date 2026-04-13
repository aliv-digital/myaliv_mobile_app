import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/home_plan_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/base_plan_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/shared/repository/base_plan_repository_exception.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

class HomePlanCubit extends Cubit<HomePlanState> {
  HomePlanCubit(this.repository) : super(HomePlanState.initial());

  final BasePlanRepository repository;

  bool _isDailyApiSyncInProgress = false;
  bool _isWeeklyApiSyncInProgress = false;
  bool _isMonthlyApiSyncInProgress = false;
  bool _isRoamingApiSyncInProgress = false;
  bool _isRoamEasyApiSyncInProgress = false;
  bool _isMifiApiSyncInProgress = false;
  bool _isLibertyGlobalApiSyncInProgress = false;
  bool _isAddOnsApiSyncInProgress = false;
  bool _isPostpaidRoamingApiSyncInProgress = false;

  Future<void> started({required UserType userType}) async {
    final HomePlanTab initialTab = _defaultTabForUserType(userType);
    if (state.selectedTab != initialTab) {
      emit(state.copyWith(selectedTab: initialTab, expandedPlanIds: {}));
    }
    // Don't use forceRefresh here - let _loadByTab decide based on existing data
    // This prevents clearing data that's currently being loaded by loadInitialPlans()
    await _loadByTab(tab: initialTab);
  }

  Future<void> changeTab(HomePlanTab tab) async {
    if (tab == state.selectedTab) {
      return;
    }

    emit(state.copyWith(selectedTab: tab, expandedPlanIds: {}));

    // _loadByTab already checks if tab is loading, so safe to call
    await _loadByTab(tab: tab);
  }

  void toggleExpanded(String planId) {
    final next = Set<String>.from(state.expandedPlanIds);
    if (next.contains(planId)) {
      next.remove(planId);
    } else {
      next.add(planId);
    }
    emit(state.copyWith(expandedPlanIds: next));
  }

  void viewDetailsPressed(HomePlanModel plan) {}

  void purchaseNowPressed(HomePlanModel plan) {
    // Prevent opening multiple purchase modals simultaneously
    if (!state.isPurchaseModalOpen) {
      emit(state.copyWith(isPurchaseModalOpen: true));
    }
  }

  void purchaseModalClosed() {
    emit(state.copyWith(isPurchaseModalOpen: false));
  }

  void toggleAddon(HomePlanAddOnModel addOn) {
    final next = Set<String>.from(state.selectedAddOnIds);
    if (next.contains(addOn.id)) {
      next.remove(addOn.id);
    } else {
      next.add(addOn.id);
    }
    emit(state.copyWith(selectedAddOnIds: next));
  }

  /// Refresh current tab - forces API call even if data exists
  Future<void> refreshCurrentTab() async {
    await _loadByTab(tab: state.selectedTab, forceRefresh: true);
  }

  /// Refresh a specific tab - forces API call even if data exists
  Future<void> refreshTab(HomePlanTab tab) async {
    await _loadByTab(tab: tab, forceRefresh: true);
  }

  /// Reset cubit to initial state (call on logout)
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 HomePlanCubit.reset(): Resetting all state and flags');
    }

    // Reset all in-progress flags
    _isDailyApiSyncInProgress = false;
    _isWeeklyApiSyncInProgress = false;
    _isMonthlyApiSyncInProgress = false;
    _isRoamingApiSyncInProgress = false;
    _isRoamEasyApiSyncInProgress = false;
    _isMifiApiSyncInProgress = false;
    _isLibertyGlobalApiSyncInProgress = false;
    _isAddOnsApiSyncInProgress = false;
    _isPostpaidRoamingApiSyncInProgress = false;

    // Reset state to initial
    emit(HomePlanState.initial());

    if (kDebugMode) {
      debugPrint('✅ HomePlanCubit.reset(): State reset to initial');
    }
  }

  Future<void> loadInitialPlans({
    bool forceRefresh = false,
    required UserType userType,
  }) async {
    if (!globalState.isAuthenticated) {
      debugPrint('⚠️ loadInitialPlans: Not authenticated, skipping');
      return;
    }

    // Check if plans are currently loading - prevent duplicate API calls
    if (_isInitialPlansLoading(userType: userType)) {
      debugPrint(
        '⚠️ loadInitialPlans: Already loading for $userType, skipping',
      );
      return;
    }

    // Check if plans are already loaded - skip unless forceRefresh
    if (!forceRefresh && _hasInitialPlansLoaded(userType: userType)) {
      debugPrint(
        '⚠️ loadInitialPlans: Already loaded for $userType, skipping (use forceRefresh to reload)',
      );
      return;
    }

    // Emit loading state for background preloading
    // This prevents race condition with started() method
    final defaultTab = _defaultTabForUserType(userType);
    _emitTabStatus(tab: defaultTab, status: HomePlanStatus.loading);

    // For prepaid: preload add-ons for Dashboard active card
    // Safe to run in parallel - different endpoint (bundles vs available-plans)
    if (userType == UserType.prepaid) {
      _scheduleAddOnsApiSyncIfIdle();
    }

    // Preload the DEFAULT tab that will be shown first
    switch (defaultTab) {
      case HomePlanTab.monthly:
        _scheduleMonthlyApiSyncIfIdle();
        break;
      case HomePlanTab.postpaidRoaming:
        _schedulePostpaidRoamingApiSyncIfIdle();
        break;
      default:
        // Fallback for any other default tab
        break;
    }
  }

  Future<void> syncAddOns({bool printRawResponse = false}) async {
    // Flag may already be set by schedule method to prevent race condition
    // Don't exit early, just ensure it's set
    if (!_isAddOnsApiSyncInProgress) {
      _isAddOnsApiSyncInProgress = true;
    }

    try {
      if (!globalState.isAuthenticated) {
        _emitTabFailureWithToast(
          tab: HomePlanTab.addOns,
          errorMessage: 'Please login to view add-ons',
        );
        return;
      }

      final List<BasePlanModel> primaryPlans = await repository
          .fetchAddOnsPrimaryPlansFromApi(
            printRawResponse: printRawResponse,
            printFilteredPrimaryPlans: false,
          );

      final BasePlanModel? selectedPrimaryPlan = repository
          .selectEarliestAddOnsPrimaryPlan(primaryPlans);
      final List<HomePlanAddOnModel> addOns = selectedPrimaryPlan == null
          ? const <HomePlanAddOnModel>[]
          : repository.mapAvailableBoltOnsToUiAddOns(
              primaryPlan: selectedPrimaryPlan,
            );

      final DateTime syncedAt = DateTime.now();
      final nextApiTabMeta = Map<HomePlanTab, HomePlanTabApiMeta>.from(
        state.apiTabMeta,
      );
      nextApiTabMeta[HomePlanTab.addOns] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: primaryPlans.length,
        lastSyncedAt: syncedAt,
      );

      final nextState =
          _withTabStatus(
            currentState: state,
            tab: HomePlanTab.addOns,
            status: HomePlanStatus.loaded,
          ).copyWith(
            addOnsApiPrimaryPlans: primaryPlans,
            addOns: addOns,
            selectedAddOnIds: const {},
            apiTabMeta: nextApiTabMeta,
            addOnsApiLastSyncedAt: syncedAt,
          );
      emit(nextState);
    } on BasePlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        tab: HomePlanTab.addOns,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.addOns,
          error: error,
        ),
      );
    } catch (_) {
      _emitTabFailureWithToast(
        tab: HomePlanTab.addOns,
        errorMessage: 'Failed to sync add-ons bundles',
      );
    } finally {
      _isAddOnsApiSyncInProgress = false;
    }
  }

  Future<void> syncDaily({bool printRawResponse = false}) async {
    await _syncTypedTab<BasePlanModel>(
      tab: HomePlanTab.daily,
      isInProgress: () => _isDailyApiSyncInProgress,
      setInProgress: (value) => _isDailyApiSyncInProgress = value,
      load: () => repository.fetchDailyPlansFromApi(
        printRawResponse: printRawResponse,
        printFilteredDailyPlans: false,
      ),
      itemCount: (plans) => plans.length,
      apply: (base, plans, syncedAt, nextApiTabMeta) => base.copyWith(
        dailyApiPlans: plans,
        apiTabMeta: nextApiTabMeta,
        dailyApiLastSyncedAt: syncedAt,
      ),
      unauthenticatedMessage: 'Please login to view daily plans',
      fallbackErrorMessage: 'Failed to sync daily plans',
    );
  }

  Future<void> syncWeekly({bool printRawResponse = false}) async {
    await _syncTypedTab<BasePlanModel>(
      tab: HomePlanTab.weekly,
      isInProgress: () => _isWeeklyApiSyncInProgress,
      setInProgress: (value) => _isWeeklyApiSyncInProgress = value,
      load: () => repository.fetchWeeklyPlansFromApi(
        printRawResponse: printRawResponse,
        printFilteredWeeklyPlans: false,
      ),
      itemCount: (plans) => plans.length,
      apply: (base, plans, syncedAt, nextApiTabMeta) => base.copyWith(
        weeklyApiPlans: plans,
        apiTabMeta: nextApiTabMeta,
        weeklyApiLastSyncedAt: syncedAt,
      ),
      unauthenticatedMessage: 'Please login to view weekly plans',
      fallbackErrorMessage: 'Failed to sync weekly plans',
    );
  }

  Future<void> syncMonthly({bool printRawResponse = false}) async {
    await _syncTypedTab<BasePlanModel>(
      tab: HomePlanTab.monthly,
      isInProgress: () => _isMonthlyApiSyncInProgress,
      setInProgress: (value) => _isMonthlyApiSyncInProgress = value,
      load: () => repository.fetchMonthlyPlansFromApi(
        printRawResponse: printRawResponse,
        printFilteredMonthlyPlans: false,
      ),
      itemCount: (plans) => plans.length,
      apply: (base, plans, syncedAt, nextApiTabMeta) => base.copyWith(
        monthlyApiPlans: plans,
        apiTabMeta: nextApiTabMeta,
        monthlyApiLastSyncedAt: syncedAt,
      ),
      unauthenticatedMessage: 'Please login to view monthly plans',
      fallbackErrorMessage: 'Failed to sync monthly plans',
    );
  }

  Future<void> syncRoaming({bool printRawResponse = false}) async {
    await _syncTypedTab<BasePlanModel>(
      tab: HomePlanTab.roaming,
      isInProgress: () => _isRoamingApiSyncInProgress,
      setInProgress: (value) => _isRoamingApiSyncInProgress = value,
      load: () => repository.fetchRoamingPlansFromApi(
        printRawResponse: printRawResponse,
        printFilteredRoamingPlans: false,
      ),
      itemCount: (plans) => plans.length,
      apply: (base, plans, syncedAt, nextApiTabMeta) => base.copyWith(
        roamingApiPlans: plans,
        apiTabMeta: nextApiTabMeta,
        roamingApiLastSyncedAt: syncedAt,
      ),
      unauthenticatedMessage: 'Please login to view roaming plans',
      fallbackErrorMessage: 'Failed to sync roaming plans',
    );
  }

  Future<void> syncRoamEasy({bool printRawResponse = false}) async {
    await _syncTypedTab<BasePlanModel>(
      tab: HomePlanTab.roameasy,
      isInProgress: () => _isRoamEasyApiSyncInProgress,
      setInProgress: (value) => _isRoamEasyApiSyncInProgress = value,
      load: () => repository.fetchRoamEasyPlansFromApi(
        printRawResponse: printRawResponse,
        printFilteredRoamEasyPlans: false,
      ),
      itemCount: (plans) => plans.length,
      apply: (base, plans, syncedAt, nextApiTabMeta) => base.copyWith(
        roamEasyApiPlans: plans,
        apiTabMeta: nextApiTabMeta,
        roamEasyApiLastSyncedAt: syncedAt,
      ),
      unauthenticatedMessage: 'Please login to view RoamEasy plans',
      fallbackErrorMessage: 'Failed to sync RoamEasy plans',
    );
  }

  Future<void> syncMifi({bool printRawResponse = false}) async {
    await _syncTypedTab<BasePlanModel>(
      tab: HomePlanTab.mifi,
      isInProgress: () => _isMifiApiSyncInProgress,
      setInProgress: (value) => _isMifiApiSyncInProgress = value,
      load: () => repository.fetchMifiPlansFromApi(
        printRawResponse: printRawResponse,
        printFilteredMifiPlans: false,
      ),
      itemCount: (plans) => plans.length,
      apply: (base, plans, syncedAt, nextApiTabMeta) => base.copyWith(
        mifiApiPlans: plans,
        apiTabMeta: nextApiTabMeta,
        mifiApiLastSyncedAt: syncedAt,
      ),
      unauthenticatedMessage: 'Please login to view MiFi plans',
      fallbackErrorMessage: 'Failed to sync MiFi plans',
    );
  }

  Future<void> syncLibertyGlobal({bool printRawResponse = false}) async {
    await _syncTypedTab<BasePlanModel>(
      tab: HomePlanTab.libertyGlobal,
      isInProgress: () => _isLibertyGlobalApiSyncInProgress,
      setInProgress: (value) => _isLibertyGlobalApiSyncInProgress = value,
      load: () => repository.fetchLibertyGlobalPlansFromApi(
        printRawResponse: printRawResponse,
        printFilteredLibertyGlobalPlans: false,
      ),
      itemCount: (plans) => plans.length,
      apply: (base, plans, syncedAt, nextApiTabMeta) => base.copyWith(
        libertyGlobalApiPlans: plans,
        apiTabMeta: nextApiTabMeta,
        libertyGlobalApiLastSyncedAt: syncedAt,
      ),
      unauthenticatedMessage: 'Please login to view Liberty Global plans',
      fallbackErrorMessage: 'Failed to sync Liberty Global plans',
    );
  }

  Future<void> syncPostpaidRoaming({bool printRawResponse = false}) async {
    await _syncTypedTab<HomePlansPostPaidPlanModel>(
      tab: HomePlanTab.postpaidRoaming,
      isInProgress: () => _isPostpaidRoamingApiSyncInProgress,
      setInProgress: (value) => _isPostpaidRoamingApiSyncInProgress = value,
      load: () => repository.fetchPostpaidRoamingPlansFromApi(
        printRawResponse: printRawResponse,
      ),
      itemCount: (plans) => plans.length,
      apply: (base, plans, syncedAt, nextApiTabMeta) => base.copyWith(
        postpaidRoamingApiPlans: plans,
        apiTabMeta: nextApiTabMeta,
        postpaidRoamingApiLastSyncedAt: syncedAt,
      ),
      unauthenticatedMessage: 'Please login to view roaming data add-ons',
      fallbackErrorMessage: 'Failed to sync roaming data add-ons',
    );
  }

  void toastConsumed() {
    emit(state.copyWith(clearPendingToast: true));
  }

  Future<void> _loadByTab({
    required HomePlanTab tab,
    bool forceRefresh = false,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔄 _loadByTab called for tab: $tab (forceRefresh: $forceRefresh)',
      );
    }

    try {
      // Check if tab is currently loading - prevent duplicate API calls
      final currentStatus = state.statusFor(tab);
      if (currentStatus == HomePlanStatus.loading) {
        if (kDebugMode) {
          debugPrint('  ⚠️ Tab $tab already loading, skipping');
        }
        return;
      }

      // Check if tab data is already loaded WITH items (skip API call unless forceRefresh)
      // IMPORTANT: A tab is only considered loaded if it has items
      // isLoaded=true with itemCount=0 is likely a stale state or error
      final tabMeta = state.apiTabMeta[tab];
      final isAlreadyLoaded =
          (tabMeta?.isLoaded ?? false) && (tabMeta?.itemCount ?? 0) > 0;

      if (!forceRefresh && isAlreadyLoaded) {
        // Data already exists, just mark as loaded without API call
        if (kDebugMode) {
          debugPrint(
            '  ✅ Tab $tab already loaded (${state.apiTabMeta[tab]?.itemCount} items), skipping API call',
          );
        }
        _emitTabStatus(tab: tab, status: HomePlanStatus.loaded);
        return;
      }

      if (kDebugMode) {
        debugPrint('  📡 Tab $tab: Emitting loading status and scheduling API');
      }
      _emitTabStatus(tab: tab, status: HomePlanStatus.loading);

      if (tab == HomePlanTab.addOns) {
        emit(
          state.copyWith(
            plans: const [],
            addOns: const [],
            selectedAddOnIds: const {},
            addOnsApiPrimaryPlans: const [],
          ),
        );
        _scheduleAddOnsApiSyncIfIdle();
        return;
      }

      // Handle tabs with typed API data - clear both generic plans and typed fields
      // This prevents showing stale data while loading
      switch (tab) {
        case HomePlanTab.daily:
          emit(state.copyWith(plans: const [], dailyApiPlans: const []));
          _scheduleDailyApiSyncIfIdle();
          return;

        case HomePlanTab.weekly:
          emit(state.copyWith(plans: const [], weeklyApiPlans: const []));
          _scheduleWeeklyApiSyncIfIdle();
          return;

        case HomePlanTab.monthly:
          emit(state.copyWith(plans: const [], monthlyApiPlans: const []));
          _scheduleMonthlyApiSyncIfIdle();
          return;

        case HomePlanTab.roaming:
          emit(state.copyWith(plans: const [], roamingApiPlans: const []));
          _scheduleRoamingApiSyncIfIdle();
          return;

        case HomePlanTab.roameasy:
          emit(state.copyWith(plans: const [], roamEasyApiPlans: const []));
          _scheduleRoamEasyApiSyncIfIdle();
          return;

        case HomePlanTab.mifi:
          emit(state.copyWith(plans: const [], mifiApiPlans: const []));
          _scheduleMifiApiSyncIfIdle();
          return;

        case HomePlanTab.libertyGlobal:
          emit(
            state.copyWith(plans: const [], libertyGlobalApiPlans: const []),
          );
          _scheduleLibertyGlobalApiSyncIfIdle();
          return;

        case HomePlanTab.postpaidRoaming:
          emit(
            state.copyWith(plans: const [], postpaidRoamingApiPlans: const []),
          );
          _schedulePostpaidRoamingApiSyncIfIdle();
          return;

        default:
          // This should never happen - all tabs should be handled above
          throw UnimplementedError(
            'Tab $tab is not handled in _loadByTab. '
            'Add a case for this tab or update the implementation.',
          );
      }
    } on BasePlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        tab: tab,
        errorMessage: _buildFriendlyMessageForTab(tab: tab, error: error),
      );
    } catch (_) {
      _emitTabFailureWithToast(tab: tab, errorMessage: 'Failed to load plans');
    }
  }

  Future<void> _syncTypedTab<T>({
    required HomePlanTab tab,
    required bool Function() isInProgress,
    required void Function(bool) setInProgress,
    required Future<List<T>> Function() load,
    required int Function(List<T>) itemCount,
    required HomePlanState Function(
      HomePlanState base,
      List<T> plans,
      DateTime syncedAt,
      Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta,
    )
    apply,
    required String unauthenticatedMessage,
    required String fallbackErrorMessage,
  }) async {
    // Flag may already be set by schedule methods to prevent race condition
    // Don't check it here, just ensure it's set
    if (!isInProgress()) {
      setInProgress(true);
    }

    try {
      if (!globalState.isAuthenticated) {
        _emitTabFailureWithToast(
          tab: tab,
          errorMessage: unauthenticatedMessage,
        );
        return;
      }

      final plans = await load();

      final syncedAt = DateTime.now();
      final nextApiTabMeta = Map<HomePlanTab, HomePlanTabApiMeta>.from(
        state.apiTabMeta,
      );
      nextApiTabMeta[tab] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: itemCount(plans),
        lastSyncedAt: syncedAt,
      );

      final loadedState = _withTabStatus(
        currentState: state,
        tab: tab,
        status: HomePlanStatus.loaded,
      );

      emit(apply(loadedState, plans, syncedAt, nextApiTabMeta));
    } on BasePlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        tab: tab,
        errorMessage: _buildFriendlyMessageForTab(tab: tab, error: error),
      );
    } catch (_) {
      _emitTabFailureWithToast(tab: tab, errorMessage: fallbackErrorMessage);
    } finally {
      setInProgress(false);
    }
  }

  bool _hasInitialPlansLoaded({required UserType userType}) {
    // Check if the DEFAULT tab (shown first) is loaded WITH items
    final defaultTab = _defaultTabForUserType(userType);
    final defaultTabMeta = state.apiTabMeta[defaultTab];
    final defaultTabLoaded =
        (defaultTabMeta?.isLoaded ?? false) &&
        (defaultTabMeta?.itemCount ?? 0) > 0;

    if (kDebugMode) {
      debugPrint('  📊 _hasInitialPlansLoaded check for $userType:');
      debugPrint('     defaultTab: $defaultTab');
      debugPrint(
        '     defaultTabLoaded: $defaultTabLoaded (isLoaded: ${defaultTabMeta?.isLoaded}, itemCount: ${defaultTabMeta?.itemCount})',
      );
    }

    if (userType == UserType.postpaid) {
      // Postpaid only needs default tab
      if (kDebugMode && defaultTabLoaded) {
        debugPrint('     ⚠️ Postpaid tab already loaded, will skip API call');
      }
      return defaultTabLoaded;
    }

    // Prepaid needs BOTH default tab AND add-ons for Dashboard active card.
    // Empty add-ons are still a valid loaded state.
    final addOnsMeta = state.apiTabMeta[HomePlanTab.addOns];
    final addOnsLoaded = addOnsMeta?.isLoaded ?? false;
    final result = defaultTabLoaded && addOnsLoaded;
    if (kDebugMode) {
      debugPrint(
        '     addOnsLoaded: $addOnsLoaded (isLoaded: ${addOnsMeta?.isLoaded}, itemCount: ${addOnsMeta?.itemCount})',
      );
      if (result) {
        debugPrint('     ⚠️ Prepaid tabs already loaded, will skip API call');
      }
    }
    return result;
  }

  /// Check if initial plans are currently loading (in progress)
  /// Checks both state status AND in-progress flags to catch race conditions
  bool _isInitialPlansLoading({required UserType userType}) {
    // Check if the DEFAULT tab (shown first) is loading
    final defaultTab = _defaultTabForUserType(userType);
    final isDefaultTabStatusLoading =
        state.statusFor(defaultTab) == HomePlanStatus.loading;

    // Check in-progress flag for race condition protection
    final isDefaultTabFlagSet = defaultTab == HomePlanTab.postpaidRoaming
        ? _isPostpaidRoamingApiSyncInProgress
        : _isMonthlyApiSyncInProgress; // Monthly is default for prepaid

    final isDefaultTabLoading =
        isDefaultTabStatusLoading || isDefaultTabFlagSet;

    if (userType == UserType.postpaid) {
      // Postpaid only preloads default tab
      return isDefaultTabLoading;
    }

    // Prepaid also preloads add-ons for Dashboard active card
    // Check if add-ons are loading (both state status and in-progress flag)
    final isAddOnsStatusLoading =
        state.statusFor(HomePlanTab.addOns) == HomePlanStatus.loading;
    final isAddOnsFlagSet = _isAddOnsApiSyncInProgress;
    final isAddOnsLoading = isAddOnsStatusLoading || isAddOnsFlagSet;

    // Return true if EITHER default tab OR add-ons are loading
    return isDefaultTabLoading || isAddOnsLoading;
  }

  void _scheduleAddOnsApiSyncIfIdle() {
    if (_isAddOnsApiSyncInProgress) {
      return;
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isAddOnsApiSyncInProgress = true;
    syncAddOns().catchError((_) {
      // Error handling is done inside syncAddOns
      // This catchError prevents unhandled promise rejection
    });
  }

  void _scheduleDailyApiSyncIfIdle() {
    if (_isDailyApiSyncInProgress) {
      return;
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isDailyApiSyncInProgress = true;
    syncDaily().catchError((_) {
      // Error handling is done inside syncDaily
    });
  }

  void _scheduleWeeklyApiSyncIfIdle() {
    if (_isWeeklyApiSyncInProgress) {
      return;
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isWeeklyApiSyncInProgress = true;
    syncWeekly().catchError((_) {
      // Error handling is done inside syncWeekly
    });
  }

  void _scheduleMonthlyApiSyncIfIdle() {
    if (_isMonthlyApiSyncInProgress) {
      return;
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isMonthlyApiSyncInProgress = true;
    syncMonthly().catchError((_) {
      // Error handling is done inside syncMonthly
    });
  }

  void _scheduleRoamingApiSyncIfIdle() {
    if (_isRoamingApiSyncInProgress) {
      return;
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isRoamingApiSyncInProgress = true;
    syncRoaming().catchError((_) {
      // Error handling is done inside syncRoaming
    });
  }

  void _scheduleRoamEasyApiSyncIfIdle() {
    if (_isRoamEasyApiSyncInProgress) {
      return;
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isRoamEasyApiSyncInProgress = true;
    syncRoamEasy().catchError((_) {
      // Error handling is done inside syncRoamEasy
    });
  }

  void _scheduleMifiApiSyncIfIdle() {
    if (_isMifiApiSyncInProgress) {
      return;
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isMifiApiSyncInProgress = true;
    syncMifi().catchError((_) {
      // Error handling is done inside syncMifi
    });
  }

  void _scheduleLibertyGlobalApiSyncIfIdle() {
    if (_isLibertyGlobalApiSyncInProgress) {
      return;
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isLibertyGlobalApiSyncInProgress = true;
    syncLibertyGlobal().catchError((_) {
      // Error handling is done inside syncLibertyGlobal
    });
  }

  void _schedulePostpaidRoamingApiSyncIfIdle() {
    if (_isPostpaidRoamingApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ _schedulePostpaidRoamingApiSyncIfIdle: Already in progress, skipping',
        );
      }
      return;
    }
    if (kDebugMode) {
      debugPrint(
        '🚀 _schedulePostpaidRoamingApiSyncIfIdle: Scheduling postpaid roaming API call',
      );
    }
    // Set flag IMMEDIATELY before async work to prevent race condition
    _isPostpaidRoamingApiSyncInProgress = true;
    syncPostpaidRoaming().catchError((_) {
      // Error handling is done inside syncPostpaidRoaming
    });
  }

  HomePlanTab _defaultTabForUserType(UserType userType) {
    return userType == UserType.postpaid
        ? HomePlanTab.postpaidRoaming
        : HomePlanTab.monthly;
  }

  HomePlanTabUiState _buildTabUiState({
    required HomePlanStatus status,
    String? errorMessage,
  }) {
    final hasError = errorMessage != null && errorMessage.isNotEmpty;
    return HomePlanTabUiState(
      status: status,
      errorMessage: hasError ? errorMessage : null,
    );
  }

  HomePlanState _withTabStatus({
    required HomePlanState currentState,
    required HomePlanTab tab,
    required HomePlanStatus status,
    String? errorMessage,
  }) {
    final nextTabUiState = _buildTabUiState(
      status: status,
      errorMessage: errorMessage,
    );

    switch (tab) {
      case HomePlanTab.daily:
        return currentState.copyWith(dailyTabUiState: nextTabUiState);
      case HomePlanTab.weekly:
        return currentState.copyWith(weeklyTabUiState: nextTabUiState);
      case HomePlanTab.monthly:
        return currentState.copyWith(monthlyTabUiState: nextTabUiState);
      case HomePlanTab.roaming:
        return currentState.copyWith(roamingTabUiState: nextTabUiState);
      case HomePlanTab.roameasy:
        return currentState.copyWith(roameasyTabUiState: nextTabUiState);
      case HomePlanTab.addOns:
        return currentState.copyWith(addOnsTabUiState: nextTabUiState);
      case HomePlanTab.mifi:
        return currentState.copyWith(mifiTabUiState: nextTabUiState);
      case HomePlanTab.libertyGlobal:
        return currentState.copyWith(libertyGlobalTabUiState: nextTabUiState);
      case HomePlanTab.postpaidRoaming:
        return currentState.copyWith(postpaidRoamingTabUiState: nextTabUiState);
    }
  }

  void _emitTabStatus({
    required HomePlanTab tab,
    required HomePlanStatus status,
    String? errorMessage,
  }) {
    emit(
      _withTabStatus(
        currentState: state,
        tab: tab,
        status: status,
        errorMessage: errorMessage,
      ),
    );
  }

  void _emitTabFailureWithToast({
    required HomePlanTab tab,
    required String errorMessage,
  }) {
    final tabFailureState = _withTabStatus(
      currentState: state,
      tab: tab,
      status: HomePlanStatus.failure,
      errorMessage: errorMessage,
    );

    final nextToastId = state.toastSequence + 1;
    final toast = HomePlanToastMessage(
      id: nextToastId,
      tab: tab,
      message: errorMessage,
    );

    emit(
      tabFailureState.copyWith(pendingToast: toast, toastSequence: nextToastId),
    );
  }

  String _buildFriendlyMessageForTab({
    required HomePlanTab tab,
    required BasePlanRepositoryException error,
  }) {
    final tabLabel = _tabFriendlyName(tab);

    switch (error.type) {
      case BasePlanRepositoryErrorType.noInternet:
        return 'No internet connection. Please check and try again.';
      case BasePlanRepositoryErrorType.timeout:
        return '$tabLabel are taking too long. Please try again.';
      case BasePlanRepositoryErrorType.unauthorized:
        return 'Your session expired for $tabLabel. Please login again.';
      case BasePlanRepositoryErrorType.forbidden:
        return 'You do not have access to $tabLabel right now.';
      case BasePlanRepositoryErrorType.notFound:
        return '$tabLabel are not available right now.';
      case BasePlanRepositoryErrorType.server:
        return '$tabLabel are temporarily unavailable. Please try again shortly.';
      case BasePlanRepositoryErrorType.badResponse:
      case BasePlanRepositoryErrorType.parsing:
        return 'We could not read $tabLabel response. Please try again.';
      case BasePlanRepositoryErrorType.unknown:
        return 'Something went wrong while loading $tabLabel.';
    }
  }

  String _tabFriendlyName(HomePlanTab tab) {
    switch (tab) {
      case HomePlanTab.daily:
        return 'Daily plans';
      case HomePlanTab.weekly:
        return 'Weekly plans';
      case HomePlanTab.monthly:
        return 'Monthly plans';
      case HomePlanTab.roaming:
        return 'Roaming plans';
      case HomePlanTab.roameasy:
        return 'RoamEasy plans';
      case HomePlanTab.addOns:
        return 'Add-ons';
      case HomePlanTab.mifi:
        return 'MiFi plans';
      case HomePlanTab.libertyGlobal:
        return 'Liberty Global plans';
      case HomePlanTab.postpaidRoaming:
        return 'Roaming data add-ons';
    }
  }
}
