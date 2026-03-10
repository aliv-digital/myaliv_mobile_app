import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';
import 'login_otp_event.dart';
import 'login_otp_state.dart';
import '../repository/login_otp_repository.dart';

class LoginOtpBloc extends Bloc<LoginOtpEvent, LoginOtpState> {
  static const int _otpLength = 4;
  final LoginOtpRepository repository;

  LoginOtpBloc({required this.repository,String initialTwoFactorKey = '',String initialPhoneNumber = ''}) :super(
    LoginOtpState( 
      twoFactorKey: initialTwoFactorKey,
      phoneNumber: initialPhoneNumber,
    )){

    on<LoginOtpCodeChanged>((event, emit) {
      emit(state.copyWith(
        code: event.code,
        status: LoginOtpStatus.initial,
        errorType: LoginOtpErrorType.none,
        codeFieldError: false,
        errorMessage: null,
      ));
    });

    on<LoginOtpSubmitted>(_onSubmitted);
    on<LoginOtpResendRequested>(_onResendRequested);
  }

  Future<void> _onSubmitted(LoginOtpSubmitted event,Emitter<LoginOtpState> emit) async {
    final phoneNumber = state.phoneNumber.trim();
    final twoFactorKey = state.twoFactorKey.trim();
    final enteredCode = state.code.trim();

    if (phoneNumber.isEmpty || twoFactorKey.isEmpty) {
      emit(state.copyWith(
        status: LoginOtpStatus.failure,
        errorType: LoginOtpErrorType.missingVerificationContext,
        codeFieldError: false,
        errorMessage: 'Missing verification details. Please login again.',
      ));
      return;
    }

    if (enteredCode.isEmpty) {
      emit(state.copyWith(
        status: LoginOtpStatus.failure,
        errorType: LoginOtpErrorType.emptyCode,
        codeFieldError: true,
        errorMessage: 'Please enter the code',
      ));
      return;
    }

    if (enteredCode.length < _otpLength) {
      emit(state.copyWith(
        status: LoginOtpStatus.failure,
        errorType: LoginOtpErrorType.incompleteCode,
        codeFieldError: true,
        errorMessage: 'Please enter the full code',
      ));
      return;
    }

    final bool isConnected = await InternetConnection().hasInternetAccess;
    if(isConnected == false){
      emit(state.copyWith(
        status: LoginOtpStatus.failure,
        errorType: LoginOtpErrorType.unknown,
        codeFieldError: false,
        errorMessage: 'No Internet Connection',
      ));
      return;
    }


    emit(state.copyWith(
      status: LoginOtpStatus.loading,
      errorType: LoginOtpErrorType.none,
      codeFieldError: false,
      errorMessage: null,
    ));

    try {
      debugPrint("OTP CODE : ${state.code}");
      await repository.verifyCode(
        phoneNumber: phoneNumber,
        twoFactorKey: twoFactorKey,
        pinCode: enteredCode,
      ).then((response) async {

        debugPrint("Ticket : ${response.ticket}");
        debugPrint("Account id : ${response.accountId}");
        await LocalStorage.storeTicket(ticket: response.ticket.toString());
        await LocalStorage.storeAccountID(accountID: response.accountId.toString());
      });


      emit(state.copyWith(
        status: LoginOtpStatus.success,
        errorType: LoginOtpErrorType.none,
        codeFieldError: false,
        errorMessage: null,
      ));
    } catch (e) {
      final message = _extractErrorMessage(e);
      final errorType = _mapErrorTypeFromMessage(message);
      if(message.toString() == "Two Factor P I N Invalid"){
        emit(state.copyWith(
          status: LoginOtpStatus.failure,
          errorType: errorType,
          codeFieldError: _isCodeInputRelatedError(errorType),
          errorMessage: "Invalid OTP",
        ));
      }else{
        emit(state.copyWith(
          status: LoginOtpStatus.failure,
          errorType: errorType,
          codeFieldError: _isCodeInputRelatedError(errorType),
          errorMessage: message,
        ));
      }
    }
  }

  Future<void> _onResendRequested(LoginOtpResendRequested event,Emitter<LoginOtpState> emit) async {
    final phoneNumber = state.phoneNumber.trim();
    final twoFactorKey = state.twoFactorKey.trim();

    if (phoneNumber.isEmpty || twoFactorKey.isEmpty) {
      emit(state.copyWith(
        resendStatus: LoginOtpResendStatus.idle,
        errorMessage: 'Missing verification details. Please login again.',
      ));
      return;
    }

    final bool isConnected = await InternetConnection().hasInternetAccess;
    if(isConnected == false){
      emit(state.copyWith(
        resendStatus: LoginOtpResendStatus.idle,
        errorMessage: 'No Internet Connection',
      ));
      return;
    }


    emit(state.copyWith(
      resendStatus: LoginOtpResendStatus.loading,
      errorMessage: null,
    ));
    try {
      final resendResponse = await repository.resendCode(
        phoneNumber: phoneNumber,
        twoFactorKey: twoFactorKey,
      );
      final updatedKey = resendResponse.key ?? twoFactorKey;
      emit(state.copyWith(
        resendStatus: LoginOtpResendStatus.done,
        // Backend may rotate key on resend; keep state in sync.
        twoFactorKey: updatedKey,
        errorMessage: null,
      ));
      // Reset to idle so future status changes do not re-trigger resend success UI.
      emit(state.copyWith(
        resendStatus: LoginOtpResendStatus.idle,
        twoFactorKey: updatedKey,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        resendStatus: LoginOtpResendStatus.idle,
        errorMessage: _extractErrorMessage(e),
      ));
    }
  }

  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
    final trimmed = raw.trim();
    return trimmed.isEmpty ? 'OTP verification failed. Please try again.' : trimmed;
  }

  LoginOtpErrorType _mapErrorTypeFromMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') ||
        lower.contains('incorrect') ||
        lower.contains('wrong') ||
        lower.contains('failedusernameorpassword') ||
        lower.contains('pin code') ||
        lower.contains('pincode')) {
      return LoginOtpErrorType.invalidCode;
    }
    return LoginOtpErrorType.unknown;
  }

  bool _isCodeInputRelatedError(LoginOtpErrorType type) {
    return type == LoginOtpErrorType.emptyCode ||
        type == LoginOtpErrorType.incompleteCode ||
        type == LoginOtpErrorType.invalidCode;
  }
}
