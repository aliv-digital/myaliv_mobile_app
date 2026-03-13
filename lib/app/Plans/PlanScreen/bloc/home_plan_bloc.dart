import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import '../../../../core/localStorage/localStorage.dart';
import '../../../Aliv-Mobile/loginOtp/model/account_info_model.dart';
import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/daily_plan_model.dart';
import '../repository/home_plan_repository.dart';
import '../repository/plan_repository_exception.dart';
import 'home_plan_event.dart';
import 'home_plan_state.dart';

class HomePlanBloc extends Bloc<HomePlanEvent, HomePlanState> {
  final HomePlanRepository repository;

  /// Prevents duplicate Daily API sync calls when user taps Daily repeatedly.
  bool _isDailyApiSyncInProgress = false;

  HomePlanBloc(this.repository) : super(HomePlanState.initial()) {
    on<HomePlanStarted>(_onStarted);
    on<HomePlanTabChanged>(_onTabChanged);
    on<HomePlanToggleExpanded>(_onToggleExpanded);

    // These 2 are UI action hooks (navigation handled in screen via listener if needed)
    on<HomePlanViewDetailsPressed>(_onViewDetailsPressed);
    on<HomePlanPurchaseNowPressed>(_onPurchaseNowPressed);

    // AddOns toggle
    on<HomePlanToggleAddon>(_onToggleAddOns);

    // Daily API sync (state-only in current phase)
    on<HomePlanDailyApiSyncRequested>(_onDailyApiSyncRequested);
    on<HomePlanToastConsumed>(_onToastConsumed);
  }

  Future<void> _onStarted(
      HomePlanStarted event, Emitter<HomePlanState> emit) async {
    await _loadByTab(emit, tab: state.selectedTab);
  }

  /// Handles tab switch and starts data load for that tab.
  Future<void> _onTabChanged(HomePlanTabChanged event, Emitter<HomePlanState> emit) async {
    emit(state.copyWith(
      selectedTab: event.tab,
      expandedPlanIds: {},
      // Keep AddOns list only when AddOns tab is selected.
      addOns: event.tab == HomePlanTab.addOns ? state.addOns : const [],
    ));

    await _loadByTab(emit, tab: event.tab);
  }

  /// Expands/collapses one plan card.
  void _onToggleExpanded(
      HomePlanToggleExpanded event, Emitter<HomePlanState> emit) {
    final next = Set<String>.from(state.expandedPlanIds);
    if (next.contains(event.planId)) {
      next.remove(event.planId);
    } else {
      next.add(event.planId);
    }
    emit(state.copyWith(expandedPlanIds: next));
  }

  // Optional handlers (kept for pattern consistency).
  void _onViewDetailsPressed(HomePlanViewDetailsPressed event, Emitter<HomePlanState> emit) {}

  void _onPurchaseNowPressed(HomePlanPurchaseNowPressed event, Emitter<HomePlanState> emit) {}

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
  Future<void> _loadByTab(Emitter<HomePlanState> emit,
      {required HomePlanTab tab}) async {
    try {
      _emitTabStatus(
        emit,
        tab: tab,
        status: HomePlanStatus.loading,
      );

      if (tab == HomePlanTab.addOns) {
        // AddOns tab loads AddOns list.
        final List<HomePlanAddOnModel> addOns = await repository.fetchAddOns();
        final HomePlanState nextState = _withTabStatus(
          currentState: state,
          tab: tab,
          status: HomePlanStatus.loaded,
        ).copyWith(
          addOns: addOns,
          plans: const [],
          expandedPlanIds: const {},
        );
        emit(nextState);
        return;
      }

      // All other tabs load plan list.
      final List<HomePlanModel> plans = await repository.fetchPlans(tab: tab);

      // Daily special flow:
      // Keep daily loader active until Daily API sync completes.
      if (tab == HomePlanTab.daily) {
        emit(state.copyWith(
          plans: plans,
          addOns: const [],
        ));
        _scheduleDailyApiSyncIfIdle();
        return;
      }

      // Non-daily tabs complete immediately.
      final HomePlanState nextState = _withTabStatus(
        currentState: state,
        tab: tab,
        status: HomePlanStatus.loaded,
      ).copyWith(
        plans: plans,
        addOns: const [],
      );
      emit(nextState);
    } on PlanRepositoryException catch (error) {
      _emitTabFailureWithToast(
        emit,
        tab: tab,
        errorMessage: _buildFriendlyMessageForTab(
          tab: tab,
          error: error,
        ),
      );
    } catch (_) {
      _emitTabFailureWithToast(
        emit,
        tab: tab,
        errorMessage: 'Failed to load plans',
      );
    }
  }

