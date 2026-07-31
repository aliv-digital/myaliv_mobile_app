import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_frequency.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/models/plan_categorization_result.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'plans_state.dart';

const List<String> _excludedPlanNames = [
  '3gb bonus roaming data us/can',
  '1.5gb bonus roaming data us/can',
  '750mb bonus roaming data',
  'bmp 1-day',
  'bmp 7-day',
  'bmp 30-day',
  'liberty bonus data2',
  'freedom bonus data5',
  'freedom35 bonus data5',
  'freedom4 bonus data2',
  'junkanoo5',
  'test',
];

/// Cubit for managing plan data with HydratedBloc persistence.
///
/// Behaviour:
/// - First launch: loading → fetch → success (cached to disk).
/// - Subsequent launches: cached data shown immediately (status: success),
///   then a silent background refresh runs if cache is stale (> 1 hour).
/// - Pull-to-refresh: status switches to `refreshing` so cached UI stays
///   visible while fresh data loads.
/// - Logout: reset() wipes the disk cache so the next user starts clean.
class PlansCubit extends HydratedCubit<PlansState> {
  PlansCubit({PlansRepository? repository})
      : _repository = repository ?? PlansRepository(),
        super(const PlansState());

  // HydratedBloc storage key = "$runtimeType$id" → "PlansCubit_v1".
  // Explicit suffix prevents collision if the class is ever renamed.
  // Bump suffix (v2, v3…) if PlansState shape changes incompatibly.
  @override
  String get id => '_v1';

  final PlansRepository _repository;

  bool _isFetching = false;
  // Set when a forceRefresh call arrives while a fetch is in-flight.
  // The in-flight fetch will re-run with forceRefresh once it finishes.
  bool _pendingForceRefresh = false;

  // ─── Public API ──────────────────────────────────────────────────────────

  Future<void> started({
    required UserType userType,
    HomePlanTab? initialTab,
  }) async {
    final tab = initialTab ?? _defaultTabForUserType(userType);

    if (state.selectedTab != tab) {
      emit(state.copyWith(selectedTab: tab, expandedPlanIds: const {}));
    }

    if (!globalState.isAuthenticated) return;

    if (!state.hasData) {
      await _fetchAllPlans();
      return;
    }

    // Cache is warm — trigger silent background refresh if stale.
    if (_shouldRefresh()) {
      // Fire-and-forget: UI keeps showing cached data while fetch runs.
      // catchError suppresses unhandled-future warnings and handles
      // the edge case where the cubit is closed before the fetch completes.
      _fetchAllPlans().catchError((_) {});
    }
  }

  Future<void> changeTab(HomePlanTab tab) async {
    if (tab == state.selectedTab) return;

    emit(state.copyWith(
      selectedTab: tab,
      expandedPlanIds: const {},
      selectedAddOnIds: const <String>{},
    ));
  }

  void clearSelectedAddOns() {
    if (state.selectedAddOnIds.isEmpty) return;
    emit(state.copyWith(selectedAddOnIds: const <String>{}));
  }

  Future<void> refreshCurrentTab() async {
    await _fetchAllPlans(forceRefresh: true);
  }

  /// Post-purchase refresh — fetches only /bundles to check whether the
  /// new plan is active yet. Skips /available-plans because the purchasable
  /// plan catalogue does not change as a result of a purchase.
  Future<void> refreshBundlesOnly() async {
    if (_isFetching) {
      _pendingForceRefresh = true;
      return;
    }
    _isFetching = true;
    emit(state.copyWith(isRefreshingBundles: true));

    try {
      final addOnsResult = await _repository.fetchAddOnsData(forceRefresh: true);

      if (isClosed) return;

      emit(state.copyWith(
        addOns: addOnsResult.addOns,
        addOnsApiPrimaryPlans: addOnsResult.primaryPlans,
        secondaryPlans: addOnsResult.secondaryPlans,
        standAlonePlans: addOnsResult.standAlonePlans,
        addOnsApiLastSyncedAt: DateTime.now(),
        errorMessage: null,
        isRefreshingBundles: false,
        clearOptimisticActivePlan: _shouldClearOptimisticPlan(
          state.optimisticActivePlan,
          addOnsResult.primaryPlans,
        ),
        clearOptimisticSecondaryPlans: _shouldClearOptimisticSecondaryPlans(
          state.optimisticSecondaryPlans,
          addOnsResult.secondaryPlans,
        ),
      ));
    } catch (_) {
      // Silently ignore — the optimistic plan stays visible and the next
      // background refresh will retry.
      if (!isClosed) emit(state.copyWith(isRefreshingBundles: false));
    } finally {
      _isFetching = false;
      if (_pendingForceRefresh) {
        _pendingForceRefresh = false;
        _fetchAllPlans(forceRefresh: true).catchError((_) {});
      }
    }
  }

