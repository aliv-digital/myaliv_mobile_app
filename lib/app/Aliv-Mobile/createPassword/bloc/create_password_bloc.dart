import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';
import '../repository/create_password_repository.dart';
import 'create_password_event.dart';
import 'create_password_state.dart';

class CreatePasswordBloc extends Bloc<CreatePasswordEvent, CreatePasswordState> {
  CreatePasswordBloc({required this.repository}) : super(const CreatePasswordState()) {
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmChanged);
    on<TogglePasswordVisibility>(_onTogglePassword);
    on<ToggleConfirmPasswordVisibility>(_onToggleConfirm);
    on<SubmitCreatePassword>(_onSubmit);
  }

  final CreatePasswordRepository repository;

  void _onPasswordChanged(PasswordChanged e, Emitter<CreatePasswordState> emit) {
    final next = state.copyWith(password: e.value, errorMessage: null);
    emit(_validate(next));
  }

  void _onConfirmChanged(ConfirmPasswordChanged e, Emitter<CreatePasswordState> emit) {
    final next = state.copyWith(confirmPassword: e.value, errorMessage: null);
    emit(_validate(next));
  }

  void _onTogglePassword(TogglePasswordVisibility e, Emitter<CreatePasswordState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onToggleConfirm(
      ToggleConfirmPasswordVisibility e,
      Emitter<CreatePasswordState> emit,
      ) {
    emit(state.copyWith(obscureConfirm: !state.obscureConfirm));
  }

  Future<void> _onSubmit(SubmitCreatePassword event,Emitter<CreatePasswordState> emit) async {
    final pass = state.password.trim();
    final confirm = state.confirmPassword.trim();
    if (pass.length < 8) {
      AppUtils.showWarningToast('Password must be at least 8 characters.');
      return;
    }
    if (pass.length > 64) {
      AppUtils.showWarningToast('Password must be 64 characters or fewer.');
      return;
    }
    if (pass != confirm) {
      AppUtils.showWarningToast('Passwords do not match.');
      return;
    }
    emit(state.copyWith(status: CreatePasswordStatus.submitting, errorMessage: null));

    try {
      await repository.createPassword(password: pass);
      emit(state.copyWith(status: CreatePasswordStatus.success));
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Something went wrong. Please try again.';
      emit(state.copyWith(
        status: CreatePasswordStatus.failure,
        errorMessage: message,
      ));
    }
  }

  CreatePasswordState _validate(CreatePasswordState s) {
    if (s.password.isEmpty && s.confirmPassword.isEmpty) {
      return s.copyWith(status: CreatePasswordStatus.initial, errorMessage: null);
    }
    return s.copyWith(
      status: s.canSubmit ? CreatePasswordStatus.valid : CreatePasswordStatus.invalid,
      errorMessage: null,
    );
  }
}
