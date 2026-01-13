import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/forgetPass_otp_repository.dart';
import 'forgetPass_otp_event.dart';
import 'forgetPass_otp_state.dart';


class OtpProfilePrepaidBloc
    extends Bloc<OtpProfilePrepaidEvent, OtpProfilePrepaidState> {
  final OtpProfilePrepaidRepository repository;

  OtpProfilePrepaidBloc({required this.repository})
      : super(const OtpProfilePrepaidState()) {
    on<OtpProfilePrepaidCodeChanged>((event, emit) {
      emit(state.copyWith(
        code: event.code,
        status: OtpProfilePrepaidStatus.initial,
        errorMessage: null,
      ));
    });

    on<OtpProfilePrepaidSubmitted>(_onSubmitted);
    on<OtpProfilePrepaidResendRequested>(_onResendRequested);
  }

  Future<void> _onSubmitted(
      OtpProfilePrepaidSubmitted event,
      Emitter<OtpProfilePrepaidState> emit,
      ) async {
    if (state.code.length < 5) {
      emit(state.copyWith(
        status: OtpProfilePrepaidStatus.failure,
        errorMessage: 'Please enter the full code',
      ));
      return;
    }

    emit(state.copyWith(
      status: OtpProfilePrepaidStatus.loading,
      errorMessage: null,
    ));

    try {
      debugPrint("OTP CODE : ${state.code}");
      await repository.verifyCode(code: state.code);
      emit(state.copyWith(status: OtpProfilePrepaidStatus.success));
    } catch (_) {
      emit(state.copyWith(
        status: OtpProfilePrepaidStatus.failure,
        errorMessage: 'Invalid verification code',
      ));
    }
  }

  Future<void> _onResendRequested(
      OtpProfilePrepaidResendRequested event,
      Emitter<OtpProfilePrepaidState> emit,
      ) async {
    emit(state.copyWith(resendStatus: OtpProfilePrepaidResendStatus.loading));
    try {
      await repository.resendCode();
      emit(state.copyWith(resendStatus: OtpProfilePrepaidResendStatus.done));
    } catch (_) {
      emit(state.copyWith(resendStatus: OtpProfilePrepaidResendStatus.idle));
    }
  }
}
