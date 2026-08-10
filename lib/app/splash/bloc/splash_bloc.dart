import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>((event, emit) async {
      try {
        await Future<void>.delayed(const Duration(seconds: 1));
        // AuthManager.loadSession() already ran in CoreInjection, so
        // currentSession reflects persisted JWT state at this point.
        final session = instance<AuthManager>().currentSession;
        if (session != null && !session.refreshExpired) {
          emit(LoggedIn());
        } else {
          emit(SplashLoaded());
        }
      } catch (_) {
        emit(SplashError());
      }
    });
  }
}
