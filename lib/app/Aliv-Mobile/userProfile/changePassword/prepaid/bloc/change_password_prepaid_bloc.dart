import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/change_password_prepaid_repository.dart';
import 'change_password_prepaid_event.dart';
import 'change_password_prepaid_state.dart';

class ChangePasswordPrepaidBloc
    extends Bloc<ChangePasswordPrepaidEvent, ChangePasswordPrepaidState> {
  final ChangePasswordPrepaidRepository repository;

  ChangePasswordPrepaidBloc(this.repository)
      : super(ChangePasswordPrepaidState.initial()) {
    on<ChangePasswordPrepaidStarted>(_onStarted);
    on<ChangePasswordPrepaidNewChanged>(_onNewChanged);
    on<ChangePasswordPrepaidConfirmChanged>(_onConfirmChanged);
    on<ChangePasswordPrepaidToggleNewVisibility>(_onToggleNew);
    on<ChangePasswordPrepaidToggleConfirmVisibility>(_onToggleConfirm);
    on<ChangePasswordPrepaidSubmitPressed>(_onSubmit);
  }

  void _onStarted(
      ChangePasswordPrepaidStarted event,
      Emitter<ChangePasswordPrepaidState> emit,
      ) {
    emit(state.copyWith(status: ChangePasswordPrepaidStatus.ready, errorMessage: null));
  }

  void _onNewChanged(
      ChangePasswordPrepaidNewChanged event,
      Emitter<ChangePasswordPrepaidState> emit,
      ) {
    emit(state.copyWith(newPassword: event.value, errorMessage: null));
  }

  void _onConfirmChanged(
      ChangePasswordPrepaidConfirmChanged event,
      Emitter<ChangePasswordPrepaidState> emit,
      ) {
    emit(state.copyWith(confirmPassword: event.value, errorMessage: null));
  }

  void _onToggleNew(
      ChangePasswordPrepaidToggleNewVisibility event,
      Emitter<ChangePasswordPrepaidState> emit,
      ) {
    emit(state.copyWith(obscureNew: !state.obscureNew));
  }

  void _onToggleConfirm(
      ChangePasswordPrepaidToggleConfirmVisibility event,
      Emitter<ChangePasswordPrepaidState> emit,
      ) {
    emit(state.copyWith(obscureConfirm: !state.obscureConfirm));
  }

  Future<void> _onSubmit(
      ChangePasswordPrepaidSubmitPressed event,
      Emitter<ChangePasswordPrepaidState> emit,
      ) async {
    final a = state.newPassword.trim();
    final b = state.confirmPassword.trim();

    if (a.length < 4 || b.length < 4) {
      emit(state.copyWith(
        status: ChangePasswordPrepaidStatus.failure,
        errorMessage: 'Password must be at least 4 characters',
      ));
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.ready, errorMessage: null));
      return;
    }

    if (a != b) {
      emit(state.copyWith(
        status: ChangePasswordPrepaidStatus.failure,
        errorMessage: 'Passwords do not match',
      ));
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.ready, errorMessage: null));
      return;
    }

    try {
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.submitting, errorMessage: null));
      await repository.changePassword(newPassword: a);
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.success));
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.ready));
    } catch (_) {
      emit(state.copyWith(
        status: ChangePasswordPrepaidStatus.failure,
        errorMessage: 'Something went wrong',
      ));
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.ready, errorMessage: null));
    }
  }
}
