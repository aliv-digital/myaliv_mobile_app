import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';

Future<void> setupFingerFaceSecurityInjection() async {
  instance.registerLazySingleton<BiometricAuthService>(
    () => BiometricAuthService(),
  );

  instance.registerLazySingleton<FingerFaceSecurityRepository>(
    () => FingerFaceSecurityRepositoryImpl(
      service: instance<BiometricAuthService>(),
    ),
  );

  instance.registerLazySingleton<FingerFaceSecurityCubit>(
    () => FingerFaceSecurityCubit(
      instance<FingerFaceSecurityRepository>(),
    ),
  );
}