  /// Optimistically marks [plan] as the active plan immediately after a
  /// successful purchase, before the real /bundles refresh returns.
  ///
  /// [purchasedAt] is the moment of purchase — used as the start date.
  /// The expire date is estimated from the plan's billing frequency:
  ///   D → +1 day · W → +7 days · M → +1 calendar month
  /// Plans with unknown frequency (roaming, mifi, etc.) leave the expire
  /// date empty so the card shows '--/--' until the real data arrives.
  ///
  /// The injected plan is cleared automatically when the next real
  /// /bundles success emit lands — see [_fetchAllPlans].
  void injectOptimisticActivePlan({
    required BasePlanModel plan,
    required DateTime purchasedAt,
  }) {
    final startUtc = purchasedAt.toUtc();
    final frequency = PlanFrequency.parse(plan.frequency);
    final endUtc = _estimateEndDate(startUtc, frequency);

    emit(state.copyWith(
      optimisticActivePlan: plan.copyWith(
        startDate: _toApiDateString(startUtc),
        endDate: endUtc != null ? _toApiDateString(endUtc) : '',
      ),
    ));
  }

  /// Combined optimistic injection for a primary-plan purchase.
  ///
  /// Sets the optimistic active plan AND replaces the secondary plan view with
  /// [addOns] (empty list if no add-ons were bought). This prevents the old
  /// plan's add-ons from appearing in "active add-ons" after switching plans,
  /// because [PlansState.effectiveSecondaryPlans] suppresses real
  /// [secondaryPlans] while [optimisticActivePlan] is pending.
  ///
  /// Use [injectOptimisticSecondaryPlans] for add-on-only purchases where the
  /// primary plan has not changed.
  void injectOptimisticPrimaryPlanChange({
    required BasePlanModel plan,
    required List<BasePlanModel> addOns,
    required DateTime purchasedAt,
  }) {
    final startUtc = purchasedAt.toUtc();
    final frequency = PlanFrequency.parse(plan.frequency);
    final endUtc = _estimateEndDate(startUtc, frequency);
    final startTag = _toApiDateString(startUtc);

    final injectedPrimary = plan.copyWith(
      startDate: startTag,
      endDate: endUtc != null ? _toApiDateString(endUtc) : '',
    );
    final injectedSecondary = addOns
        .map((p) => p.copyWith(startDate: startTag))
        .toList(growable: false);

    emit(state.copyWith(
      optimisticActivePlan: injectedPrimary,
      optimisticSecondaryPlans: injectedSecondary,
    ));
  }

  /// Optimistically marks [plans] as active secondary plans immediately after
  /// a successful add-on purchase, before the real /bundles refresh returns.
  ///
  /// [purchasedAt] is stamped onto [startDate] of each plan — this timestamp
  /// is used by [_shouldClearOptimisticSecondaryPlans] as the injection time
  /// for the safety-valve TTL check, mirroring [injectOptimisticActivePlan].
  void injectOptimisticSecondaryPlans({
    required List<BasePlanModel> plans,
    required DateTime purchasedAt,
  }) {
    if (plans.isEmpty) return;
    final startTag = _toApiDateString(purchasedAt.toUtc());
    final injected = plans
        .map((p) => p.copyWith(startDate: startTag))
        .toList(growable: false);
    emit(state.copyWith(optimisticSecondaryPlans: injected));
  }

