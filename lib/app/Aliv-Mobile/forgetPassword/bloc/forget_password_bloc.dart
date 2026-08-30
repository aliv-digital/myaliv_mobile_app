import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/forgetpassword_repository.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgetPasswordRepository repository;

  ForgetPasswordBloc({required this.repository}) : super(const ForgetPasswordState()) {
    on<ForgetPasswordPhoneChanged>((event, emit) {
      emit(state.copyWith(
        phone: event.phone,
        status: ForgetPasswordStatus.initial,
        errorMessage: null,
      ));
    });

    on<ForgetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ForgetPasswordSubmitted event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    final apiPhone = state.phone.replaceAll(RegExp(r'\D'), '');

    if (apiPhone.isEmpty) {
      emit(state.copyWith(
        status: ForgetPasswordStatus.failure,
        errorMessage: 'Please enter your phone number.',
      ));
      return;
    }

    emit(state.copyWith(status: ForgetPasswordStatus.loading, errorMessage: null));

    try {
      final mfaToken = await repository.sendRequest(apiPhone: apiPhone);
      emit(state.copyWith(
        status: ForgetPasswordStatus.success,
        mfaToken: mfaToken,
        apiPhoneNumber: apiPhone,
      ));
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Something went wrong. Please try again.';
      emit(state.copyWith(
        status: ForgetPasswordStatus.failure,
        errorMessage: message,
      ));
    }
  }
}
