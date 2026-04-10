import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/home_plan_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_ons_primary_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
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
    await _loadByTab(tab: initialTab);
  }

  Future<void> changeTab(HomePlanTab tab) async {
    if (tab == state.selectedTab) {
      return;
    }

    emit(
      state.copyWith(
        selectedTab: tab,
        expandedPlanIds: {},
      ),
    );

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

  Future<void> loadInitialPlans({
    bool forceRefresh = false,
    required UserType userType,
  }) async {
    if (!globalState.isAuthenticated) {
      return;
    }

    // Check if plans are currently loading - prevent duplicate API calls
    if (_isInitialPlansLoading(userType: userType)) {
      return;
    }

    // Check if plans are already loaded - skip unless forceRefresh
    if (!forceRefresh && _hasInitialPlansLoaded(userType: userType)) {
      return;
    }

    // Note: Don't emit loading state here - this is background preloading
    // UI loading states are managed by _loadByTab() via started() and changeTab()

    // Preload the DEFAULT tab that will be shown first
    final defaultTab = _defaultTabForUserType(userType);

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

    // For prepaid: Also preload add-ons for Dashboard active card
    // Safe to run in parallel - different endpoint (bundles vs available-plans)
    if (userType == UserType.prepaid) {
      _scheduleAddOnsApiSyncIfIdle();
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

      final List<AddOnsPrimaryPlanModel> primaryPlans = await repository
          .fetchAddOnsPrimaryPlansFromApi(
            printRawResponse: printRawResponse,
            printFilteredPrimaryPlans: false,
          );

      final AddOnsPrimaryPlanModel? selectedPrimaryPlan = repository
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
    await _syncTypedTab<DailyPlanModel>(
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
    await _syncTypedTab<WeeklyPlanModel>(
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
    await _syncTypedTab<MonthlyPlanModel>(
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
    await _syncTypedTab<RoamingPlanModel>(
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
    await _syncTypedTab<RoamEasyPlanModel>(
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
    await _syncTypedTab<MifiPlanModel>(
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
    await _syncTypedTab<LibertyGlobalPlanModel>(
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
    try {
      // Check if tab is currently loading - prevent duplicate API calls
      final currentStatus = state.statusFor(tab);
      if (currentStatus == HomePlanStatus.loading) {
        return;
      }

      // Check if tab data is already loaded (skip API call unless forceRefresh)
      final isAlreadyLoaded = state.apiTabMeta[tab]?.isLoaded ?? false;

      if (!forceRefresh && isAlreadyLoaded) {
        // Data already exists, just mark as loaded without API call
        _emitTabStatus(tab: tab, status: HomePlanStatus.loaded);
        return;
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

      if (tab == HomePlanTab.daily ||
          tab == HomePlanTab.weekly ||
          tab == HomePlanTab.monthly ||
          tab == HomePlanTab.roaming ||
          tab == HomePlanTab.roameasy ||
          tab == HomePlanTab.mifi ||
          tab == HomePlanTab.libertyGlobal ||
          tab == HomePlanTab.postpaidRoaming) {
        emit(state.copyWith(plans: const []));

        switch (tab) {
          case HomePlanTab.daily:
            _scheduleDailyApiSyncIfIdle();
            break;
          case HomePlanTab.weekly:
            _scheduleWeeklyApiSyncIfIdle();
            break;
          case HomePlanTab.monthly:
            _scheduleMonthlyApiSyncIfIdle();
            break;
          case HomePlanTab.roaming:
            _scheduleRoamingApiSyncIfIdle();
            break;
          case HomePlanTab.roameasy:
            _scheduleRoamEasyApiSyncIfIdle();
            break;
          case HomePlanTab.mifi:
            _scheduleMifiApiSyncIfIdle();
            break;
          case HomePlanTab.libertyGlobal:
            _scheduleLibertyGlobalApiSyncIfIdle();
            break;
          case HomePlanTab.postpaidRoaming:
            _schedulePostpaidRoamingApiSyncIfIdle();
            break;
          case HomePlanTab.addOns:
            break;
        }
        return;
      }

      final plans = await repository.fetchPlans(tab: tab);
      emit(
        _withTabStatus(
          currentState: state,
          tab: tab,
          status: HomePlanStatus.loaded,
        ).copyWith(plans: plans),
      );
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
    // Check if the DEFAULT tab (shown first) is loaded
    final defaultTab = _defaultTabForUserType(userType);
    final defaultTabLoaded = state.apiTabMeta[defaultTab]?.isLoaded ?? false;

    if (userType == UserType.postpaid) {
      // Postpaid only needs default tab
      return defaultTabLoaded;
    }

    // Prepaid needs BOTH default tab AND add-ons for Dashboard active card
    final addOnsLoaded = state.apiTabMeta[HomePlanTab.addOns]?.isLoaded ?? false;
    return defaultTabLoaded && addOnsLoaded;
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

    final isDefaultTabLoading = isDefaultTabStatusLoading || isDefaultTabFlagSet;

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
      return;
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