  // ─── Optimistic-plan helpers ─────────────────────────────────────────────

  /// How long to keep showing an optimistic plan when /bundles hasn't
  /// confirmed it yet. Acts as a safety valve against stale optimistic state
  /// if the backend never returns the plan (e.g. silent purchase failure).
  static const _optimisticPlanMaxAge = Duration(seconds: 30);

  /// Returns true if [optimistic] should be replaced by real [newPrimaryPlans].
  ///
  /// Clears when:
  ///   1. No optimistic plan is set (nothing to protect).
  ///   2. /bundles confirmed the plan — its [planId] appears in [newPrimaryPlans].
  ///   3. Safety valve — the optimistic plan is older than [_optimisticPlanMaxAge].
  ///      We use [BasePlanModel.startDateTime] as the injection timestamp because
  ///      [injectOptimisticActivePlan] sets startDate to the purchase moment.
  static bool _shouldClearOptimisticPlan(
    OptimisticActivePlan? optimistic,
    List<BasePlanModel> newPrimaryPlans,
  ) {
    if (optimistic == null) return true;

    // /bundles confirmed our plan — safe to replace with real data.
    if (newPrimaryPlans.any((p) => p.planId == optimistic.planId)) return true;

    // Empty bundles means the backend is still processing the purchase.
    // Keep showing the optimistic plan until a non-empty response arrives.
    if (newPrimaryPlans.isEmpty) return false;

    // /bundles returned plans but ours isn't among them — unexpected.
    // Apply the safety valve to avoid showing stale data indefinitely.
    final injectedAt = optimistic.startDateTime;
    if (injectedAt != null &&
        DateTime.now().difference(injectedAt) > _optimisticPlanMaxAge) {
      return true;
    }

    return false;
  }

  /// Mirrors [_shouldClearOptimisticPlan] for secondary plans.
  ///
  /// Clears when:
  ///   1. No optimistic secondary plans are set.
  ///   2. All injected plan IDs appear in [newSecondaryPlans] (confirmed).
  ///   3. Safety valve — the oldest injected plan exceeds [_optimisticPlanMaxAge].
  ///
  /// Keeps showing optimistic data when [newSecondaryPlans] is empty —
  /// the backend is still processing the purchase.
  static bool _shouldClearOptimisticSecondaryPlans(
    List<BasePlanModel> optimistic,
    List<BasePlanModel> newSecondaryPlans,
  ) {
    if (optimistic.isEmpty) return true;

    if (optimistic.every(
      (p) => newSecondaryPlans.any((n) => n.planId == p.planId),
    )) { return true; }

    if (newSecondaryPlans.isEmpty) return false;

    final injectedAt = optimistic.first.startDateTime;
    if (injectedAt != null &&
        DateTime.now().difference(injectedAt) > _optimisticPlanMaxAge) {
      return true;
    }

    return false;
  }

  static final _apiDateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Formats a UTC [DateTime] into the ISO string the backend uses.
  /// The trailing 'Z' ensures [parseApiDate] treats it as UTC.
  static String _toApiDateString(DateTime utcDateTime) =>
      '${_apiDateFormat.format(utcDateTime)}Z';

