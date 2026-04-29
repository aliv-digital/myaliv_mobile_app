// lib/login/login_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../repository/auth_repository.dart';
import '../utils/login_phone_number_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repository;
  final LoginPhoneNumberHelper phoneNumberHelper;

  LoginBloc({
    required this.repository,
    LoginPhoneNumberHelper? phoneNumberHelper,
  })  : phoneNumberHelper = phoneNumberHelper ?? const LoginPhoneNumberHelper(),
        super(const LoginState()) {
    on<LoginPhoneChanged>((event, emit) {
      emit(state.copyWith(
        phone: event.phone,
        status: LoginStatus.initial,
        errorMessage: null,
        twoFactorKey: null,
        apiPhoneNumber: null,
        phoneFieldError: false,
      ));
    });

    on<LoginPasswordChanged>((event, emit) {
      emit(state.copyWith(
        password: event.password,
        status: LoginStatus.initial,
        errorMessage: null,
        twoFactorKey: null,
        apiPhoneNumber: null,
        passwordFieldError: false,
      ));
    });

    on<LoginCountryChanged>((event, emit) {
      emit(state.copyWith(
        selectedCountry: event.selectedCountry,
        status: LoginStatus.initial,
        errorMessage: null,
        twoFactorKey: null,
        apiPhoneNumber: null,
        phoneFieldError: false,
      ));
    });

    on<LoginSubmitted>(_onSubmitted);
  }

  /// Emits failure state.
  ///
  /// Local validation errors stay inline in the form and should not trigger a
  /// toast. Backend/API failures can opt-in to bumping `errorToastId`, which is
  /// what the UI listener watches before showing a toast.
  void _emitFailure(
    Emitter<LoginState> emit, {
    required String message,
    required bool phoneFieldError,
    required bool passwordFieldError,
    bool showToast = false,
  }) {
    emit(
      state.copyWith(
        status: LoginStatus.failure,
        errorMessage: message,
        twoFactorKey: null,
        apiPhoneNumber: null,
        phoneFieldError: phoneFieldError,
        passwordFieldError: passwordFieldError,
        errorToastId: showToast ? state.errorToastId + 1 : state.errorToastId,
      ),
    );
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    final isPhoneEmpty = state.phone.trim().isEmpty;
    final isPasswordEmpty = state.password.trim().isEmpty;

    if (isPhoneEmpty || isPasswordEmpty) {
      final String validationMessage;
      if (isPhoneEmpty && isPasswordEmpty) {
        validationMessage = 'enter phone number and password';
      } else if (isPhoneEmpty) {
        validationMessage = 'phone number is required';
      } else {
        validationMessage = 'password is required';
      }
      _emitFailure(
        emit,
        message: validationMessage,
        phoneFieldError: isPhoneEmpty,
        passwordFieldError: isPasswordEmpty,
      );
      return;
    }
    final LoginPhoneValidationResult phoneValidationResult =
        phoneNumberHelper.validateAndBuildApiUsername(
      rawPhoneNumber: state.phone,
      selectedCountry: state.selectedCountry,
    );

    if (!phoneValidationResult.isValid ||
        phoneValidationResult.phoneNumberForApi == null) {
      _emitFailure(
        emit,
        message: phoneValidationResult.errorMessage ??
            LoginPhoneNumberHelper.invalidPhoneNumberMessage,
        phoneFieldError: true,
        passwordFieldError: false,
      );
      return;
    }
    final bool isConnected = await InternetConnection().hasInternetAccess;
    if (isConnected == false) {
      _emitFailure(
        emit,
        message: 'No Internet Connection',
        phoneFieldError: false,
        passwordFieldError: false,
        showToast: true,
      );
      return;
    }

    emit(state.copyWith(
      status: LoginStatus.loading,
      errorMessage: null,
      twoFactorKey: null,
      apiPhoneNumber: null,
      phoneFieldError: false,
      passwordFieldError: false,
    ));

    try {
      final authResponse = await repository.login(
        username: phoneValidationResult.phoneNumberForApi!,
        password: state.password,
      );

      emit(state.copyWith(
        status: LoginStatus.success,
        errorMessage: null,
        twoFactorKey: authResponse.twoFactorKey,
        apiPhoneNumber: phoneValidationResult.phoneNumberForApi,
        phoneFieldError: false,
        passwordFieldError: false,
      ));
    } catch (e) {
      final message = _extractErrorMessage(e);
      debugPrint('Login error: $message, $e');
      if (message.toString() == "FailedSimpleValidation") {
        _emitFailure(
          emit,
          message: 'The number you entered is invalid',
          phoneFieldError: false,
          passwordFieldError: false,
          showToast: true,
        );
      } else if (message.toString() == "FailedUsernameIsLocked") {
        _emitFailure(
          emit,
          message: "your account is locked out, please try again in 15 minutes",
          phoneFieldError: false,
          passwordFieldError: false,
          showToast: true,
        );
      } else {
        _emitFailure(
          emit,
          message: message,
          phoneFieldError: false,
          passwordFieldError: false,
          showToast: true,
        );
      }
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
