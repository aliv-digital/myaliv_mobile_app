import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/view/login_page.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockBiometricRepository extends Mock
    implements FingerFaceSecurityRepository {}

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  testWidgets(
    'Login shows biometric cancellation in its existing inline area',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      // Match the app font so the existing Login row is measured accurately.
      await (FontLoader('CircularPro')
            ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
            ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
          .load();
      await instance.reset();
      addTearDown(instance.reset);
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _MockBiometricRepository();
      final network = _MockNetworkService();
      when(() => repository.getBiometricStatus()).thenAnswer(
        (_) async => const FingerFaceSecurityModel(
          faceIdEnabled: true,
          fingerprintEnabled: true,
        ),
      );
      when(
        () => repository.authenticate(reason: any(named: 'reason')),
      ).thenAnswer((_) async => BiometricAuthResult.cancelled);
      final cubit = FingerFaceSecurityCubit(repository);
      final config = AppUiConfigCubit();
      addTearDown(cubit.close);
      addTearDown(config.close);
      instance.registerSingleton<FingerFaceSecurityCubit>(cubit);
      instance.registerSingleton<NetworkService>(network);
      await cubit.loadBiometricStatus();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: BlocProvider.value(value: config, child: const LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('save my password'), findsOneWidget);

      await tester.tap(find.text('face id'));
      await tester.pumpAndSettle();

      final message = find.text('enter your password to continue');
      expect(message, findsOneWidget);
      expect(
        tester.widget<Text>(message).style,
        AuthModuleTextStyles.saveMyPassword,
      );
      expect(cubit.state.isFailure, isFalse);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Face not detected. Try again.'), findsNothing);
      verifyZeroInteractions(network);

      // Ordinary Face ID rejection uses its own copy and keeps password login.
      when(
        () => repository.authenticate(reason: any(named: 'reason')),
      ).thenAnswer((_) async => BiometricAuthResult.failed);
      await tester.tap(find.text('face id'));
      await tester.pumpAndSettle();
      expect(message, findsNothing);
      expect(find.text('save my password'), findsOneWidget);
      expect(cubit.state.isFailure, isTrue);
      expect(find.text('Face not detected. Try again.'), findsOneWidget);
      expect(
        find.text('Fingerprint not recognized. Please try again.'),
        findsNothing,
      );
      final password = tester.widget<TextField>(find.byType(TextField).last);
      expect(password.enabled, isNot(false));
      expect(password.readOnly, isFalse);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'sign in'),
            )
            .onPressed,
        isNotNull,
      );
      expect(
        cubit.state.errorMessage,
        'Authentication failed. Please try again.',
      );
      verifyZeroInteractions(network);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      when(
        () => repository.authenticate(reason: any(named: 'reason')),
      ).thenAnswer((_) async => BiometricAuthResult.userRequestedFallback);
      for (final action in ['fingerprint', 'face id']) {
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(
          cubit.state.lastAuthResult,
          BiometricAuthResult.userRequestedFallback,
        );
        expect(
          find.text('Fingerprint not recognized. Please try again.'),
          findsNothing,
        );
        expect(find.text('Face not detected. Try again.'), findsNothing);
        expect(
          find.text('Authentication failed. Please try again.'),
          findsNothing,
        );
        expect(find.byType(SnackBar), findsNothing);
        expect(find.byType(Dialog), findsNothing);
        expect(message, findsNothing);
        final password = tester.widget<TextField>(find.byType(TextField).last);
        expect(password.enabled, isNot(false));
        expect(password.readOnly, isFalse);
      }
      await tester.enterText(find.byType(TextField).last, 'test-password');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'test-password',
      );
      verifyZeroInteractions(network);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
