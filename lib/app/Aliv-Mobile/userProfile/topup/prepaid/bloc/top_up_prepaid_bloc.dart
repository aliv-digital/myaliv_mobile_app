import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_limit_left_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/top_up_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/top_up_prepaid_state.dart';

class TopUpPrepaidBloc extends Bloc<TopUpPrepaidEvent, TopUpPrepaidState> {
  final TopUpPrepaidRepository repo;

  TopUpPrepaidBloc({TopUpPrepaidRepository? repo})
      : repo = repo ?? TopUpPrepaidRepository(),
        super(TopUpPrepaidState.initial()) {
    on<TopUpPrepaidStarted>(_onStarted);
    on<TopUpPrepaidTabChanged>(_onTabChanged);
    on<TopUpPrepaidAmountChanged>(_onAmountChanged);
    on<TopUpPrepaidTopUpPressed>(_onTopUpPressed);
    on<TopUpPrepaidLimitRefreshed>(_onLimitRefreshed);
  }

  Future<void> _onStarted(
      TopUpPrepaidStarted event,
      Emitter<TopUpPrepaidState> emit,
      ) async {
    emit(state.copyWith(
      loadStatus: TopUpPrepaidLoadStatus.loading,
      limitFetchFailed: false,
      clearError: true,
    ));

    // Balance + limit run in parallel; a failure in one must not hide the
    // other's result. Both are wrapped in their own try/catch.
    final results = await Future.wait([
      _safeFetchBalance(),
      _safeFetchLimit(),
    ]);

    final balanceResult = results[0] as _BalanceResult;
    final limitResult = results[1] as _LimitResult;

    final loadFailed = balanceResult.failed && limitResult.failed;

    emit(state.copyWith(
      loadStatus: loadFailed
          ? TopUpPrepaidLoadStatus.failure
          : TopUpPrepaidLoadStatus.ready,
      balance: balanceResult.balance ?? state.balance,
      limitLeft: limitResult.data?.limitLeft,
      earliestTopUpDateLocal: limitResult.data?.earliestTopUpDateLocal,
      limitFetchFailed: limitResult.failed,
      errorMessage: loadFailed ? 'Failed to load data' : null,
      clearError: !loadFailed,
    ));
  }

  Future<void> _onLimitRefreshed(
      TopUpPrepaidLimitRefreshed event,
      Emitter<TopUpPrepaidState> emit,
      ) async {
    final result = await _safeFetchLimit();
    emit(state.copyWith(
      limitLeft: result.data?.limitLeft,
      earliestTopUpDateLocal: result.data?.earliestTopUpDateLocal,
      limitFetchFailed: result.failed,
    ));
  }

  Future<_BalanceResult> _safeFetchBalance() async {
    try {
      final balance = await repo.fetchCurrentBalance();
      return _BalanceResult(balance: balance);
    } catch (_) {
      return const _BalanceResult(failed: true);
    }
  }

  Future<_LimitResult> _safeFetchLimit() async {
    try {
      final limit = await repo.fetchTopUpLimitLeft();
      return _LimitResult(data: limit);
    } catch (_) {
      return const _LimitResult(failed: true);
    }
  }

  void _onTabChanged(
      TopUpPrepaidTabChanged event,
      Emitter<TopUpPrepaidState> emit,
      ) {
    // ✅ keep amount/balance, just update selected tab
    emit(state.copyWith(selectedTabIndex: event.index, clearError: true));
  }

  void _onAmountChanged(
      TopUpPrepaidAmountChanged event,
      Emitter<TopUpPrepaidState> emit,
      ) {
    emit(state.copyWith(amountText: event.value, clearError: true));
  }

  Future<void> _onTopUpPressed(
      TopUpPrepaidTopUpPressed event,
      Emitter<TopUpPrepaidState> emit,
      ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(submitStatus: TopUpPrepaidSubmitStatus.loading, clearError: true));
    try {
      await repo.topUp(amount: state.amountValue);
      await instance<AnalyticsService>().logWalletTopUp(
        amount: state.amountValue,
        paymentMethod: 'direct',
      );
      emit(state.copyWith(submitStatus: TopUpPrepaidSubmitStatus.success));
      // optional: reset amount after success
      emit(state.copyWith(submitStatus: TopUpPrepaidSubmitStatus.idle, amountText: '0.00'));
    } catch (_) {
      emit(state.copyWith(
        submitStatus: TopUpPrepaidSubmitStatus.failure,
        errorMessage: 'Top up failed. Try again.',
      ));
    }
  }
}

class _BalanceResult {
  final double? balance;
  final bool failed;
  const _BalanceResult({this.balance, this.failed = false});
}

class _LimitResult {
  final TopUpLimitLeft? data;
  final bool failed;
  const _LimitResult({this.data, this.failed = false});
}
