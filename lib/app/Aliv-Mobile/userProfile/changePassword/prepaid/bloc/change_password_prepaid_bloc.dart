import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import '../repository/change_password_prepaid_repository.dart';
import 'change_password_prepaid_event.dart';
import 'change_password_prepaid_state.dart';

class ChangePasswordPrepaidBloc
    extends Bloc<ChangePasswordPrepaidEvent, ChangePasswordPrepaidState> {
  final ChangePasswordPrepaidRepository repository;
  final Future<ActionVerifiedResult<ProtectedAccountAction>?> Function(Object)
  verifyAction;
  final void Function() cancelVerification;
  bool _pending = false;
  bool _closing = false;

  static const _minLength = 8;
  static const _maxLength = 64;
  static const _lengthError = 'password does not meet the requirement';
  static const _matchError = 'password does not match';

  ChangePasswordPrepaidBloc(
    this.repository, {
    required this.verifyAction,
    required this.cancelVerification,
  }) : super(ChangePasswordPrepaidState.initial()) {
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

    final newError =
        (trimmed.isNotEmpty &&
            (trimmed.length < _minLength || trimmed.length > _maxLength))
        ? _lengthError
        : null;

    final confirmTrimmed = state.confirmPassword.trim();
    final confirmError = confirmTrimmed.isEmpty
        ? null
        : (confirmTrimmed != trimmed ? _matchError : null);

    emit(
      state.copyWith(
        newPassword: value,
        newPasswordError: newError,
        confirmPasswordError: confirmError,
      ),
    );
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

    emit(
      state.copyWith(
        confirmPassword: value,
        confirmPasswordError: confirmError,
      ),
    );
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
    if (_pending || _closing) {
      return;
    }
    final a = state.newPassword.trim();
    final b = state.confirmPassword.trim();

    final newErr = (a.length < _minLength || a.length > _maxLength)
        ? _lengthError
        : null;
    final confirmErr = (b.length < _minLength || b.length > _maxLength)
        ? _lengthError
        : (a != b ? _matchError : null);

    if (newErr != null || confirmErr != null) {
      emit(
        state.copyWith(
          status: ChangePasswordPrepaidStatus.ready,
          newPasswordError: newErr,
          confirmPasswordError: confirmErr,
        ),
      );
      return;
    }

    _pending = true;
    try {
      final attemptId = Object();
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.verifying));
      final verified = await verifyAction(attemptId);
      if (_closing || emit.isDone) {
        return;
      }
      if (verified == null ||
          !identical(verified.attemptId, attemptId) ||
          verified.purpose != ProtectedAccountAction.changePassword ||
          state.newPassword.trim() != a ||
          state.confirmPassword.trim() != b ||
          !verified.consume()) {
        emit(state.copyWith(status: ChangePasswordPrepaidStatus.ready));
        return;
      }
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.submitting));
      final success = await repository.changePassword(newPassword: a);

      if (_closing || emit.isDone) {
        return;
      }

      if (success) {
        emit(state.copyWith(status: ChangePasswordPrepaidStatus.success));
      } else {
        emit(
          state.copyWith(
            status: ChangePasswordPrepaidStatus.failure,
            errorMessage: 'failed to update password. please try again.',
          ),
        );
      }
    } catch (_) {
      if (_closing || emit.isDone) {
        return;
      }
      emit(
        state.copyWith(
          status: ChangePasswordPrepaidStatus.failure,
          errorMessage: 'failed to update password. please try again.',
        ),
      );
    } finally {
      _pending = false;
    }
  }

  @override
  Future<void> close() {
    _closing = true;
    cancelVerification();
    return super.close();
  }
}
