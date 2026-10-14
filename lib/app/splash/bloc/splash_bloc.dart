import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>((event, emit) async {
      try {
        await Future<void>.delayed(const Duration(seconds: 1));

        final session = instance<AuthManager>().currentSession;

        if (session == null || session.refreshExpired) {
          emit(SplashLoaded());
          return;
        }

        final timedOut = await SessionTimeoutService().hasTimedOut();
        if (!timedOut) {
          emit(LoggedIn());
          return;
        }

        // Session is valid but user has been away >= 20 min.
        // Require biometric re-auth if enabled; otherwise fall back to Welcome.
        final biometricEnabled =
            instance<FingerFaceSecurityCubit>().state.isAnyEnabled;
        emit(biometricEnabled ? BiometricLockRequired() : SplashLoaded());
      } catch (_) {
        emit(SplashError());
      }
    });
  }
}
