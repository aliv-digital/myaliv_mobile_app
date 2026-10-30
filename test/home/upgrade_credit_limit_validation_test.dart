import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/logic/credit_limit_value_validation.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/update_limits_request.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/view/upgrade_credit_limit_screen.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/view/widgets/limit_amount_input_field.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Auth extends Mock implements AuthManager {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

class _Harness {
  final devices = _Devices();
  final balance = _Balance();
  final account = _Account();
  final auth = _Auth();
  final challenge = _Challenge();
  late GoRouter router;
  var challenges = 0;

  Future<void> pump(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          DeviceLimitsModel.fromJson({
            'DeviceID': 123,
            'MaxAllowedLocalText': 100,
            'MaxAllowedLocalData': 100,
            'MaxAllowedLocalVoice': 100,
            'MaxAllowedRoaming': 100,
            'MaxAllowedInternational': 100,
          }),
        ],
      ),
    );
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    when(() => balance.state).thenReturn(BalanceState.initial());
    when(() => account.state).thenReturn(
      const AccountInfoState(accountInfo: AccountInfoModel(idAcc: 42)),
    );
    when(() => auth.currentSession).thenReturn(
      TokenSession(
        accessToken: 'synthetic-access',
        refreshToken: 'synthetic-refresh',
        accessExpiresAt: DateTime(2100),
        refreshExpiresAt: DateTime(2101),
      ),
    );
    when(() => challenge.requestChallenge()).thenAnswer((_) async {
      challenges++;
      return const CallLogsChallenge(
        mfaToken: 'synthetic-mfa',
        apiPhoneNumber: '2425550100',
      );
    });
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<CallLogsVerificationRepository>(challenge);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.upgradeCreditLimit,
      routes: [
        GoRoute(
          path: AppRoutes.upgradeCreditLimit,
          builder: (_, _) => const UpgradeCreditLimitScreen(),
        ),
        GoRoute(
          path: AppRoutes.accountActionOtp,
          builder: (_, _) => const Scaffold(body: Text('OTP destination')),
        ),
      ],
    );
    await tester.pumpWidget(
      BlocProvider<BalanceCubit>.value(
        value: balance,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> proceed(WidgetTester tester) async {
    tester.testTextInput.hide();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.ensureVisible(find.text('proceed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('proceed'));
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    await devices.close();
    await balance.close();
    await account.close();
    await instance.reset();
  }
}

void main() {
  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  for (final value in [
    '0',
    '100',
    '100.00',
    '12.3456',
    '.5',
    '100.',
    '-100',
    '-12.50',
    '+100.25',
    ' 100.25 ',
  ]) {
    test('accepts a finite integer or decimal: $value', () {
      expect(validateCreditLimitValue(value), isNull);
    });
  }

  for (final value in [
    '',
    ' ',
    'abc',
    '100abc',
    '158-88848888',
    '1.2.3',
    '1,000',
    r'$100',
    '1 00',
    'NaN',
    'Infinity',
    '-Infinity',
    '1e3',
    '0xFF',
    '+',
    '-',
    '.',
    '--1',
  ]) {
    test('rejects a value outside integer/decimal notation: "$value"', () {
      expect(validateCreditLimitValue(value), 'invalid value');
    });
  }

  test('rejects a decimal that exceeds the finite double range', () {
    expect(validateCreditLimitValue('9' * 400), 'invalid value');
  });

  test('accepted values keep the existing request mapping', () {
    final request = UpdateLimitsRequest.fromFormValues(
      localText: '125',
      localData: '125.50',
      localVoice: '0',
      international: '-3.25',
      roaming: '.5',
    );
    expect(request.toJson(), {
      'MaxAllowedLocalText': 125.0,
      'MaxAllowedLocalData': 125.5,
      'MaxAllowedLocalVoice': 0.0,
      'MaxAllowedInternational': -3.25,
      'MaxAllowedRoaming': 0.5,
    });
  });

  for (final width in [320.0, 430.0]) {
    testWidgets('all five fields show inline errors and block OTP at $width', (
      tester,
    ) async {
      final h = _Harness();
      try {
        await h.pump(tester, width: width);
        expect(find.text('invalid value'), findsNothing);
        const invalid = ['abc', '1.2.3', '158-88848888', r'$10', 'NaN'];
        const valid = ['125', '125.50', '0', '-3.25', '.5'];
        for (var i = 0; i < 5; i++) {
          final field = find.byType(LimitFieldWithController).at(i);
          final input = find.descendant(
            of: field,
            matching: find.byType(TextField),
          );
          await tester.ensureVisible(input);
          await tester.enterText(input, invalid[i]);
          await tester.pumpAndSettle();
          final error = find.descendant(
            of: field,
            matching: find.text('invalid value'),
          );
          expect(error, findsOneWidget);
          expect(
            tester.widget<Text>(error).style?.color,
            ColorManager.redColor,
          );
          expect(
            tester.getTopLeft(error).dy,
            greaterThan(tester.getBottomLeft(input).dy),
          );
          await h.proceed(tester);
          expect(h.challenges, 0);
          expect(find.text('OTP destination'), findsNothing);
          expect(find.text('invalid value'), findsOneWidget);
          await tester.ensureVisible(input);
          await tester.enterText(input, valid[i]);
          await tester.pumpAndSettle();
          expect(find.text('invalid value'), findsNothing);
        }
        await h.proceed(tester);
        expect(h.challenges, 1);
        expect(find.text('OTP destination'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        await h.dispose(tester);
      }
    });
  }

  testWidgets('empty fields show all five errors and do not request OTP', (
    tester,
  ) async {
    final h = _Harness();
    try {
      await h.pump(tester);
      for (var i = 0; i < 5; i++) {
        final input = find.byType(TextField).at(i);
        await tester.ensureVisible(input);
        await tester.enterText(input, '');
        await tester.pump();
      }
      await h.proceed(tester);
      expect(find.text('invalid value'), findsNWidgets(5));
      expect(h.challenges, 0);
      expect(find.text('OTP destination'), findsNothing);
    } finally {
      await h.dispose(tester);
    }
  });

  testWidgets('unchanged valid limits retain the existing no-change message', (
    tester,
  ) async {
    final h = _Harness();
    try {
      await h.pump(tester);
      await h.proceed(tester);
      expect(find.text('invalid value'), findsNothing);
      expect(
        find.text(
          'No changes detected. Please enter or update a value before continuing.',
        ),
        findsOneWidget,
      );
      expect(h.challenges, 0);
    } finally {
      await h.dispose(tester);
    }
  });
}
