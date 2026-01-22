import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/otp_prepaid_repository.dart';
import 'otp_prepaid_event.dart';
import 'otp_prepaid_state.dart';



class OtpAutoRenewPrepaidBloc
    extends Bloc<OtpAutoRenewPrepaidEvent, OtpAutoRenewPrepaidState> {
  final OtpAutoRenewPrepaidRepository repository;

  OtpAutoRenewPrepaidBloc({required this.repository})
      : super(const OtpAutoRenewPrepaidState()) {
    on<OtpAutoRenewPrepaidCodeChanged>((event, emit) {
      emit(
        state.copyWith(
          code: event.code,
          status: OtpAutoRenewPrepaidStatus.initial,
          errorMessage: null,
        ),
      );
    });

    on<OtpAutoRenewPrepaidSubmitted>(_onSubmitted);
    on<OtpAutoRenewPrepaidResendRequested>(_onResendRequested);
  }

  Future<void> _onSubmitted(
      OtpAutoRenewPrepaidSubmitted event,
      Emitter<OtpAutoRenewPrepaidState> emit,
      ) async {
    if (state.code.length < 5) {
      emit(
        state.copyWith(
          status: OtpAutoRenewPrepaidStatus.failure,
          errorMessage: 'Please enter the full code',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: OtpAutoRenewPrepaidStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      debugPrint("OTP CODE : ${state.code}");
      await repository.verifyCode(code: state.code);
      emit(state.copyWith(status: OtpAutoRenewPrepaidStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          status: OtpAutoRenewPrepaidStatus.failure,
          errorMessage: 'Invalid verification code',
        ),
      );
    }
  }

  Future<void> _onResendRequested(
      OtpAutoRenewPrepaidResendRequested event,
      Emitter<OtpAutoRenewPrepaidState> emit,
      ) async {
    emit(state.copyWith(resendStatus: OtpAutoRenewPrepaidResendStatus.loading));

    try {
      await repository.resendCode();
      emit(state.copyWith(resendStatus: OtpAutoRenewPrepaidResendStatus.done));
    } catch (_) {
      emit(state.copyWith(resendStatus: OtpAutoRenewPrepaidResendStatus.idle));
    }
  }
}