  /// Sync strict Daily API data and store in state.
  ///
  /// Why separate event:
  /// - keeps `_loadByTab` readable
  /// - avoids mixing demo UI loading with API data preparation
  /// - easy to expand similar events for Weekly/Monthly later
  Future<void> _onDailyApiSyncRequested(HomePlanDailyApiSyncRequested event, Emitter<HomePlanState> emit) async {
    // Hard guard:
    // Never allow more than one Daily API sync at a time.
    if (_isDailyApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint('daily-api-sync: skipped, sync already in progress');
      }
      return;
    }

    _isDailyApiSyncInProgress = true;

    try {
      final _PlanApiAuthContext? auth = await _readPlanApiAuthContext();
      if (auth == null) {
        if (kDebugMode) {
          debugPrint(
            'daily-api-sync: skipped, missing username/password/deviceAccountID',
          );
        }
        _emitTabFailureWithToast(
          emit,
          tab: HomePlanTab.daily,
          errorMessage:
              'Daily plans are unavailable right now. Please login again.',
        );
        return;
      }

      final List<DailyPlanModel> dailyPlans = await repository.fetchDailyPlansFromApi(
        username: auth.username,
        password: auth.password,
        deviceAccountID: auth.deviceAccountID,
        printRawResponse: event.printRawResponse,
        printFilteredDailyPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta = Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);
      // next time etar upor base kore onek kichu kora jabe but ekhon etar currently active use nai
      nextApiTabMeta[HomePlanTab.daily] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: dailyPlans.length,
        lastSyncedAt: syncedAt,
      );
      //if(nextApiTabMeta[HomePlanTab.daily]?.isLoaded == true){

      //}
      debugPrint("First Indexed Data : ");
      debugPrint("${dailyPlans[0].planName}");//${dailyPlans[0].toDebugMap()
      debugPrint("last synced : ${state.dailyApiLastSyncedAt}");
      // Optional debug print to verify first daily plan quickly.
      if (kDebugMode && dailyPlans.isNotEmpty) {
        debugPrint('First Indexed Data :');
        debugPrint(dailyPlans[0].planName);
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

  /// Clears one-time toast after UI handles it.
  void _onToastConsumed(
    HomePlanToastConsumed event,
    Emitter<HomePlanState> emit,
  ) {
    emit(state.copyWith(clearPendingToast: true));
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

    emit(tabFailureState.copyWith(
      pendingToast: toast,
      toastSequence: nextToastId,
    ));
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

  // we need this as authorization token to fetch data
  Future<_PlanApiAuthContext?> _readPlanApiAuthContext() async {
    final Map<String, dynamic> map = await LocalStorage.getAccountInfoMap();
    final AccountInfoModel account = AccountInfoModel.fromJson(map);
    final String? password = await LocalStorage.getTicket();
    final String username = AppConstants.userName;
    final String deviceAccountID = account.idAcc.toString();

    final bool invalidPassword = password == null || password.isEmpty;
    final bool invalidUsername = username.isEmpty;
    final bool invalidDeviceAccountID =
        account.idAcc <= 0 || deviceAccountID.isEmpty;

    if (invalidPassword || invalidUsername || invalidDeviceAccountID) {
      return null;
    }

    return _PlanApiAuthContext(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
    );
  }

  Future<void> localData() async {
    final map = await LocalStorage.getAccountInfoMap();
    final account = AccountInfoModel.fromJson(map);
    final password = await LocalStorage.getTicket();
    final username = AppConstants.userName;

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

class _PlanApiAuthContext {
  const _PlanApiAuthContext({
    required this.username,
    required this.password,
    required this.deviceAccountID,
  });

  final String username;
  final String password;
  final String deviceAccountID;
}
