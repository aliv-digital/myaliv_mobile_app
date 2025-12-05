import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_otp_event.dart';
import 'login_otp_state.dart';
import '../repository/login_otp_repository.dart';

class LoginOtpBloc extends Bloc<LoginOtpEvent, LoginOtpState> {
  final LoginOtpRepository repository;

  LoginOtpBloc({required this.repository}) : super(const LoginOtpState()) {
    on<LoginOtpCodeChanged>((event, emit) {
      emit(state.copyWith(
        code: event.code,
        status: LoginOtpStatus.initial,
        errorMessage: null,
      ));
    });

    on<LoginOtpSubmitted>(_onSubmitted);
    on<LoginOtpResendRequested>(_onResendRequested);
  }

  Future<void> _onSubmitted(LoginOtpSubmitted event,Emitter<LoginOtpState> emit) async {
    if (state.code.length < 5) {
      emit(state.copyWith(
        status: LoginOtpStatus.failure,
        errorMessage: 'Please enter the full code',
      ));
      return;
    }

    emit(state.copyWith(
      status: LoginOtpStatus.loading,
      errorMessage: null,
    ));

    try {
      debugPrint("OTP CODE : ${state.code}");
      await repository.verifyCode(code: state.code);
      emit(state.copyWith(status: LoginOtpStatus.success));
    } catch (_) {
      emit(state.copyWith(
        status: LoginOtpStatus.failure,
        errorMessage: 'Invalid verification code',
      ));
    }
  }

  Future<void> _onResendRequested(LoginOtpResendRequested event,Emitter<LoginOtpState> emit) async {
    emit(state.copyWith(resendStatus: LoginOtpResendStatus.loading));
    try {
      await repository.resendCode();
      emit(state.copyWith(resendStatus: LoginOtpResendStatus.done));
    } catch (_) {
      emit(state.copyWith(resendStatus: LoginOtpResendStatus.idle));
    }
  }
}
