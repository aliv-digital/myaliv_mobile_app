import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import '../../../../core/localStorage/localStorage.dart';
import '../../../Aliv-Mobile/loginOtp/model/account_info_model.dart';
import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/daily_plan_model.dart';
import '../repository/home_plan_repository.dart';
import 'home_plan_event.dart';
import 'home_plan_state.dart';

class HomePlanBloc extends Bloc<HomePlanEvent, HomePlanState> {
  final HomePlanRepository repository;
  // Prevents duplicate Daily API sync calls when user taps Daily repeatedly.
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
  }

  Future<void> _onStarted(
      HomePlanStarted event, Emitter<HomePlanState> emit) async {
    await _loadByTab(emit, tab: state.selectedTab);
  }

  Future<void> _onTabChanged(
      HomePlanTabChanged event, Emitter<HomePlanState> emit) async {
    // user tab change korle ekhane eshe selected tab load hoy
    emit(state.copyWith(
      selectedTab: event.tab,
      expandedPlanIds: {},
      // tab change e addOns list clean (optional but safe)
      // AddOns tab e gele abar load হবে
      addOns: event.tab == HomePlanTab.addOns ? state.addOns : const [],
      // checked state preserve rakhte chaile eta remove korba na
      // ami safe ভাবে preserve রাখছি
    ));

    await _loadByTab(emit, tab: event.tab);
  }

  void _onToggleExpanded(HomePlanToggleExpanded event, Emitter<HomePlanState> emit) {
    final next = Set<String>.from(state.expandedPlanIds);
    if (next.contains(event.planId)) {
      next.remove(event.planId);
    } else {
      next.add(event.planId);
    }
    emit(state.copyWith(expandedPlanIds: next));
  }

  // optional handlers (kept for pattern consistency)
  void _onViewDetailsPressed(HomePlanViewDetailsPressed event, Emitter<HomePlanState> emit) {}

  void _onPurchaseNowPressed(HomePlanPurchaseNowPressed event, Emitter<HomePlanState> emit) {}

  // ✅ AddOns multi-select toggle
  void _onToggleAddOns(HomePlanToggleAddon event, Emitter<HomePlanState> emit) {
    final next = Set<String>.from(state.selectedAddOnIds);

    // event.addon -> HomePlanAddOnModel (id)
    if (next.contains(event.addon.id)) {
      next.remove(event.addon.id); // uncheck
    } else {
      next.add(event.addon.id); // check
    }

    emit(state.copyWith(selectedAddOnIds: next));
  }

  // ✅ one loader that handles both: plans + addOns
  Future<void> _loadByTab(Emitter<HomePlanState> emit,
      {required HomePlanTab tab}) async {
    try {
      emit(state.copyWith(
        status: HomePlanStatus.loading,
        errorMessage: null,
      ));

      if (tab == HomePlanTab.addOns) {
        // ✅ load addOns instead of plans
        final List<HomePlanAddOnModel> addOns = await repository.fetchAddOns();
        emit(state.copyWith(
          status: HomePlanStatus.loaded,
          addOns: addOns,
          plans: const [], // keep clean
          expandedPlanIds: const {},
        ));
        return;
      }

      // ✅ normal plans
      final List<HomePlanModel> plans = await repository.fetchPlans(tab: tab);

      // Daily special flow:
      // Keep loader active until real Daily API sync is completed.
      // So here we update plans in state but do NOT mark status as loaded yet.
      if (tab == HomePlanTab.daily) {
        emit(state.copyWith(
          plans: plans,
          addOns: const [],
        ));
        _scheduleDailyApiSyncIfIdle();
        return;
      }

      // Other tabs:
      // Complete load immediately with current tab data.
      emit(state.copyWith(
        status: HomePlanStatus.loaded,
        plans: plans,
        addOns: const [], // keep clean
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomePlanStatus.failure,
        errorMessage: 'Failed to load plans',
      ));
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
      // emit(state.copyWith(
      //   status: HomePlanStatus.loading,
      //   errorMessage: null,
      // ));
      final _PlanApiAuthContext? auth = await _readPlanApiAuthContext();
      if (auth == null) {
        if (kDebugMode) {
          debugPrint(
            'daily-api-sync: skipped, missing username/password/deviceAccountID',
          );
        }
        emit(state.copyWith(
          status: HomePlanStatus.failure,
          errorMessage: 'Missing API credentials for daily plans',
        ));
        return;
      }

      final List<DailyPlanModel> dailyPlans =
          await repository.fetchDailyPlansFromApi(
        username: auth.username,
        password: auth.password,
        deviceAccountID: auth.deviceAccountID,
        printRawResponse: event.printRawResponse,
        printFilteredDailyPlans: false,
      );

      final DateTime syncedAt = DateTime.now();
      final Map<HomePlanTab, HomePlanTabApiMeta> nextApiTabMeta =
          Map<HomePlanTab, HomePlanTabApiMeta>.from(state.apiTabMeta);
      nextApiTabMeta[HomePlanTab.daily] = HomePlanTabApiMeta(
        isLoaded: true,
        itemCount: dailyPlans.length,
        lastSyncedAt: syncedAt,
      );
      debugPrint("First Indexed Data : ");
     debugPrint("${dailyPlans[0].planName}");//${dailyPlans[0].toDebugMap()

      emit(state.copyWith(
        status: HomePlanStatus.loaded,
        dailyApiPlans: dailyPlans,
        apiTabMeta: nextApiTabMeta,
        dailyApiLastSyncedAt: syncedAt,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('daily-api-sync: failed with error: $e');
      }
      emit(state.copyWith(
        status: HomePlanStatus.failure,
        errorMessage: 'Failed to sync daily plans',
      ));
    } finally {
      _isDailyApiSyncInProgress = false;
    }
  }

  /// Schedules Daily API sync only when no sync is running.
  ///
  /// This avoids redundant network calls on repeated Daily tab taps.
  void _scheduleDailyApiSyncIfIdle() {
    // Lock ownership stays inside `_onDailyApiSyncRequested`.
    // Scheduler only dispatches the intent event.
    add(HomePlanDailyApiSyncRequested());
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
