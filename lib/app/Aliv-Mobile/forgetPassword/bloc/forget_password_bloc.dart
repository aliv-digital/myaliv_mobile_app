import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/forgetpassword_repository.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgetPasswordRepository repository;

  ForgetPasswordBloc({required this.repository})
    : super(const ForgetPasswordState()) {
    on<ForgetPasswordPhoneChanged>((event, emit) {
      emit(
        state.copyWith(
          phone: event.phone,
          status: ForgetPasswordStatus.initial,
          errorMessage: null,
          isEmptyNumberError: false,
          isInvalidNumberLengthError: false,
        ),
      );
    });

    on<ForgetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ForgetPasswordSubmitted event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    final apiPhone = state.phone.replaceAll(RegExp(r'\D'), '');

    if (apiPhone.isEmpty) {
      // FPW-001 applies only to the empty field; other digitless values keep
      // their existing failure message and toast behavior.
      final isEmptyNumber = state.phone.isEmpty;
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: isEmptyNumber
              ? 'enter your mobile number'
              : 'Please enter your phone number.',
          isEmptyNumberError: isEmptyNumber,
          isInvalidNumberLengthError: false,
        ),
      );
      return;
    }

    // FPW-002 checks the existing normalized digits before any API request.
    if (apiPhone.length != 10) {
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: 'enter a valid 10-digit mobile number',
          isEmptyNumberError: false,
          isInvalidNumberLengthError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ForgetPasswordStatus.loading,
        errorMessage: null,
        isEmptyNumberError: false,
        isInvalidNumberLengthError: false,
      ),
    );

    try {
      final mfaToken = await repository.sendRequest(apiPhone: apiPhone);
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.success,
          mfaToken: mfaToken,
          apiPhoneNumber: apiPhone,
          isEmptyNumberError: false,
          isInvalidNumberLengthError: false,
        ),
      );
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Something went wrong. Please try again.';
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: message,
          isEmptyNumberError: false,
          isInvalidNumberLengthError: false,
        ),
      );
    }
  }
}
