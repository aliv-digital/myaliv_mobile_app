import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localStorage/localStorage.dart';
import '../../../core/utils/appUtils.dart';
import '../model/auth_response_model.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc() : super(AuthState.initial()) {

    on<SignInPressed>(_onSignInPressed);
  }

  final repo = AuthRepository();

  Future<void> _onSignInPressed(SignInPressed event,Emitter<AuthState> emit) async {

    emit(state.copyWith(status: AuthStatus.loading));

   // await Future.delayed(const Duration(seconds: 2));

    if (event.phoneNumber.length<=1) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        error: 'Fields cannot be empty',
      ));
      AppUtils.showWarningToast("Phone number required!");
    }else if(event.password.isEmpty){
      emit(state.copyWith(
        status: AuthStatus.failure,
        error: 'Fields cannot be empty',
      ));
      AppUtils.showWarningToast("Password required!");
    } else {
      await repo.signIn(event.phoneNumber, event.password).then((AuthResponse response) async {
        debugPrint(event.phoneNumber);
        if(response.status == 200){
          debugPrint("-------------------------- AuthBloc -------------------------");
          debugPrint("Phone : ${response.phone}");
          debugPrint("status : ${response.status}");
          debugPrint("message : ${response.message}");
          debugPrint("phone : ${response.phone}");
          debugPrint("---------------------------------------------------------------");


          await LocalStorage.storePassword(password: event.password);
          await Future.delayed(Duration(milliseconds: 400));
          AppUtils.showSuccessToast(response.message.toString());
          emit(state.copyWith(status: AuthStatus.success));
        }else{
          emit(state.copyWith(
            status: AuthStatus.failure,
            error: response.message,
          ));
          AppUtils.showWarningToast(response.message);
          //emit(state.copyWith(status: AuthStatus.success));
        }
      });
    }
  }



}
