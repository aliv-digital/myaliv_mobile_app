import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/forgetPass_otp_repository.dart';
import 'forgetPass_otp_event.dart';
import 'forgetPass_otp_state.dart';


class ForgetPasswordOtpBloc extends Bloc<ForgetPasswordOtpEvent, ForgetPasswordOtpState> {
  final ForgetPasswordOtpRepository repository;

  ForgetPasswordOtpBloc({required this.repository}) : super(const ForgetPasswordOtpState()) {
    on<ForgetPasswordOtpCodeChanged>((event, emit) {
      emit(state.copyWith(
        code: event.code,
        status: ForgetPasswordOtpStatus.initial,
        errorMessage: null,
      ));
    });

    on<ForgetPasswordOtpSubmitted>(_onSubmitted);
    on<ForgetPasswordOtpResendRequested>(_onResendRequested);
  }

  Future<void> _onSubmitted(ForgetPasswordOtpSubmitted event,Emitter<ForgetPasswordOtpState> emit) async {
    if (state.code.length < 5) {
      emit(state.copyWith(
        status: ForgetPasswordOtpStatus.failure,
        errorMessage: 'Please enter the full code',
      ));
      return;
    }

    emit(state.copyWith(
      status: ForgetPasswordOtpStatus.loading,
      errorMessage: null,
    ));

    try {
      debugPrint("OTP CODE : ${state.code}");
      await repository.verifyCode(code: state.code);
      emit(state.copyWith(status: ForgetPasswordOtpStatus.success));
    } catch (_) {
      emit(state.copyWith(
        status: ForgetPasswordOtpStatus.failure,
        errorMessage: 'Invalid verification code',
      ));
    }
  }

  Future<void> _onResendRequested(ForgetPasswordOtpResendRequested event,Emitter<ForgetPasswordOtpState> emit) async {
    emit(state.copyWith(resendStatus: ForgetPasswordOtpResendStatus.loading));
    try {
      await repository.resendCode();
      emit(state.copyWith(resendStatus: ForgetPasswordOtpResendStatus.done));
    } catch (_) {
      emit(state.copyWith(resendStatus: ForgetPasswordOtpResendStatus.idle));
    }
  }
}
