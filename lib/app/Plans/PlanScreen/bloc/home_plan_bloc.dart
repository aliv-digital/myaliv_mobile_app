import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import '../../../../core/localStorage/localStorage.dart';
import '../../../Aliv-Mobile/loginOtp/model/account_info_model.dart';
import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/add_ons_primary_plan_model.dart';
import '../models/daily_plan_model.dart';
import '../models/liberty_global_plan_model.dart';
import '../models/mifi_plan_model.dart';
import '../models/monthly_plan_model.dart';
import '../models/roaming_plan_model.dart';
import '../models/roameasy_plan_model.dart';
import '../models/weekly_plan_model.dart';
import '../repository/base_plan_repository.dart';
import '../repository/plan_types.dart';
import '../repository/plan_repository_exception.dart';
import 'home_plan_event.dart';
import 'home_plan_state.dart';

class HomePlanBloc extends Bloc<HomePlanEvent, HomePlanState> {
  final BasePlanRepository repository;

  /// Prevents duplicate Daily API sync calls when user taps Daily repeatedly.
  bool _isDailyApiSyncInProgress = false;

  /// Prevents duplicate Weekly API sync calls when user taps Weekly repeatedly.
  bool _isWeeklyApiSyncInProgress = false;

  /// Prevents duplicate Monthly API sync calls when user taps Monthly repeatedly.
  bool _isMonthlyApiSyncInProgress = false;

  /// Prevents duplicate Roaming API sync calls when user taps Roaming repeatedly.
  bool _isRoamingApiSyncInProgress = false;

  /// Prevents duplicate RoamEasy API sync calls when user taps RoamEasy repeatedly.
  bool _isRoamEasyApiSyncInProgress = false;

  /// Prevents duplicate MiFi API sync calls when user taps MiFi repeatedly.
  bool _isMifiApiSyncInProgress = false;

  /// Prevents duplicate Liberty Global API sync calls when user taps the tab repeatedly.
  bool _isLibertyGlobalApiSyncInProgress = false;

  /// Prevents duplicate Add-ons bundles API sync calls when user taps repeatedly.
  bool _isAddOnsApiSyncInProgress = false;

  HomePlanBloc(this.repository) : super(HomePlanState.initial()) {
    on<HomePlanStarted>(_onStarted);
    on<HomePlanTabChanged>(_onTabChanged);
    on<HomePlanToggleExpanded>(_onToggleExpanded);

    // These 2 are UI action hooks (navigation handled in screen via listener if needed)
    on<HomePlanViewDetailsPressed>(_onViewDetailsPressed);
    on<HomePlanPurchaseNowPressed>(_onPurchaseNowPressed);

    // AddOns toggle
    on<HomePlanToggleAddon>(_onToggleAddOns);
    on<HomePlanAddOnsApiSyncRequested>(_onAddOnsApiSyncRequested);

    // Daily API sync (state-only in current phase)
    on<HomePlanDailyApiSyncRequested>(_onDailyApiSyncRequested);
    on<HomePlanWeeklyApiSyncRequested>(_onWeeklyApiSyncRequested);
    on<HomePlanMonthlyApiSyncRequested>(_onMonthlyApiSyncRequested);
    on<HomePlanRoamingApiSyncRequested>(_onRoamingApiSyncRequested);
    on<HomePlanRoamEasyApiSyncRequested>(_onRoamEasyApiSyncRequested);
    on<HomePlanMifiApiSyncRequested>(_onMifiApiSyncRequested);
    on<HomePlanLibertyGlobalApiSyncRequested>(_onLibertyGlobalApiSyncRequested);
    on<HomePlanToastConsumed>(_onToastConsumed);
  }

  Future<void> _onStarted(
    HomePlanStarted event,
    Emitter<HomePlanState> emit,
  ) async {
    await _loadByTab(emit, tab: state.selectedTab);
  }

