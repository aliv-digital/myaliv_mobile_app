// lib/login/login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repository;

  LoginBloc({required this.repository}) : super(const LoginState()) {
    on<LoginPhoneChanged>((event, emit) {
      emit(state.copyWith(
        phone: event.phone,
        status: LoginStatus.initial,
        errorMessage: null,
        phoneFieldError: false,
      ));
    });

    on<LoginPasswordChanged>((event, emit) {
      emit(state.copyWith(
        password: event.password,
        status: LoginStatus.initial,
        errorMessage: null,
        passwordFieldError: false,
      ));
    });

    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    final isPhoneEmpty = state.phone.trim().isEmpty;
    final isPasswordEmpty = state.password.trim().isEmpty;

    if (isPhoneEmpty || isPasswordEmpty) {
      final validationMessage = isPhoneEmpty && isPasswordEmpty
          ? 'enter phone number and password'
          : isPhoneEmpty
              ? 'enter phone number'
              : 'enter password';

      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: validationMessage,
          phoneFieldError: isPhoneEmpty,
          passwordFieldError: isPasswordEmpty,
        ),
      );
      return;
    }

    emit(state.copyWith(
      status: LoginStatus.loading,
      errorMessage: null,
      phoneFieldError: false,
      passwordFieldError: false,
    ));
    try {
      await repository.login(
        username: state.phone,
        password: state.password,
      );
      emit(state.copyWith(
        status: LoginStatus.success,
        errorMessage: null,
        phoneFieldError: false,
        passwordFieldError: false,
      ));
    } catch (e) {
      final message = _extractErrorMessage(e);
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: message,
          phoneFieldError: false,
          passwordFieldError: false,
        ),
      );
    }
  }

  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
    return raw.trim().isEmpty ? 'invalid credentials!' : raw.trim();
  }
}
