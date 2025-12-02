import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localStorage/localStorage.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>((event, emit) async {
      try {
        await Future.delayed(const Duration(seconds: 3));  // Simulating a delay for splash

        String ? token = await LocalStorage.getAccessToken();
        if(token != null){
          emit(LoggedIn());
        }else{
          emit(SplashLoaded());
        }
        // Splash screen finished, emit loaded state
      } catch (e) {
        emit(SplashError());  // Error state if something goes wrong
      }
    });
  }
}
