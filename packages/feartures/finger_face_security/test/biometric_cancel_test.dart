import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';

class _TestLocalAuthentication extends LocalAuthentication {
  _TestLocalAuthentication({this.result = true, this.exceptionCode});

  final bool result;
  final LocalAuthExceptionCode? exceptionCode;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> get canCheckBiometrics async => true;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [
    BiometricType.fingerprint,
  ];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<Object> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    if (exceptionCode != null) {
      throw LocalAuthException(code: exceptionCode!);
    }
    return result;
  }
}

class _TestBiometricRepository implements FingerFaceSecurityRepository {
  _TestBiometricRepository(this.result);

  BiometricAuthResult result;

  @override
  Future<BiometricAuthResult> authenticate({String? reason}) async => result;

  @override
  Future<FingerFaceSecurityModel> getBiometricStatus() async =>
      const FingerFaceSecurityModel();

  @override
  Future<BiometricSetupResult> setupBiometric() async =>
      BiometricSetupResult.success;

  @override
  Future<BiometricSetupResult> setupFingerprintBiometric() => setupBiometric();

  @override
  Future<BiometricSetupResult> setupFaceIdBiometric() => setupBiometric();

  @override
  Future<void> disableBiometric() async {}

  @override
  Future<void> disableFingerprintBiometric() async {}

  @override
  Future<void> disableFaceIdBiometric() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BIO-005 service mapping', () {
    for (final entry in {
      LocalAuthExceptionCode.userCanceled: BiometricAuthResult.cancelled,
      LocalAuthExceptionCode.userRequestedFallback: BiometricAuthResult.failed,
      LocalAuthExceptionCode.systemCanceled: BiometricAuthResult.error,
      LocalAuthExceptionCode.temporaryLockout: BiometricAuthResult.error,
      LocalAuthExceptionCode.biometricLockout: BiometricAuthResult.error,
    }.entries) {
      test('${entry.key.name} maps to ${entry.value.name}', () async {
        final service = BiometricAuthService(
          localAuth: _TestLocalAuthentication(exceptionCode: entry.key),
        );

        expect(await service.authenticateWithBiometrics(), entry.value);
      });
    }

    for (final result in [false, true]) {
      test('authentication result $result remains unchanged', () async {
        final service = BiometricAuthService(
          localAuth: _TestLocalAuthentication(result: result),
        );

        expect(
          await service.authenticateWithBiometrics(),
          result ? BiometricAuthResult.success : BiometricAuthResult.failed,
        );
      });
    }
  });

  for (final result in [
    BiometricAuthResult.cancelled,
    BiometricAuthResult.failed,
    BiometricAuthResult.success,
  ]) {
    test('Cubit preserves the distinct ${result.name} outcome', () async {
      final cubit = FingerFaceSecurityCubit(_TestBiometricRepository(result));
      addTearDown(cubit.close);
      final states = <FingerFaceSecurityState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await cubit.authenticate();
      await Future<void>.delayed(Duration.zero);

      expect(states.first.status, FingerFaceSecurityStatus.authenticating);
      expect(cubit.state.lastAuthResult, result);
      expect(cubit.state.isSessionAuthenticated, isFalse);
      switch (result) {
        case BiometricAuthResult.cancelled:
          expect(cubit.state.status, FingerFaceSecurityStatus.cancelled);
          expect(cubit.state.isFailure, isFalse);
          expect(cubit.state.errorMessage, isNull);
          expect(
            cubit.state.informationalMessage,
            'enter your password to continue',
          );
        case BiometricAuthResult.failed:
          expect(cubit.state.isFailure, isTrue);
          expect(cubit.state.informationalMessage, isNull);
          expect(
            cubit.state.errorMessage,
            'Authentication failed. Please try again.',
          );
        case BiometricAuthResult.success:
          expect(cubit.state.status, FingerFaceSecurityStatus.authenticated);
          expect(cubit.state.errorMessage, isNull);
          expect(cubit.state.informationalMessage, isNull);
        default:
          fail('Unexpected test result');
      }
    });

    testWidgets('security gate ${result.name}: text, haptics and callbacks', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final haptics = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final cubit = FingerFaceSecurityCubit(_TestBiometricRepository(result));
      addTearDown(cubit.close);
      var successCallbacks = 0;
      var errorCallbacks = 0;
      final theme = ThemeData(useMaterial3: true);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: BlocProvider.value(
            value: cubit,
            child: BiometricLockScreen(
              onAuthSuccess: () => successCallbacks++,
              onAuthError: () => errorCallbacks++,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      switch (result) {
        case BiometricAuthResult.cancelled:
          final message = find.text('enter your password to continue');
          expect(message, findsOneWidget);
          expect(
            tester.widget<Text>(message).style?.color,
            theme.colorScheme.onSurface,
          );
          expect(
            find.text('Authentication failed. Please try again.'),
            findsNothing,
          );
          expect(haptics, isEmpty);
          expect(successCallbacks, 0);
        case BiometricAuthResult.failed:
          expect(
            find.text('Authentication failed. Please try again.'),
            findsOneWidget,
          );
          expect(haptics, ['HapticFeedbackType.heavyImpact']);
          expect(successCallbacks, 0);
        case BiometricAuthResult.success:
          expect(find.text('Authentication successful!'), findsOneWidget);
          expect(haptics, ['HapticFeedbackType.lightImpact']);
          expect(successCallbacks, 1);
        default:
          fail('Unexpected test result');
      }
      expect(errorCallbacks, 0);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