  /// Handles tab switch and starts data load for that tab.
  Future<void> _onTabChanged(
    HomePlanTabChanged event,
    Emitter<HomePlanState> emit,
  ) async {
    // If user taps the already-selected tab, keep current state as-is.
    // This prevents unnecessary reloads and repeated API calls.
    if (event.tab == state.selectedTab) {
      return;
    }

    emit(
      state.copyWith(
        selectedTab: event.tab,
        expandedPlanIds: {},
        // Keep AddOns list only when AddOns tab is selected.
        addOns: event.tab == HomePlanTab.addOns ? state.addOns : const [],
      ),
    );

    await _loadByTab(emit, tab: event.tab);
  }

  /// Expands/collapses one plan card.
  void _onToggleExpanded(
    HomePlanToggleExpanded event,
    Emitter<HomePlanState> emit,
  ) {
    final next = Set<String>.from(state.expandedPlanIds);
    if (next.contains(event.planId)) {
      next.remove(event.planId);
    } else {
      next.add(event.planId);
    }
    emit(state.copyWith(expandedPlanIds: next));
  }

  // Optional handlers (kept for pattern consistency).
  void _onViewDetailsPressed(
    HomePlanViewDetailsPressed event,
    Emitter<HomePlanState> emit,
  ) {}

  void _onPurchaseNowPressed(
    HomePlanPurchaseNowPressed event,
    Emitter<HomePlanState> emit,
  ) {}

  /// AddOns multi-select toggle handler.
  void _onToggleAddOns(HomePlanToggleAddon event, Emitter<HomePlanState> emit) {
    final next = Set<String>.from(state.selectedAddOnIds);

    // event.addon => HomePlanAddOnModel (id).
    if (next.contains(event.addon.id)) {
      next.remove(event.addon.id);
    } else {
      next.add(event.addon.id);
    }

    emit(state.copyWith(selectedAddOnIds: next));
  }

