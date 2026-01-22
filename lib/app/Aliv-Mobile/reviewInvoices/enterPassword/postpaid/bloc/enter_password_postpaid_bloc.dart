import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/enter_password_postpaid_repository.dart';
import 'enter_password_postpaid_event.dart';
import 'enter_password_postpaid_state.dart';

class EnterPasswordPostpaidBloc
    extends Bloc<EnterPasswordPostpaidEvent, EnterPasswordPostpaidState> {
  final EnterPasswordPostpaidRepository repository;

  EnterPasswordPostpaidBloc(this.repository)
      : super(EnterPasswordPostpaidState.initial()) {
    on<EnterPasswordPostpaidStarted>(_onStarted);
    on<EnterPasswordPostpaidBackPressed>(_onBack);
    on<EnterPasswordPostpaidPasswordChanged>(_onPasswordChanged);
    on<EnterPasswordPostpaidToggleObscure>(_onToggle);
    on<EnterPasswordPostpaidContinuePressed>(_onContinue);
    on<EnterPasswordPostpaidFaceIdPressed>(_onFaceId);
    on<EnterPasswordPostpaidFingerprintPressed>(_onFingerprint);
  }

  Future<void> _onStarted(
      EnterPasswordPostpaidStarted event,
      Emitter<EnterPasswordPostpaidState> emit,
      ) async {
    emit(
      state.copyWith(
        status: EnterPasswordPostpaidStatus.ready,
        errorMessage: null,
      ),
    );
  }

  void _onBack(
      EnterPasswordPostpaidBackPressed event,
      Emitter<EnterPasswordPostpaidState> emit,
      ) {
    // navigation handle তুমি screen-level এ করতে পারো
  }

  void _onPasswordChanged(
      EnterPasswordPostpaidPasswordChanged event,
      Emitter<EnterPasswordPostpaidState> emit,
      ) {
    emit(state.copyWith(password: event.value, errorMessage: null));
  }

  void _onToggle(
      EnterPasswordPostpaidToggleObscure event,
      Emitter<EnterPasswordPostpaidState> emit,
      ) {
    emit(state.copyWith(obscure: !state.obscure));
  }

  Future<void> _onContinue(
      EnterPasswordPostpaidContinuePressed event,
      Emitter<EnterPasswordPostpaidState> emit,
      ) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: EnterPasswordPostpaidStatus.failure,
          errorMessage: 'Password required',
        ),
      );
      emit(
        state.copyWith(
          status: EnterPasswordPostpaidStatus.ready,
          errorMessage: null,
        ),
      );
      return;
    }

    try {
      emit(
        state.copyWith(
          status: EnterPasswordPostpaidStatus.submitting,
          errorMessage: null,
        ),
      );

      final ok = await repository.verifyPassword(state.password.trim());

      if (ok) {
        emit(state.copyWith(status: EnterPasswordPostpaidStatus.success));
        emit(state.copyWith(status: EnterPasswordPostpaidStatus.ready));
      } else {
        emit(
          state.copyWith(
            status: EnterPasswordPostpaidStatus.failure,
            errorMessage: 'Invalid password',
          ),
        );
        emit(
          state.copyWith(
            status: EnterPasswordPostpaidStatus.ready,
            errorMessage: null,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: EnterPasswordPostpaidStatus.failure,
          errorMessage: 'Something went wrong',
        ),
      );
      emit(
        state.copyWith(
          status: EnterPasswordPostpaidStatus.ready,
          errorMessage: null,
        ),
      );
    }
  }

  Future<void> _onFaceId(
      EnterPasswordPostpaidFaceIdPressed event,
      Emitter<EnterPasswordPostpaidState> emit,
      ) async {
    // TODO: integrate local_auth later
    await repository.authenticateWithFaceId();
  }

  Future<void> _onFingerprint(
      EnterPasswordPostpaidFingerprintPressed event,
      Emitter<EnterPasswordPostpaidState> emit,
      ) async {
    // TODO: integrate local_auth later
    await repository.authenticateWithFingerprint();
  }
}
