// lib/login/forgetPass_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/forgetpassword_repository.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';



class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgetPasswordRepository repository;

  ForgetPasswordBloc({required this.repository}) : super(const ForgetPasswordState()) {
    on<ForgetPasswordPhoneChanged>((event, emit) {
      emit(state.copyWith(phone: event.phone, status: ForgetPasswordStatus.initial, errorMessage: null));
    });

    on<ForgetPasswordPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password, status: ForgetPasswordStatus.initial, errorMessage: null));
    });

    on<ForgetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(ForgetPasswordSubmitted event, Emitter<ForgetPasswordState> emit) async {
    emit(state.copyWith(status: ForgetPasswordStatus.loading, errorMessage: null));
    try {
      await repository.sendRequest(
        phone: state.phone,
        password: state.password,
      );
      emit(state.copyWith(status: ForgetPasswordStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: 'invalid credentials!',
        ),
      );
    }
  }
}