  /// Loads data for one tab and updates only that tab's UI state.
  Future<void> _loadByTab(
    Emitter<HomePlanState> emit, {
    required HomePlanTab tab,
  }) async {
    try {
      _emitTabStatus(emit, tab: tab, status: HomePlanStatus.loading);

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

      // Daily/Weekly/Monthly special flow:
      // Keep loader active until the real API sync completes.
      // These tabs already use dedicated API state lists in UI, so we skip
      // the old mock `fetchPlans(...)` path completely.
      if (tab == HomePlanTab.daily ||
          tab == HomePlanTab.weekly ||
          tab == HomePlanTab.monthly ||
          tab == HomePlanTab.roaming ||
          tab == HomePlanTab.roameasy ||
          tab == HomePlanTab.mifi ||
          tab == HomePlanTab.libertyGlobal) {
        emit(state.copyWith(plans: const [], addOns: const []));

        if (tab == HomePlanTab.daily) {
          _scheduleDailyApiSyncIfIdle();
        } else if (tab == HomePlanTab.weekly) {
          _scheduleWeeklyApiSyncIfIdle();
        } else if (tab == HomePlanTab.monthly) {
          _scheduleMonthlyApiSyncIfIdle();
        } else if (tab == HomePlanTab.roaming) {
          _scheduleRoamingApiSyncIfIdle();
        } else if (tab == HomePlanTab.roameasy) {
          _scheduleRoamEasyApiSyncIfIdle();
        } else if (tab == HomePlanTab.mifi) {
          _scheduleMifiApiSyncIfIdle();
        } else {
          _scheduleLibertyGlobalApiSyncIfIdle();
        }
        return;
      }

      // All remaining tabs still load from the existing mock plan source.
      final List<HomePlanModel> plans = await repository.fetchPlans(tab: tab);

      // Non-daily tabs complete immediately.
      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: tab,
        status: HomePlanStatus.loaded,
      ).copyWith(plans: plans, addOns: const []);
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: tab,
        errorMessage: _buildFriendlyMessageForTab(tab: tab, error: error),
      );
    } catch (_) {
      _emitTabFailureWithToast(
        emit,
        tab: tab,
        errorMessage: 'Failed to load plans',
      );
    }
  }

  /// Sync Add-ons bundles API data and store sorted `PrimaryPlans` in state.
  Future<void> _onAddOnsApiSyncRequested(
    HomePlanAddOnsApiSyncRequested event,
    Emitter<HomePlanState> emit,
  ) async {
    if (_isAddOnsApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('add-ons-api-sync: skipped, sync already in progress');
      }
      return;
    }

    _isAddOnsApiSyncInProgress = true;

    try {
      if (!globalState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('add-ons-api-sync: skipped, user not authenticated');
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.addOns,
          errorMessage: 'Please login to view add-ons',
        );
        return;
      }

      final List<AddOnsPrimaryPlanModel> primaryPlans =
          await repository.fetchAddOnsPrimaryPlansFromApi(
        printRawResponse: event.printRawResponse,
        printFilteredPrimaryPlans: false,
      );

      final AddOnsPrimaryPlanModel? selectedPrimaryPlan =
          repository.selectEarliestAddOnsPrimaryPlan(primaryPlans);
      final List<HomePlanAddOnModel> addOns = selectedPrimaryPlan == null
          ? const <HomePlanAddOnModel>[]
          : repository.mapAvailableBoltOnsToUiAddOns(
              primaryPlan: selectedPrimaryPlan,
            );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);

      nextApiTabMeta[HomePlanTab.addOns] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: primaryPlans.length,
        lastSyncedAt: syncedAt,
      );

      final HomePlanState nextState = _withTabStatus(
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
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.addOns,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.addOns,
          error: error,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('add-ons-api-sync: failed with error: $error');
      }
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.addOns,
        errorMessage: 'Failed to sync add-ons bundles',
      );
    } finally {
      _isAddOnsApiSyncInProgress = false;
    }
  }

  /// Sync strict Daily API data and store in state.
  ///
  /// Why separate event:
  /// - keeps `_loadByTab` readable
  /// - avoids mixing demo UI loading with API data preparation
  /// - easy to expand similar events for Weekly/Monthly later
  Future<void> _onDailyApiSyncRequested(
    HomePlanDailyApiSyncRequested event,
    Emitter<HomePlanState> emit,
  ) async {
    // Hard guard:
    // Never allow more than one Daily API sync at a time.
    if (_isDailyApiSyncInProgress) {
      // parallel e jeno just ekta request chole eta korbo pore
      if (kDebugMode) {
        debugPrint('daily-api-sync: skipped, sync already in progress');
      }
      return;
    }

    _isDailyApiSyncInProgress = true;

    try {
      if (!globalState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('daily-api-sync: skipped, user not authenticated');
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.daily,
          errorMessage: 'Please login to view daily plans',
        );
        return;
      }

      final List<DailyPlanModel> dailyPlans =
          await repository.fetchDailyPlansFromApi(
        printRawResponse: event.printRawResponse,
        printFilteredDailyPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);
      // next time etar upor base kore onek kichu kora jabe but ekhon etar currently active use nai
      nextApiTabMeta[HomePlanTab.daily] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: dailyPlans.length,
        lastSyncedAt: syncedAt,
      );
      //if(nextApiTabMeta[HomePlanTab.daily]?.isLoaded == true){

      //}
      // debugPrint("First Indexed Data : ");
      // debugPrint(dailyPlans[0].planName); // ${dailyPlans[0].toDebugMap()

      // Optional debug print to verify first daily plan quickly.
      if (kDebugMode && dailyPlans.isNotEmpty) {
        debugPrint("=========== Daily Plan ==============");
        debugPrint('First Indexed Data :');
        debugPrint(dailyPlans[0].planName);
        debugPrint("last synced : ${state.dailyApiLastSyncedAt}");
      } else if (kDebugMode) {
        debugPrint("dailyPlans.isEmpty");
      }

      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: HomePlanTab.daily,
        status: HomePlanStatus.loaded,
      ).copyWith(
        dailyApiPlans: dailyPlans,
        apiTabMeta: nextApiTabMeta,
        dailyApiLastSyncedAt: syncedAt,
      );
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.daily,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.daily,
          error: error,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('daily-api-sync: failed with error: $e');
      }
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.daily,
        errorMessage: 'Failed to sync daily plans',
      );
    } finally {
      _isDailyApiSyncInProgress = false;
    }
  }

  /// Sync strict Weekly API data and store in state.
  ///
  /// Why separate event:
  /// - keeps `_loadByTab` readable
  /// - avoids mixing demo UI loading with API data preparation
  /// - easy to expand similar events for Monthly and others later
  Future<void> _onWeeklyApiSyncRequested(
    HomePlanWeeklyApiSyncRequested event,
    Emitter<HomePlanState> emit,
  ) async {
    // Hard guard:
    // Never allow more than one Weekly API sync at a time.
    if (_isWeeklyApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('weekly-api-sync: skipped, sync already in progress');
      }
      return;
    }

    _isWeeklyApiSyncInProgress = true;

    try {
      if (!globalState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('weekly-api-sync: skipped, user not authenticated');
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.weekly,
          errorMessage: 'Please login to view weekly plans',
        );
        return;
      }

      final List<WeeklyPlanModel> weeklyPlans = await repository.fetchWeeklyPlansFromApi(
        printRawResponse: event.printRawResponse,
        printFilteredWeeklyPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);

      nextApiTabMeta[HomePlanTab.weekly] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: weeklyPlans.length,
        lastSyncedAt: syncedAt,
      );

      // Optional debug print to verify first weekly plan quickly.
      if (kDebugMode && weeklyPlans.isNotEmpty) {
        debugPrint("=========== Weekly Plan ==============");
        debugPrint('First Weekly Indexed Data :');
        debugPrint(weeklyPlans[0].planName);
        debugPrint("last synced : ${state.weeklyApiLastSyncedAt}");
      } else if (kDebugMode) {
        debugPrint("weeklyPlans.isEmpty");
      }

      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: HomePlanTab.weekly,
        status: HomePlanStatus.loaded,
      ).copyWith(
        weeklyApiPlans: weeklyPlans,
        apiTabMeta: nextApiTabMeta,
        weeklyApiLastSyncedAt: syncedAt,
      );
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.weekly,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.weekly,
          error: error,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('weekly-api-sync: failed with error: $e');
      }
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.weekly,
        errorMessage: 'Failed to sync weekly plans',
      );
    } finally {
      _isWeeklyApiSyncInProgress = false;
    }
  }

  /// Sync strict Monthly API data and store in state.
  ///
  /// Why separate event:
  /// - keeps `_loadByTab` readable
  /// - avoids mixing demo UI loading with API data preparation
  /// - follows the same pattern as Daily and Weekly
  Future<void> _onMonthlyApiSyncRequested(
    HomePlanMonthlyApiSyncRequested event,
    Emitter<HomePlanState> emit,
  ) async {
    // Hard guard:
    // Never allow more than one Monthly API sync at a time.
    if (_isMonthlyApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('monthly-api-sync: skipped, sync already in progress');
      }
      return;
    }

    _isMonthlyApiSyncInProgress = true;

    try {
      if (!globalState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('monthly-api-sync: skipped, user not authenticated');
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.monthly,
          errorMessage: 'Please login to view monthly plans',
        );
        return;
      }

      final List<MonthlyPlanModel> monthlyPlans =
          await repository.fetchMonthlyPlansFromApi(
        printRawResponse: event.printRawResponse,
        printFilteredMonthlyPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);

      nextApiTabMeta[HomePlanTab.monthly] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: monthlyPlans.length,
        lastSyncedAt: syncedAt,
      );

      // Optional debug print to verify first monthly plan quickly.
      if (kDebugMode && monthlyPlans.isNotEmpty) {
        debugPrint("=========== Monthly Plan ==============");
        debugPrint('First Monthly Indexed Data :');
        debugPrint(monthlyPlans[0].planName);
        debugPrint("last synced : ${state.monthlyApiLastSyncedAt}");
      } else if (kDebugMode) {
        debugPrint("monthlyPlans.isEmpty");
      }

      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: HomePlanTab.monthly,
        status: HomePlanStatus.loaded,
      ).copyWith(
        monthlyApiPlans: monthlyPlans,
        apiTabMeta: nextApiTabMeta,
        monthlyApiLastSyncedAt: syncedAt,
      );
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.monthly,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.monthly,
          error: error,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('monthly-api-sync: failed with error: $e');
      }
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.monthly,
        errorMessage: 'Failed to sync monthly plans',
      );
    } finally {
      _isMonthlyApiSyncInProgress = false;
    }
  }

  /// Sync strict Roaming API data and store in state.
  Future<void> _onRoamingApiSyncRequested(
    HomePlanRoamingApiSyncRequested event,
    Emitter<HomePlanState> emit,
  ) async {
    if (_isRoamingApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('roaming-api-sync: skipped, sync already in progress');
      }
      return;
    }

    _isRoamingApiSyncInProgress = true;

    try {
      if (!globalState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('roaming-api-sync: skipped, user not authenticated');
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.roaming,
          errorMessage: 'Please login to view roaming plans',
        );
        return;
      }

      final List<RoamingPlanModel> roamingPlans =
          await repository.fetchRoamingPlansFromApi(
        printRawResponse: event.printRawResponse,
        printFilteredRoamingPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);

      nextApiTabMeta[HomePlanTab.roaming] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: roamingPlans.length,
        lastSyncedAt: syncedAt,
      );

      if (kDebugMode && roamingPlans.isNotEmpty) {
        debugPrint("=========== Roaming Plan ==============");
        debugPrint('First Roaming Indexed Data :');
        debugPrint(roamingPlans[0].planName);
        debugPrint("last synced : ${state.roamingApiLastSyncedAt}");
      } else if (kDebugMode) {
        debugPrint("roamingPlans.isEmpty");
      }

      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: HomePlanTab.roaming,
        status: HomePlanStatus.loaded,
      ).copyWith(
        roamingApiPlans: roamingPlans,
        apiTabMeta: nextApiTabMeta,
        roamingApiLastSyncedAt: syncedAt,
      );
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.roaming,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.roaming,
          error: error,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('roaming-api-sync: failed with error: $e');
      }
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.roaming,
        errorMessage: 'Failed to sync roaming plans',
      );
    } finally {
      _isRoamingApiSyncInProgress = false;
    }
  }

  /// Sync strict RoamEasy API data and store in state.
  Future<void> _onRoamEasyApiSyncRequested(
    HomePlanRoamEasyApiSyncRequested event,
    Emitter<HomePlanState> emit,
  ) async {
    if (_isRoamEasyApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('roameasy-api-sync: skipped, sync already in progress');
      }
      return;
    }

    _isRoamEasyApiSyncInProgress = true;

    try {
      if (!globalState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('roameasy-api-sync: skipped, user not authenticated');
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.roameasy,
          errorMessage: 'Please login to view RoamEasy plans',
        );
        return;
      }

      final List<RoamEasyPlanModel> roamEasyPlans =
          await repository.fetchRoamEasyPlansFromApi(
        printRawResponse: event.printRawResponse,
        printFilteredRoamEasyPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);

      nextApiTabMeta[HomePlanTab.roameasy] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: roamEasyPlans.length,
        lastSyncedAt: syncedAt,
      );

      if (kDebugMode && roamEasyPlans.isNotEmpty) {
        debugPrint("=========== RoamEasy Plan ==============");
        debugPrint('First RoamEasy Indexed Data :');
        debugPrint(roamEasyPlans[0].planName);
        debugPrint("last synced : ${state.roamEasyApiLastSyncedAt}");
      } else if (kDebugMode) {
        debugPrint("roamEasyPlans.isEmpty");
      }

      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: HomePlanTab.roameasy,
        status: HomePlanStatus.loaded,
      ).copyWith(
        roamEasyApiPlans: roamEasyPlans,
        apiTabMeta: nextApiTabMeta,
        roamEasyApiLastSyncedAt: syncedAt,
      );
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.roameasy,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.roameasy,
          error: error,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('roameasy-api-sync: failed with error: $e');
      }
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.roameasy,
        errorMessage: 'Failed to sync RoamEasy plans',
      );
    } finally {
      _isRoamEasyApiSyncInProgress = false;
    }
  }

  /// Sync strict MiFi API data and store in state.
  Future<void> _onMifiApiSyncRequested(
    HomePlanMifiApiSyncRequested event,
    Emitter<HomePlanState> emit,
  ) async {
    if (_isMifiApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('mifi-api-sync: skipped, sync already in progress');
      }
      return;
    }

    _isMifiApiSyncInProgress = true;

    try {
      if (!globalState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint('mifi-api-sync: skipped, user not authenticated');
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.mifi,
          errorMessage: 'Please login to view MiFi plans',
        );
        return;
      }

      final List<MifiPlanModel> mifiPlans =
          await repository.fetchMifiPlansFromApi(
        printRawResponse: event.printRawResponse,
        printFilteredMifiPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);

      nextApiTabMeta[HomePlanTab.mifi] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: mifiPlans.length,
        lastSyncedAt: syncedAt,
      );

      if (kDebugMode && mifiPlans.isNotEmpty) {
        debugPrint("=========== MiFi Plan ==============");
        debugPrint('First MiFi Indexed Data :');
        debugPrint(mifiPlans[0].planName);
        debugPrint("last synced : ${state.mifiApiLastSyncedAt}");
      } else if (kDebugMode) {
        debugPrint("mifiPlans.isEmpty");
      }

      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: HomePlanTab.mifi,
        status: HomePlanStatus.loaded,
      ).copyWith(
        mifiApiPlans: mifiPlans,
        apiTabMeta: nextApiTabMeta,
        mifiApiLastSyncedAt: syncedAt,
      );
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.mifi,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.mifi,
          error: error,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('mifi-api-sync: failed with error: $e');
      }
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.mifi,
        errorMessage: 'Failed to sync MiFi plans',
      );
    } finally {
      _isMifiApiSyncInProgress = false;
    }
  }

  /// Sync strict Liberty Global API data and store in state.
  Future<void> _onLibertyGlobalApiSyncRequested(
    HomePlanLibertyGlobalApiSyncRequested event,
    Emitter<HomePlanState> emit,
  ) async {
    if (_isLibertyGlobalApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint(
          'liberty-global-api-sync: skipped, sync already in progress',
        );
      }
      return;
    }

    _isLibertyGlobalApiSyncInProgress = true;

    try {
      if (!globalState.isAuthenticated) {
        if (kDebugMode) {
          debugPrint(
            'liberty-global-api-sync: skipped, user not authenticated',
          );
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.libertyGlobal,
          errorMessage: 'Please login to view Liberty Global plans',
        );
        return;
      }

      final List<LibertyGlobalPlanModel> libertyGlobalPlans =
          await repository.fetchLibertyGlobalPlansFromApi(
        printRawResponse: event.printRawResponse,
        printFilteredLibertyGlobalPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);

      nextApiTabMeta[HomePlanTab.libertyGlobal] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: libertyGlobalPlans.length,
        lastSyncedAt: syncedAt,
      );

      if (kDebugMode && libertyGlobalPlans.isNotEmpty) {
        debugPrint("=========== Liberty Global Plan ==============");
        debugPrint('First Liberty Global Indexed Data :');
        debugPrint(libertyGlobalPlans[0].planName);
        debugPrint("last synced : ${state.libertyGlobalApiLastSyncedAt}");
      } else if (kDebugMode) {
        debugPrint("libertyGlobalPlans.isEmpty");
      }

      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: HomePlanTab.libertyGlobal,
        status: HomePlanStatus.loaded,
      ).copyWith(
        libertyGlobalApiPlans: libertyGlobalPlans,
        apiTabMeta: nextApiTabMeta,
        libertyGlobalApiLastSyncedAt: syncedAt,
      );
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.libertyGlobal,
        errorMessage: _buildFriendlyMessageForTab(
          tab: HomePlanTab.libertyGlobal,
          error: error,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('liberty-global-api-sync: failed with error: $e');
      }
      _emitTabFailureWithToast(
        emit,
        tab: HomePlanTab.libertyGlobal,
        errorMessage: 'Failed to sync Liberty Global plans',
      );
    } finally {
      _isLibertyGlobalApiSyncInProgress = false;
    }
  }

  /// Clears one-time toast after UI handles it.
  void _onToastConsumed(
    HomePlanToastConsumed event,
    Emitter<HomePlanState> emit,
  ) {
    emit(state.copyWith(clearPendingToast: true));
  }

  /// Schedules Add-ons API sync only when no sync is running.
  void _scheduleAddOnsApiSyncIfIdle() {
    if (_isAddOnsApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('add-ons-api-sync: skipped, sync already in progress');
      }
      return;
    }

    add(HomePlanAddOnsApiSyncRequested());
  }

  /// Schedules Daily API sync only when no sync is running.
  ///
  /// This avoids redundant network calls on repeated Daily tab taps.
  void _scheduleDailyApiSyncIfIdle() {
    if (_isDailyApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('daily-api-sync: skipped, sync already in progress');
      }
      return;
    }

    // Lock ownership stays inside `_onDailyApiSyncRequested`.
    // Scheduler only dispatches the intent event.
    add(HomePlanDailyApiSyncRequested());
  }

  /// Schedules Weekly API sync only when no sync is running.
  ///
  /// This avoids redundant network calls on repeated Weekly tab taps.
  void _scheduleWeeklyApiSyncIfIdle() {
    if (_isWeeklyApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('weekly-api-sync: skipped, sync already in progress');
      }
      return;
    }

    // Lock ownership stays inside `_onWeeklyApiSyncRequested`.
    // Scheduler only dispatches the intent event.
    add(HomePlanWeeklyApiSyncRequested());
  }

  /// Schedules Monthly API sync only when no sync is running.
  ///
  /// This avoids redundant network calls on repeated Monthly tab taps.
  void _scheduleMonthlyApiSyncIfIdle() {
    if (_isMonthlyApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('monthly-api-sync: skipped, sync already in progress');
      }
      return;
    }

    // Lock ownership stays inside `_onMonthlyApiSyncRequested`.
    // Scheduler only dispatches the intent event.
    add(HomePlanMonthlyApiSyncRequested());
  }

  /// Schedules Roaming API sync only when no sync is running.
  void _scheduleRoamingApiSyncIfIdle() {
    if (_isRoamingApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('roaming-api-sync: skipped, sync already in progress');
      }
      return;
    }

    add(HomePlanRoamingApiSyncRequested());
  }

  /// Schedules RoamEasy API sync only when no sync is running.
  void _scheduleRoamEasyApiSyncIfIdle() {
    if (_isRoamEasyApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('roameasy-api-sync: skipped, sync already in progress');
      }
      return;
    }

    add(HomePlanRoamEasyApiSyncRequested());
  }

  /// Schedules MiFi API sync only when no sync is running.
  void _scheduleMifiApiSyncIfIdle() {
    if (_isMifiApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('mifi-api-sync: skipped, sync already in progress');
      }
      return;
    }

    add(HomePlanMifiApiSyncRequested());
  }

  /// Schedules Liberty Global API sync only when no sync is running.
  void _scheduleLibertyGlobalApiSyncIfIdle() {
    if (_isLibertyGlobalApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint(
          'liberty-global-api-sync: skipped, sync already in progress',
        );
      }
      return;
    }

    add(HomePlanLibertyGlobalApiSyncRequested());
  }

  /// Returns one tab UI-state object.
  ///
  /// If `errorMessage` is null/empty, error is cleared.
  HomePlanTabUiState _buildTabUiState({
    required HomePlanStatus status,
    String? errorMessage,
  }) {
    final bool hasError = errorMessage != null && errorMessage.isNotEmpty;
    return HomePlanTabUiState(
      status: status,
      errorMessage: hasError ? errorMessage : null,
    );
  }

  /// Returns a new state with updated UI-state for one specific tab.
  HomePlanState _withTabStatus({
    required HomePlanState currentState,
    required HomePlanTab tab,
    required HomePlanStatus status,
    String? errorMessage,
  }) {
    final HomePlanTabUiState nextTabUiState = _buildTabUiState(
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
    }
  }

  /// Emits one tab status update with optional error.
  void _emitTabStatus(
    Emitter<HomePlanState> emit, {
    required HomePlanTab tab,
    required HomePlanStatus status,
    String? errorMessage,
  }) {
    final HomePlanState nextState = _withTabStatus(
      currentState: state,
      tab: tab,
      status: status,
      errorMessage: errorMessage,
    );
    emit(nextState);
  }

  /// Emits tab failure and one-time toast in one place.
  void _emitTabFailureWithToast(
    Emitter<HomePlanState> emit, {
    required HomePlanTab tab,
    required String errorMessage,
  }) {
    final HomePlanState tabFailureState = _withTabStatus(
      currentState: state,
      tab: tab,
      status: HomePlanStatus.failure,
      errorMessage: errorMessage,
    );

    final int nextToastId = state.toastSequence + 1;
    final HomePlanToastMessage toast = HomePlanToastMessage(
      id: nextToastId,
      tab: tab,
      message: errorMessage,
    );

    emit(
      tabFailureState.copyWith(pendingToast: toast, toastSequence: nextToastId),
    );
  }

  /// Maps typed repository errors to friendly tab-specific text.
  String _buildFriendlyMessageForTab({
    required HomePlanTab tab,
    required PlanRepositoryException error,
  }) {
    final String tabLabel = _tabFriendlyName(tab);

    switch (error.type) {
      case PlanRepositoryErrorType.noInternet:
        return 'No internet connection. Please check and try again.';
      case PlanRepositoryErrorType.timeout:
        return '$tabLabel are taking too long. Please try again.';
      case PlanRepositoryErrorType.unauthorized:
        return 'Your session expired for $tabLabel. Please login again.';
      case PlanRepositoryErrorType.forbidden:
        return 'You do not have access to $tabLabel right now.';
      case PlanRepositoryErrorType.notFound:
        return '$tabLabel are not available right now.';
      case PlanRepositoryErrorType.server:
        return '$tabLabel are temporarily unavailable. Please try again shortly.';
      case PlanRepositoryErrorType.badResponse:
      case PlanRepositoryErrorType.parsing:
        return 'We could not read $tabLabel response. Please try again.';
      case PlanRepositoryErrorType.unknown:
        return 'Something went wrong while loading $tabLabel.';
    }
  }

  /// User-friendly tab titles used inside toast messages.
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
    }
  }

  Future<void> localData() async {
    final map = await LocalStorage.getAccountInfoMap();
    final account = AccountInfoModel.fromJson(map);
    final password = await LocalStorage.getTicket();
    final username = userName; // from core/constants

    final email = account.email;
    final deviceAccountID = account.idAcc; // device account id
    final accountStatus = account.accountStatus;
    final accountType = account.accountType;
    final paymentOption = account.paymentOption;
    debugPrint("Email : $email");
    debugPrint("Account Status : $accountStatus");
    debugPrint("Account Type : $accountType");
    debugPrint("Payment Option : $paymentOption");
    debugPrint("Device Account ID : $deviceAccountID");
    debugPrint("password : $password");
    debugPrint("username : $username");
  }
}
