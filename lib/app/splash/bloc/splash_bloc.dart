import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localStorage/localStorage.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>((event, emit) async {
      try {
        final results = await Future.wait([
          LocalStorage.getAccessToken(),
          Future<void>.delayed(const Duration(seconds: 1)),
        ]);
        final token = results[0] as String?;
        if (token != null) {
          emit(LoggedIn());
        } else {
          emit(SplashLoaded());
        }
      } catch (e) {
        emit(SplashError());
      }
    });
  }
}
