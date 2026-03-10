// lib/login/login_bloc.dart
import 'package:flutter/material.dart';
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
        twoFactorKey: null,
        phoneFieldError: false,
      ));
    });

    on<LoginPasswordChanged>((event, emit) {
      emit(state.copyWith(
        password: event.password,
        status: LoginStatus.initial,
        errorMessage: null,
        twoFactorKey: null,
        passwordFieldError: false,
      ));
    });

    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    final isPhoneEmpty = state.phone.trim().isEmpty;
    final isPasswordEmpty = state.password.trim().isEmpty;

    if (isPhoneEmpty || isPasswordEmpty) {
      final String validationMessage;
      if (isPhoneEmpty && isPasswordEmpty) {
        validationMessage = 'enter phone number and password';
      } else if (isPhoneEmpty) {
        validationMessage = 'enter phone number';
      } else {
        validationMessage = 'enter password';
      }

      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: validationMessage,
          twoFactorKey: null,
          phoneFieldError: isPhoneEmpty,
          passwordFieldError: isPasswordEmpty,
        ),
      );
      return;
    }

    emit(state.copyWith(
      status: LoginStatus.loading,
      errorMessage: null,
      twoFactorKey: null,
      phoneFieldError: false,
      passwordFieldError: false,
    ));
    try {
      final authResponse = await repository.login(
        username: state.phone,
        password: state.password,
      );

      emit(state.copyWith(
        status: LoginStatus.success,
        errorMessage: null,
        twoFactorKey: authResponse.twoFactorKey,
        phoneFieldError: false,
        passwordFieldError: false,
      ));
    } catch (e) {
      final message = _extractErrorMessage(e);
      debugPrint('Login error: $message, $e');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: message,
          twoFactorKey: null,
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

// trying with wrong credentials : FailedUsernameOrPassword | status code : 401

// after trying with wrong credentials so many times ,
// error message : FailedUsernameIsLocked | status code : 401

/*
if invalid phone number like "f*74#2@" or short digits then response :
 status Code : 400,
 body: {
  "ErrorCode":95000,
  "ErrorCodeName":"FailedSimpleValidation",
  "Message":"Failed Simple Validation",
  "Errors":
    {
      "request.Username":["Must be a 7 or 10 digit phone number."]},
      "Detail":null
    }
 */
