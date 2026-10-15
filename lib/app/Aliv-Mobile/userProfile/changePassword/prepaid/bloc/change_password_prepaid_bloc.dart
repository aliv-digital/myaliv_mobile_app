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
  final bool Function() isAuthorizationCurrent;
  ActionVerifiedResult<ProtectedAccountAction>? _authorization;
  bool _started = false;
  bool _pending = false;
  bool _closing = false;

  static const _minLength = 8;
  static const _maxLength = 64;
  static const _lengthError = 'password does not meet the requirement';
  static const _matchError = 'Passwords do not match. Try again.';

  ChangePasswordPrepaidBloc(
    this.repository, {
    required this.verifyAction,
    required this.cancelVerification,
    required this.isAuthorizationCurrent,
  }) : super(ChangePasswordPrepaidState.initial()) {
    on<ChangePasswordPrepaidStarted>(_onStarted);
    on<ChangePasswordPrepaidAuthorizationInvalidated>(_onInvalidated);
    on<ChangePasswordPrepaidNewChanged>(_onNewChanged);
    on<ChangePasswordPrepaidConfirmChanged>(_onConfirmChanged);
    on<ChangePasswordPrepaidToggleNewVisibility>(_onToggleNew);
    on<ChangePasswordPrepaidToggleConfirmVisibility>(_onToggleConfirm);
    on<ChangePasswordPrepaidSubmitPressed>(_onSubmit);
  }

  Future<void> _onStarted(
    ChangePasswordPrepaidStarted event,
    Emitter<ChangePasswordPrepaidState> emit,
  ) async {
    if (_started || _closing) {
      return;
    }
    _started = true;
    _pending = true;
    emit(state.copyWith(status: ChangePasswordPrepaidStatus.verifying));
    try {
      final attemptId = Object();
      final verified = await verifyAction(attemptId);
      if (_closing || emit.isDone) {
        return;
      }
      if (verified == null ||
          !identical(verified.attemptId, attemptId) ||
          verified.purpose != ProtectedAccountAction.changePassword ||
          !verified.isValid ||
          !isAuthorizationCurrent()) {
        emit(state.copyWith(
            status: ChangePasswordPrepaidStatus.verificationCancelled));
        return;
      }
      // Retain the coordinator-issued capability privately until valid Submit.
      // It is neither route data nor a cached verification flag.
      _authorization = verified;
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.ready));
    } catch (error) {
      if (!_closing && !emit.isDone) {
        emit(state.copyWith(
          status: ChangePasswordPrepaidStatus.verificationCancelled,
          errorMessage: error.toString(),
        ));
      }
    } finally {
      _pending = false;
    }
  }

  void _onInvalidated(
    ChangePasswordPrepaidAuthorizationInvalidated event,
    Emitter<ChangePasswordPrepaidState> emit,
  ) {
    _authorization = null;
    cancelVerification();
    emit(state.copyWith(
        status: ChangePasswordPrepaidStatus.verificationCancelled));
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
    if (_pending ||
        _closing ||
        state.status == ChangePasswordPrepaidStatus.success) {
      return;
    }
    if (_authorization == null || !isAuthorizationCurrent()) {
      _authorization = null;
      emit(state.copyWith(
          status: ChangePasswordPrepaidStatus.verificationCancelled));
      return;
    }
    final a = state.newPassword.trim();
    final b = state.confirmPassword.trim();

    final newErr = a.isEmpty
        ? 'New password is required.'
        : (a.length < _minLength || a.length > _maxLength)
        ? _lengthError
        : null;
    final confirmErr = b.isEmpty
        ? 'Please re-enter your password.'
        : a != b
        ? _matchError
        : (b.length < _minLength || b.length > _maxLength)
        ? _lengthError
        : null;

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
      final verified = _authorization;
      _authorization = null;
      if (verified == null || !verified.consume()) {
        emit(state.copyWith(
            status: ChangePasswordPrepaidStatus.verificationCancelled));
        return;
      }
      emit(state.copyWith(status: ChangePasswordPrepaidStatus.submitting));
      final success = await repository.changePassword(newPassword: a);

      if (_closing ||
          emit.isDone ||
          state.status == ChangePasswordPrepaidStatus.verificationCancelled ||
          !isAuthorizationCurrent()) {
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
      if (_closing ||
          emit.isDone ||
          state.status == ChangePasswordPrepaidStatus.verificationCancelled ||
          !isAuthorizationCurrent()) {
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
    _authorization = null;
    cancelVerification();
    return super.close();
  }
}
