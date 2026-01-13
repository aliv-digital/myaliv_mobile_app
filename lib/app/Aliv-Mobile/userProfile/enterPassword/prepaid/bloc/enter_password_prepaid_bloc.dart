import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/enter_password_prepaid_repository.dart';
import 'enter_password_prepaid_event.dart';
import 'enter_password_prepaid_state.dart';

class EnterPasswordPrepaidBloc
    extends Bloc<EnterPasswordPrepaidEvent, EnterPasswordPrepaidState> {
  final EnterPasswordPrepaidRepository repository;

  EnterPasswordPrepaidBloc(this.repository)
      : super(EnterPasswordPrepaidState.initial()) {
    on<EnterPasswordPrepaidStarted>(_onStarted);
    on<EnterPasswordPrepaidBackPressed>(_onBack);
    on<EnterPasswordPrepaidPasswordChanged>(_onPasswordChanged);
    on<EnterPasswordPrepaidToggleObscure>(_onToggle);
    on<EnterPasswordPrepaidContinuePressed>(_onContinue);
    on<EnterPasswordPrepaidFaceIdPressed>(_onFaceId);
    on<EnterPasswordPrepaidFingerprintPressed>(_onFingerprint);
  }

  Future<void> _onStarted(
      EnterPasswordPrepaidStarted event,
      Emitter<EnterPasswordPrepaidState> emit,
      ) async {
    emit(state.copyWith(status: EnterPasswordPrepaidStatus.ready, errorMessage: null));
  }

  void _onBack(
      EnterPasswordPrepaidBackPressed event,
      Emitter<EnterPasswordPrepaidState> emit,
      ) {
    // navigation handle তুমি screen-level এ করতে পারো
  }

  void _onPasswordChanged(
      EnterPasswordPrepaidPasswordChanged event,
      Emitter<EnterPasswordPrepaidState> emit,
      ) {
    emit(state.copyWith(password: event.value, errorMessage: null));
  }

  void _onToggle(
      EnterPasswordPrepaidToggleObscure event,
      Emitter<EnterPasswordPrepaidState> emit,
      ) {
    emit(state.copyWith(obscure: !state.obscure));
  }

  Future<void> _onContinue(
      EnterPasswordPrepaidContinuePressed event,
      Emitter<EnterPasswordPrepaidState> emit,
      ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: EnterPasswordPrepaidStatus.failure,
        errorMessage: 'Password required',
      ));
      emit(state.copyWith(status: EnterPasswordPrepaidStatus.ready, errorMessage: null));
      return;
    }

    try {
      emit(state.copyWith(status: EnterPasswordPrepaidStatus.submitting, errorMessage: null));
      final ok = await repository.verifyPassword(state.password.trim());
      if (ok) {
        emit(state.copyWith(status: EnterPasswordPrepaidStatus.success));
        emit(state.copyWith(status: EnterPasswordPrepaidStatus.ready));
      } else {
        emit(state.copyWith(
          status: EnterPasswordPrepaidStatus.failure,
          errorMessage: 'Invalid password',
        ));
        emit(state.copyWith(status: EnterPasswordPrepaidStatus.ready, errorMessage: null));
      }
    } catch (_) {
      emit(state.copyWith(
        status: EnterPasswordPrepaidStatus.failure,
        errorMessage: 'Something went wrong',
      ));
      emit(state.copyWith(status: EnterPasswordPrepaidStatus.ready, errorMessage: null));
    }
  }

  Future<void> _onFaceId(
      EnterPasswordPrepaidFaceIdPressed event,
      Emitter<EnterPasswordPrepaidState> emit,
      ) async {
    // TODO: integrate local_auth later
    await repository.authenticateWithFaceId();
  }

  Future<void> _onFingerprint(
      EnterPasswordPrepaidFingerprintPressed event,
      Emitter<EnterPasswordPrepaidState> emit,
      ) async {
    // TODO: integrate local_auth later
    await repository.authenticateWithFingerprint();
  }
}