  /// Returns the estimated plan end date based on billing [frequency].
  /// Returns null for frequencies that don't map to a fixed duration
  /// (roaming, mifi, liberty-global, etc.).
  static DateTime? _estimateEndDate(DateTime start, PlanFrequency? frequency) {
    switch (frequency) {
      case PlanFrequency.daily:
        return start.add(const Duration(days: 1));
      case PlanFrequency.weekly:
        return start.add(const Duration(days: 7));
      case PlanFrequency.monthly:
        return DateTime.utc(
          start.year,
          start.month + 1,
          start.day,
          start.hour,
          start.minute,
          start.second,
        );
      case null:
        return null;
    }
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

  void toggleAddon(HomePlanAddOnModel addOn) {
    final next = Set<String>.from(state.selectedAddOnIds);
    if (next.contains(addOn.id)) {
      next.remove(addOn.id);
    } else {
      next.add(addOn.id);
    }
    emit(state.copyWith(selectedAddOnIds: next));
  }

  void purchaseNowPressed(HomePlanModel plan) {
    if (!state.isPurchaseModalOpen) {
      emit(state.copyWith(isPurchaseModalOpen: true));
    }
  }

  void purchaseModalClosed() {
    emit(state.copyWith(isPurchaseModalOpen: false));
  }

  void toastConsumed() {
    emit(state.copyWith(clearPendingToast: true));
  }

  /// Clears in-memory state and wipes the HydratedBloc disk cache.
  /// Called on logout to ensure the next user starts from a clean slate.
  void reset() {
    _isFetching = false;
    _pendingForceRefresh = false;
    emit(const PlansState()); // HydratedBloc auto-persists the empty state

    if (kDebugMode) {
      debugPrint('✅ PlansCubit.reset(): State and cache cleared');
    }
  }

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

    // Fresh cache: nothing to do.
    if (!forceRefresh && state.hasData && !_shouldRefresh()) {
      if (kDebugMode) {
        debugPrint('⚠️ loadInitialPlans: Cache fresh, skipping');
      }
      return;
    }

    await _fetchAllPlans(forceRefresh: forceRefresh);
  }

  // ─── HydratedCubit ───────────────────────────────────────────────────────

