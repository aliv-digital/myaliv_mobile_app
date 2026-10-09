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
        (_) async => const FingerFaceSecurityModel(faceIdEnabled: true),
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
      verifyZeroInteractions(network);

      // A later failed attempt retains the original Login fallback behavior.
      when(
        () => repository.authenticate(reason: any(named: 'reason')),
      ).thenAnswer((_) async => BiometricAuthResult.failed);
      await tester.tap(find.text('face id'));
      await tester.pumpAndSettle();
      expect(message, findsNothing);
      expect(find.text('save my password'), findsOneWidget);
      expect(cubit.state.isFailure, isTrue);
      expect(
        cubit.state.errorMessage,
        'Authentication failed. Please try again.',
      );
      verifyZeroInteractions(network);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
