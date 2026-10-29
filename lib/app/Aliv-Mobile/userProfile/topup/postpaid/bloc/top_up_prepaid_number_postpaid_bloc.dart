import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/logic/top_up_limit_gate.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/send_topup_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_prepaid_repository.dart';

import '../repository/top_up_prepaid_number_postpaid_repository.dart';
import 'top_up_prepaid_number_postpaid_event.dart';
import 'top_up_prepaid_number_postpaid_state.dart';

class TopUpPrepaidNumberPostPaidBloc
    extends
        Bloc<TopUpPrepaidNumberPostPaidEvent, TopUpPrepaidNumberPostPaidState> {
  final TopUpPrepaidNumberPostPaidRepository repo;
  final TopUpPrepaidRepository _topUpRepo;
  final AccountInfoCubit _accountInfoCubit;

  TopUpPrepaidNumberPostPaidBloc({
    TopUpPrepaidNumberPostPaidRepository? repo,
    TopUpPrepaidRepository? topUpRepo,
    AccountInfoCubit? accountInfoCubit,
  }) : repo = repo ?? TopUpPrepaidNumberPostPaidRepository(),
       _topUpRepo = topUpRepo ?? TopUpPrepaidRepository(),
       _accountInfoCubit = accountInfoCubit ?? instance<AccountInfoCubit>(),
       super(TopUpPrepaidNumberPostPaidState.initial()) {
    on<TopUpPrepaidNumberPostPaidStarted>(_onStarted);
    on<TopUpPrepaidNumberPostPaidNumberChanged>(_onNumberChanged);
    on<TopUpPrepaidNumberPostPaidConfirmNumberChanged>(_onConfirmNumberChanged);
    on<TopUpPrepaidNumberPostPaidAmountChanged>(_onAmountChanged);
    on<TopUpPrepaidNumberPostPaidApplyPressed>(_onApplyPressed);
  }

  Future<void> _onStarted(
    TopUpPrepaidNumberPostPaidStarted event,
    Emitter<TopUpPrepaidNumberPostPaidState> emit,
  ) async {
    emit(
      state.copyWith(
        loadStatus: TopUpPrepaidNumberPostPaidLoadStatus.loading,
        clearError: true,
      ),
    );
    // Fetch the 24h limit-left in parallel with the existing 150ms spinner
    // so a transient blocking network call can't delay the screen render.
    final limitFuture = _fetchLimitLeft();
    await Future.delayed(const Duration(milliseconds: 150));
    final limitResult = await limitFuture;
    emit(
      state.copyWith(
        loadStatus: TopUpPrepaidNumberPostPaidLoadStatus.ready,
        limitLeft: limitResult.$1,
        limitFetchFailed: limitResult.$2,
      ),
    );
  }

  Future<(double?, bool)> _fetchLimitLeft() async {
    try {
      final result = await _topUpRepo.fetchTopUpLimitLeft();
      return (result.limitLeft, false);
    } catch (_) {
      return (null, true);
    }
  }

  void _onNumberChanged(
    TopUpPrepaidNumberPostPaidNumberChanged event,
    Emitter<TopUpPrepaidNumberPostPaidState> emit,
  ) {
    emit(
      state.copyWith(
        number: event.value,
        applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle,
        clearError: true,
      ),
    );
  }

  void _onConfirmNumberChanged(
    TopUpPrepaidNumberPostPaidConfirmNumberChanged event,
    Emitter<TopUpPrepaidNumberPostPaidState> emit,
  ) {
    emit(
      state.copyWith(
        confirmNumber: event.value,
        applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle,
        clearError: true,
      ),
    );
  }

  void _onAmountChanged(
    TopUpPrepaidNumberPostPaidAmountChanged event,
    Emitter<TopUpPrepaidNumberPostPaidState> emit,
  ) {
    emit(
      state.copyWith(
        amountText: event.value,
        applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle,
        clearError: true,
        clearAmountInlineError: true,
      ),
    );
  }

  Future<void> _onApplyPressed(
    TopUpPrepaidNumberPostPaidApplyPressed event,
    Emitter<TopUpPrepaidNumberPostPaidState> emit,
  ) async {
    if (!state.canApply) return;

    // Preflight: A/B/C/D limit gate (same semantics as the prepaid My Number
    // tab). TOP-002 min + Case B → inline under the amount box; Case A/C/D →
    // toast. Any block short-circuits before the Gate 0/2/3 network calls.
    final gate = evaluateMyNumberTopUpGate(
      amount: state.amountValue,
      account: _accountInfoCubit.state.accountInfo,
      limitLeft: state.limitLeft,
      limitFetchFailed: state.limitFetchFailed,
    );
    if (gate.blocked) {
      if (gate.isBelowMinimum || gate.isPerTransactionLimit) {
        emit(
          state.copyWith(
            amountInlineError: gate.errorMessage,
            applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.failure,
            errorMessage: gate.errorMessage,
            clearAmountInlineError: true,
          ),
        );
      }
      return;
    }

    emit(
      state.copyWith(
        applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.loading,
        clearError: true,
        clearAmountInlineError: true,
      ),
    );

    try {
      await repo.runGates(
        number: state.numberForApi ?? state.number.trim(),
        amount: state.amountValue,
      );
      emit(
        state.copyWith(
          applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.success,
        ),
      );
    } on TopUpPrepaidNumberException catch (e) {
      emit(
        state.copyWith(
          applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.failure,
          errorMessage: SendTopupRepository.caseDMessage,
        ),
      );
    }
  }
}
