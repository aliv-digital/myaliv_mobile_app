import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/faceIdSecurity/bloc/face_id_security_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/faceIdSecurity/bloc/face_id_security_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/faceIdSecurity/bloc/face_id_security_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/faceIdSecurity/repository/face_id_security_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/fingerPrintSecurity/bloc/fingerprint_security_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/fingerPrintSecurity/bloc/fingerprint_security_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/fingerPrintSecurity/bloc/fingerprint_security_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/fingerPrintSecurity/repository/fingerprint_security_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/settingScreen/bloc/settings_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/settingScreen/bloc/settings_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/settingScreen/bloc/settings_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/settingScreen/repository/settings_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/enterPassword/prepaid/bloc/enter_password_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/enterPassword/prepaid/bloc/enter_password_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/enterPassword/prepaid/repository/enter_password_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/splash/bloc/splash_bloc.dart';
import 'package:myaliv_mobile_app/app/splash/bloc/splash_event.dart';
import 'package:myaliv_mobile_app/app/splash/bloc/splash_state.dart';

class _Biometrics extends Mock implements FingerFaceSecurityRepository {}

class _FingerprintSettings extends Mock
    implements FingerPrintSecurityRepository {}

class _FaceSettings extends Mock implements FaceIdSecurityRepository {}

class _Settings extends Mock implements SettingsRepository {}

class _Password extends Mock implements EnterPasswordPrepaidRepository {}

class _Auth extends Mock implements AuthManager {}

void main() {
  late _Biometrics repository;
  late FingerFaceSecurityCubit biometrics;

  setUp(() async {
    await instance.reset();
    repository = _Biometrics();
    when(() => repository.getBiometricStatus())
        .thenAnswer((_) async => const FingerFaceSecurityModel(
              fingerprintEnabled: true,
              faceIdEnabled: true,
              isFingerprintAvailable: true,
              isFaceIdAvailable: true,
            ));
    when(() => repository.authenticate(reason: any(named: 'reason')))
        .thenAnswer((_) async => BiometricAuthResult.userRequestedFallback);
    when(() => repository.setupFingerprintBiometric())
        .thenAnswer((_) async => BiometricSetupResult.authenticationFailed);
    when(() => repository.setupFaceIdBiometric())
        .thenAnswer((_) async => BiometricSetupResult.authenticationFailed);
    biometrics = FingerFaceSecurityCubit(repository);
    instance.registerSingleton<FingerFaceSecurityCubit>(biometrics);
    await biometrics.loadBiometricStatus();
  });

  tearDown(() async {
    await biometrics.close();
    await instance.reset();
  });

  test('fingerprint settings retain back navigation after unsuccessful setup',
      () async {
    final bloc = FingerPrintSecurityBloc(repository: _FingerprintSettings());
    addTearDown(bloc.close);
    bloc.add(const AgreePressed());
    await bloc.stream.firstWhere(
        (state) => state.navTarget == FingerPrintSecurityNavTarget.back);
    expect(biometrics.state.errorMessage,
        'Authentication failed. Please try again.');
    expect(biometrics.state.isSessionAuthenticated, isFalse);
    verify(() => repository.setupFingerprintBiometric()).called(1);
  });

  test('Face ID settings retain back navigation after unsuccessful setup',
      () async {
    final bloc = FaceIdSecurityBloc(repository: _FaceSettings());
    addTearDown(bloc.close);
    bloc.add(const FaceIdAgreePressed());
    await bloc.stream
        .firstWhere((state) => state.navTarget == FaceIdSecurityNavTarget.back);
    expect(biometrics.state.errorMessage,
        'Authentication failed. Please try again.');
    expect(biometrics.state.isSessionAuthenticated, isFalse);
    verify(() => repository.setupFaceIdBiometric()).called(1);
  });

  test('general settings reload the same availability and flags after fallback',
      () async {
    await biometrics.authenticate();
    final bloc = SettingsBloc(repository: _Settings());
    addTearDown(bloc.close);
    bloc.add(const SettingsStarted());
    await bloc.stream
        .firstWhere((state) => state.status == SettingsStatus.ready);
    expect(bloc.state.fingerprintEnabled, isTrue);
    expect(bloc.state.faceScanEnabled, isTrue);
    expect(bloc.state.isFingerprintAvailable, isTrue);
    expect(bloc.state.isFaceIdAvailable, isTrue);
    expect(bloc.state.navTarget, SettingsNavTarget.none);
    expect(bloc.state.errorMessage, isNull);
    expect(biometrics.state.isSessionAuthenticated, isFalse);
  });

  for (final face in [false, true]) {
    test(
        'account verification face=$face preserves fallback without password API',
        () async {
      final password = _Password();
      final bloc = EnterPasswordPrepaidBloc(password);
      addTearDown(bloc.close);
      final before = bloc.state;
      final result = biometrics.stream.firstWhere((state) =>
          state.lastAuthResult == BiometricAuthResult.userRequestedFallback);
      bloc.add(face
          ? const EnterPasswordPrepaidFaceIdPressed()
          : const EnterPasswordPrepaidFingerprintPressed());
      await result;
      expect(bloc.state, before);
      expect(biometrics.state.errorMessage,
          'Authentication failed. Please try again.');
      expect(biometrics.state.isSessionAuthenticated, isFalse);
      verifyZeroInteractions(password);
    });
  }

  test('startup still requires app lock after password fallback', () async {
    await biometrics.authenticate();
    final auth = _Auth();
    when(() => auth.currentSession).thenReturn(TokenSession(
      accessToken: 'test-access',
      refreshToken: 'test-refresh',
      accessExpiresAt: DateTime(2030),
      refreshExpiresAt: DateTime(2031),
    ));
    instance.registerSingleton<AuthManager>(auth);
    final bloc = SplashBloc();
    addTearDown(bloc.close);
    bloc.add(SplashStarted());
    final state = await bloc.stream.first;
    expect(state, isA<BiometricLockRequired>());
    expect(biometrics.state.isSessionAuthenticated, isFalse);
    verify(() => auth.currentSession).called(1);
    verifyNoMoreInteractions(auth);
  });
}
