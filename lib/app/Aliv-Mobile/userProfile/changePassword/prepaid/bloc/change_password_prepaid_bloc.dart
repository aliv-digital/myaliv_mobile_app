import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/change_password_prepaid_repository.dart';
import 'change_password_prepaid_event.dart';
import 'change_password_prepaid_state.dart';

class ChangePasswordPrepaidBloc
    extends Bloc<ChangePasswordPrepaidEvent, ChangePasswordPrepaidState> {
  final ChangePasswordPrepaidRepository repository;

  static const _minLength = 4;
  static const _lengthError = 'password does not meet the requirement';
  static const _matchError = 'password does not match';

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
    emit(state.copyWith(status: ChangePasswordPrepaidStatus.ready));
  }

  void _onNewChanged(
      ChangePasswordPrepaidNewChanged event,
      Emitter<ChangePasswordPrepaidState> emit,
      ) {
    final value = event.value;
    final trimmed = value.trim();

    final newError = (trimmed.isNotEmpty && trimmed.length < _minLength)
        ? _lengthError
        : null;

    final confirmTrimmed = state.confirmPassword.trim();
    final confirmError = confirmTrimmed.isEmpty
        ? null
        : (confirmTrimmed != trimmed ? _matchError : null);

    emit(state.copyWith(
      newPassword: value,
      newPasswordError: newError,
      confirmPasswordError: confirmError,
    ));
  }

  void _onConfirmChanged(
      ChangePasswordPrepaidConfirmChanged event,
      Emitter<ChangePasswordPrepaidState> emit,
      ) {
    final value = event.value;
    final trimmed = value.trim();

    final confirmError = trimmed.isEmpty
        ? null
        : (trimmed != state.newPassword.trim() ? _matchError : null);

    emit(state.copyWith(
      confirmPassword: value,
      confirmPasswordError: confirmError,
    ));
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

    final newErr = a.length < _minLength ? _lengthError : null;
    final confirmErr = b.length < _minLength
        ? _lengthError
        : (a != b ? _matchError : null);

    if (newErr != null || confirmErr != null) {
      emit(state.copyWith(
        status: ChangePasswordPrepaidStatus.ready,
        newPasswordError: newErr,
        confirmPasswordError: confirmErr,
      ));
      return;
    }

    try {
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.submitting));
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