  @override
  PlansState? fromJson(Map<String, dynamic> json) {
    try {
      return PlansState.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ PlansCubit.fromJson: Failed to restore cache - $e');
      }
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PlansState state) {
    // Skip writes while a fetch is in-flight — keeps the previous cache intact
    // so a crash mid-fetch doesn't wipe the disk.
    // All other states (success, failure, initial) are written, including the
    // empty PlansState() emitted by reset() — this is what clears the old
    // user's cached plans from disk on logout.
    if (state.isLoading || state.isRefreshing) return null;
    try {
      return state.toJson();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ PlansCubit.toJson: Failed to serialize cache - $e');
      }
      return null;
    }
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<void> _fetchAllPlans({bool forceRefresh = false}) async {
    if (_isFetching) {
      if (forceRefresh) _pendingForceRefresh = true;
      if (kDebugMode) {
        debugPrint(
          '⚠️ PlansCubit: Already fetching${forceRefresh ? ', queued forceRefresh' : ', skipping'}',
        );
      }
      return;
    }
    _pendingForceRefresh = false;

    if (!forceRefresh && state.hasData && !_shouldRefresh()) {
      if (kDebugMode) {
        debugPrint('⚠️ PlansCubit: Data fresh, skipping fetch');
      }
      return;
    }

    _isFetching = true;
    final hadDataBefore = state.hasData;

    // Keep cached data visible during a background refresh.
    emit(state.copyWith(
      status: hadDataBefore ? PlansStatus.refreshing : PlansStatus.loading,
      errorMessage: null,
    ));

    if (kDebugMode) {
      debugPrint(
        '🔄 PlansCubit: Fetching all plans (${hadDataBefore ? "silent refresh" : "initial load"})...',
      );
    }

    try {
      // Start both requests concurrently.
      final plansFuture = _repository.fetchCategorizedPlans(
        forceRefresh: forceRefresh,
      );
      final bundlesFuture = _repository.fetchAddOnsData(
        forceRefresh: forceRefresh,
      );

      // Emit bundles data as soon as it arrives so the active plan card is
      // visible immediately, without waiting for the slower available-plans
      // response. The status stays loading/refreshing until both complete.
      bundlesFuture.then((addOnsResult) {
        if (isClosed) return;
        emit(state.copyWith(
          addOns: addOnsResult.addOns,
          addOnsApiPrimaryPlans: addOnsResult.primaryPlans,
          secondaryPlans: addOnsResult.secondaryPlans,
          standAlonePlans: addOnsResult.standAlonePlans,
          addOnsApiLastSyncedAt: DateTime.now(),
          clearOptimisticActivePlan: _shouldClearOptimisticPlan(
            state.optimisticActivePlan,
            addOnsResult.primaryPlans,
          ),
          clearOptimisticSecondaryPlans: _shouldClearOptimisticSecondaryPlans(
            state.optimisticSecondaryPlans,
            addOnsResult.secondaryPlans,
          ),
        ));
      }).catchError((_) {});

      final results = await Future.wait([plansFuture, bundlesFuture]);

      if (isClosed) return;

      final plansResult = results[0] as PlanCategorizationResult;
      final addOnsResult = results[1] as AddOnsResult;
      final now = DateTime.now();

      emit(state.copyWith(
        status: PlansStatus.success,
        dailyApiPlans: _filterBase(plansResult.dailyPlans),
        weeklyApiPlans: _filterBase(plansResult.weeklyPlans),
        monthlyApiPlans: _filterBase(plansResult.monthlyPlans),
        roamingApiPlans: _filterBase(plansResult.roamingPlans),
        roamEasyApiPlans: _filterBase(plansResult.roamEasyPlans),
        mifiApiPlans: _filterBase(plansResult.mifiPlans),
        libertyGlobalApiPlans: _filterBase(plansResult.libertyGlobalPlans),
        postpaidRoamingApiPlans: _filterPostpaid(plansResult.postpaidRoamingPlans),
        addOns: addOnsResult.addOns,
        addOnsApiPrimaryPlans: addOnsResult.primaryPlans,
        secondaryPlans: addOnsResult.secondaryPlans,
        standAlonePlans: addOnsResult.standAlonePlans,
        lastFetchedAt: now,
        addOnsApiLastSyncedAt: now,
        errorMessage: null,
        clearOptimisticActivePlan: _shouldClearOptimisticPlan(
          state.optimisticActivePlan,
          addOnsResult.primaryPlans,
        ),
        clearOptimisticSecondaryPlans: _shouldClearOptimisticSecondaryPlans(
          state.optimisticSecondaryPlans,
          addOnsResult.secondaryPlans,
        ),
      ));
    } catch (e) {
      final errorMsg = _friendlyErrorMessage(e);

      if (kDebugMode) {
        debugPrint('❌ PlansCubit: Error fetching plans - $e');
      }

      if (hadDataBefore) {
        // Keep cached data visible; show toast only.
        final nextId = state.toastSequence + 1;
        emit(state.copyWith(
          status: PlansStatus.success,
          pendingToast: PlansToastMessage(id: nextId, message: errorMsg),
          toastSequence: nextId,
        ));
      } else {
        _emitFailureWithToast(errorMsg);
      }
    } finally {
      _isFetching = false;
      if (_pendingForceRefresh) {
        _pendingForceRefresh = false;
        _fetchAllPlans(forceRefresh: true).catchError((_) {});
      }
    }
  }

  void _emitFailureWithToast(String errorMessage) {
    final nextId = state.toastSequence + 1;
    emit(state.copyWith(
      status: PlansStatus.failure,
      errorMessage: errorMessage,
      pendingToast: PlansToastMessage(id: nextId, message: errorMessage),
      toastSequence: nextId,
    ));
  }

  HomePlanTab _defaultTabForUserType(UserType userType) {
    return userType == UserType.postpaid
        ? HomePlanTab.postpaidRoaming
        : HomePlanTab.monthly;
  }

  bool _shouldRefresh() {
    if (state.lastFetchedAt == null) return true;
    return DateTime.now().difference(state.lastFetchedAt!) >
        const Duration(hours: 0);
  }

  bool _isExcludedPlanName(String name) {
    final lower = name.toLowerCase();
    return _excludedPlanNames.any(lower.contains);
  }

  List<BasePlanModel> _filterBase(List<BasePlanModel> plans) =>
      plans.where((p) => !_isExcludedPlanName(p.planName)).toList();

  List<HomePlansPostPaidPlanModel> _filterPostpaid(
    List<HomePlansPostPaidPlanModel> plans,
  ) =>
      plans.where((p) => !_isExcludedPlanName(p.planName)).toList();

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
