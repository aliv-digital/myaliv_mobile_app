import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/otp_postpaid_repository.dart';
import 'otp_postpaid_event.dart';
import 'otp_postpaid_state.dart';

class OTPPostpaidBloc extends Bloc<OTPPostpaidEvent, OTPPostpaidState> {
  final OTPPostpaidRepository repository;

  OTPPostpaidBloc({required this.repository}) : super(const OTPPostpaidState()) {
    on<OTPPostpaidCodeChanged>((event, emit) {
      emit(
        state.copyWith(
          code: event.code,
          status: OTPPostpaidStatus.initial,
          errorMessage: null,
        ),
      );
    });

    on<OTPPostpaidSubmitted>(_onSubmitted);
    on<OTPPostpaidResendRequested>(_onResendRequested);
  }

  Future<void> _onSubmitted(
      OTPPostpaidSubmitted event,
      Emitter<OTPPostpaidState> emit,
      ) async {
    if (state.code.length < 5) {
      emit(
        state.copyWith(
          status: OTPPostpaidStatus.failure,
          errorMessage: 'Please enter the full code',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: OTPPostpaidStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      debugPrint("OTP CODE : ${state.code}");
      await repository.verifyCode(code: state.code);
      emit(state.copyWith(status: OTPPostpaidStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          status: OTPPostpaidStatus.failure,
          errorMessage: 'Invalid verification code',
        ),
      );
    }
  }

  Future<void> _onResendRequested(
      OTPPostpaidResendRequested event,
      Emitter<OTPPostpaidState> emit,
      ) async {
    emit(state.copyWith(resendStatus: OTPPostpaidResendStatus.loading));

    try {
      await repository.resendCode();
      emit(state.copyWith(resendStatus: OTPPostpaidResendStatus.done));
    } catch (_) {
      emit(state.copyWith(resendStatus: OTPPostpaidResendStatus.idle));
    }
  }
}
