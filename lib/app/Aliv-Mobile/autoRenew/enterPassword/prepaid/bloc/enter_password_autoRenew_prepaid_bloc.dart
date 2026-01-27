import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/enter_password_autoRenew_prepaid_repository.dart';
import 'enter_password_autoRenew_prepaid_event.dart';
import 'enter_password_autoRenew_prepaid_state.dart';

class EnterPasswordAutoRenewPrepaidBloc extends Bloc<
    EnterPasswordAutoRenewPrepaidEvent, EnterPasswordAutoRenewPrepaidState> {
  final EnterPasswordAutoRenewPrepaidRepository repository;

  EnterPasswordAutoRenewPrepaidBloc(this.repository)
      : super(EnterPasswordAutoRenewPrepaidState.initial()) {
    on<EnterPasswordAutoRenewPrepaidStarted>(_onStarted);
    on<EnterPasswordAutoRenewPrepaidBackPressed>(_onBack);
    on<EnterPasswordAutoRenewPrepaidPasswordChanged>(_onPasswordChanged);
    on<EnterPasswordAutoRenewPrepaidToggleObscure>(_onToggle);
    on<EnterPasswordAutoRenewPrepaidContinuePressed>(_onContinue);
    on<EnterPasswordAutoRenewPrepaidFaceIdPressed>(_onFaceId);
    on<EnterPasswordAutoRenewPrepaidFingerprintPressed>(_onFingerprint);
  }

  Future<void> _onStarted(
      EnterPasswordAutoRenewPrepaidStarted event,
      Emitter<EnterPasswordAutoRenewPrepaidState> emit,
      ) async {
    emit(
      state.copyWith(
        status: EnterPasswordAutoRenewPrepaidStatus.ready,
        errorMessage: null,
      ),
    );
  }

  void _onBack(
      EnterPasswordAutoRenewPrepaidBackPressed event,
      Emitter<EnterPasswordAutoRenewPrepaidState> emit,
      ) {
    // navigation handle তুমি screen-level এ করতে পারো
  }

  void _onPasswordChanged(
      EnterPasswordAutoRenewPrepaidPasswordChanged event,
      Emitter<EnterPasswordAutoRenewPrepaidState> emit,
      ) {
    emit(state.copyWith(password: event.value, errorMessage: null));
  }

  void _onToggle(
      EnterPasswordAutoRenewPrepaidToggleObscure event,
      Emitter<EnterPasswordAutoRenewPrepaidState> emit,
      ) {
    emit(state.copyWith(obscure: !state.obscure));
  }

  Future<void> _onContinue(
      EnterPasswordAutoRenewPrepaidContinuePressed event,
      Emitter<EnterPasswordAutoRenewPrepaidState> emit,
      ) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: EnterPasswordAutoRenewPrepaidStatus.failure,
          errorMessage: 'Password required',
        ),
      );
      emit(
        state.copyWith(
          status: EnterPasswordAutoRenewPrepaidStatus.ready,
          errorMessage: null,
        ),
      );
      return;
    }

    try {
      emit(
        state.copyWith(
          status: EnterPasswordAutoRenewPrepaidStatus.submitting,
          errorMessage: null,
        ),
      );

      final ok = await repository.verifyPassword(state.password.trim());

      if (ok) {
        emit(state.copyWith(status: EnterPasswordAutoRenewPrepaidStatus.success));
        emit(state.copyWith(status: EnterPasswordAutoRenewPrepaidStatus.ready));
      } else {
        emit(
          state.copyWith(
            status: EnterPasswordAutoRenewPrepaidStatus.failure,
            errorMessage: 'Invalid password',
          ),
        );
        emit(
          state.copyWith(
            status: EnterPasswordAutoRenewPrepaidStatus.ready,
            errorMessage: null,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: EnterPasswordAutoRenewPrepaidStatus.failure,
          errorMessage: 'Something went wrong',
        ),
      );
      emit(
        state.copyWith(
          status: EnterPasswordAutoRenewPrepaidStatus.ready,
          errorMessage: null,
        ),
      );
    }
  }

  Future<void> _onFaceId(
      EnterPasswordAutoRenewPrepaidFaceIdPressed event,
      Emitter<EnterPasswordAutoRenewPrepaidState> emit,
      ) async {
    // TODO: integrate local_auth later
    await repository.authenticateWithFaceId();
  }

  Future<void> _onFingerprint(
      EnterPasswordAutoRenewPrepaidFingerprintPressed event,
      Emitter<EnterPasswordAutoRenewPrepaidState> emit,
      ) async {
    // TODO: integrate local_auth later
    await repository.authenticateWithFingerprint();
  }
}
