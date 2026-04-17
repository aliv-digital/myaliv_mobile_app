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
        errorMessage: 'password must be at least 4 characters',
      ));
      return;
    }

    if (a != b) {
      emit(state.copyWith(
        status: ChangePasswordPrepaidStatus.failure,
        errorMessage: 'passwords do not match',
      ));
      return;
    }

    try {
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.submitting, errorMessage: null));
      final success = await repository.changePassword(newPassword: a);

      if (success) {
        emit(state.copyWith(status: ChangePasswordPrepaidStatus.success));
      } else {
        emit(state.copyWith(
          status: ChangePasswordPrepaidStatus.failure,
          errorMessage: 'failed to update password. please try again.',
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: ChangePasswordPrepaidStatus.failure,
        errorMessage: 'failed to update password. please try again.',
      ));
    }
  }
}
