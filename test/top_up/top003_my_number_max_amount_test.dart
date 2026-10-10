import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/logic/top_up_limit_gate.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/view/top_up_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_amount_box.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

const _caseA =
    'your top up limit is not set on your account. to process this payment, please contact support at 1-242-300-2548';
const _caseD =
    'please try again in a few minutes. if this continues, contact support at 1-242-300-2548';
const _caseC200 =
    'your daily top up limit is \$ 200.00. please try a smaller amount to complete your transaction.';

AccountInfoModel _account({double perTx = 100, double daily = 200}) =>
    AccountInfoModel(topUpPerTransLimit: perTx, topUp24HourLimit: daily);

void main() {
  group('My Number gate', () {
    TopUpGateResult gate(
      double amount, {
      double perTx = 100,
      double daily = 200,
      double? limitLeft = 200,
      bool failed = false,
      bool hasAccount = true,
    }) => evaluateMyNumberTopUpGate(
      amount: amount,
      account: hasAccount ? _account(perTx: perTx, daily: daily) : null,
      limitLeft: limitLeft,
      limitFetchFailed: failed,
    );

    for (final (perTx, amount, text) in [
      (100.0, 100.01, r'the maximum top-up amount is $100.00'),
      (50.0, 60.0, r'the maximum top-up amount is $50.00'),
      (1000.0, 1500.0, r'the maximum top-up amount is $1,000.00'),
    ]) {
      test('TOP-003 uses the account limit $perTx', () {
        final result = gate(amount, perTx: perTx, daily: 2000, limitLeft: 2000);
        expect(result.errorMessage, text);
        expect(result.isPerTransactionLimit, isTrue);
      });
    }

    test('amount equal to the account limit stays valid', () {
      final result = gate(100);
      expect(result.blocked, isFalse);
      expect(result.isPerTransactionLimit, isFalse);
    });

    test('daily limit (Case C) is unchanged', () {
      final result = gate(80, limitLeft: 50);
      expect(result.errorMessage, _caseC200);
      expect(result.isPerTransactionLimit, isFalse);
    });

    test('limit not set (Case A) is unchanged and wins over TOP-003', () {
      for (final result in [gate(150, perTx: 0), gate(150, daily: 0)]) {
        expect(result.errorMessage, _caseA);
        expect(result.isPerTransactionLimit, isFalse);
      }
    });

    test('data failure (Case D) is unchanged and wins over TOP-003', () {
      for (final result in [
        gate(150, failed: true),
        gate(150, limitLeft: null),
        gate(150, hasAccount: false),
      ]) {
        expect(result.errorMessage, _caseD);
        expect(result.isPerTransactionLimit, isFalse);
      }
    });
  });

  group('My Number screen', () {
    late _Network network;
    late _Account account;
    late _Balance balance;
    String? confirmationAmount;

    setUpAll(() async {
      registerFallbackValue(HttpMethod.get);
      await (FontLoader('CircularPro')
            ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
            ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });

    setUp(() {
      network = _Network();
      account = _Account();
      balance = _Balance();
      confirmationAmount = null;
      when(() => balance.state).thenReturn(BalanceState.initial());
      instance.registerSingleton<NetworkService>(network);
    });

    tearDown(() async {
      await account.close();
      await balance.close();
      await instance.reset();
    });

    void givenLimits({
      double perTx = 100,
      double daily = 200,
      double limitLeft = 200,
      bool limitFails = false,
    }) {
      when(() => account.state).thenReturn(
        AccountInfoState(
          accountInfo: _account(perTx: perTx, daily: daily),
        ),
      );
      when(
        () => network.request<dynamic>(any(), method: any(named: 'method')),
      ).thenAnswer((invocation) async {
        final path = invocation.positionalArguments.first as String;
        if (path == Api.topUpLimitLeft) {
          if (limitFails) throw Exception('offline');
          return Response<dynamic>(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: <String, dynamic>{'TopUp24HourLimitLeft': limitLeft},
          );
        }
        return Response<dynamic>(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: <String, dynamic>{'Info': ''},
        );
      });
    }

    void verifyNoOrderCheck() {
      verifyNever(
        () => network.request<dynamic>(
          any(that: startsWith(Api.canSubmitOrder(amount: 0).split('?').first)),
          method: any(named: 'method'),
        ),
      );
      expect(confirmationAmount, isNull);
    }

    Future<void> pumpScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(path: '/', builder: (_, _) => const TopUpPrepaidScreen()),
          GoRoute(
            path: AppRoutes.confirmation,
            builder: (_, state) {
              confirmationAmount = state.uri.queryParameters['amount'];
              return const Scaffold(body: Text('existing confirmation'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AccountInfoCubit>.value(value: account),
            BlocProvider<BalanceCubit>.value(value: balance),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> enterAmount(WidgetTester tester, String value) async {
      await tester.enterText(
        find.descendant(
          of: find.byType(TopUpPrepaidAmountBox),
          matching: find.byType(TextField),
        ),
        value,
      );
      await tester.pumpAndSettle();
    }

    Future<void> proceed(WidgetTester tester) async {
      await tester.tap(find.text('top-up now'));
      await tester.pump();
    }

    Future<void> dismissToasts(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }

    Finder maxError() => find.textContaining('the maximum top-up amount is');

    for (final (perTx, text) in [
      (100.0, r'the maximum top-up amount is $100.00'),
      (50.0, r'the maximum top-up amount is $50.00'),
    ]) {
      testWidgets('TOP-003 inline error uses account limit $perTx', (
        tester,
      ) async {
        givenLimits(perTx: perTx);
        await pumpScreen(tester);
        await enterAmount(tester, '150');
        await proceed(tester);
        await tester.pumpAndSettle();
        expect(find.text(text), findsOneWidget);
        expect(find.textContaining('your single top up limit'), findsNothing);
        verifyNoOrderCheck();
        await dismissToasts(tester);
        // Inline, not a toast: it stays until the amount changes.
        expect(find.text(text), findsOneWidget);
      });
    }

    testWidgets('amount equal to the limit continues the existing flow', (
      tester,
    ) async {
      givenLimits();
      await pumpScreen(tester);
      await enterAmount(tester, '100');
      await proceed(tester);
      await tester.pumpAndSettle();
      expect(maxError(), findsNothing);
      expect(find.text('existing confirmation'), findsOneWidget);
      expect(confirmationAmount, '100.00');
    });

    testWidgets('correcting the amount clears the error and continues', (
      tester,
    ) async {
      givenLimits();
      await pumpScreen(tester);
      await enterAmount(tester, '150');
      await proceed(tester);
      await tester.pumpAndSettle();
      expect(maxError(), findsOneWidget);

      await enterAmount(tester, '80');
      expect(maxError(), findsNothing);
      await proceed(tester);
      await tester.pumpAndSettle();
      expect(find.text('existing confirmation'), findsOneWidget);
      expect(confirmationAmount, '80.00');
    });

    testWidgets('daily limit keeps its existing toast', (tester) async {
      givenLimits(limitLeft: 50);
      await pumpScreen(tester);
      await enterAmount(tester, '80');
      await proceed(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(_caseC200), findsOneWidget);
      expect(maxError(), findsNothing);
      verifyNoOrderCheck();
      await dismissToasts(tester);
    });

    testWidgets('limit not set keeps its existing toast', (tester) async {
      givenLimits(perTx: 0);
      await pumpScreen(tester);
      await enterAmount(tester, '150');
      await proceed(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(_caseA), findsOneWidget);
      expect(maxError(), findsNothing);
      verifyNoOrderCheck();
      await dismissToasts(tester);
    });

    testWidgets('limit load failure keeps its existing toast', (tester) async {
      givenLimits(limitFails: true);
      await pumpScreen(tester);
      await enterAmount(tester, '150');
      await proceed(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(_caseD), findsOneWidget);
      expect(maxError(), findsNothing);
      verifyNoOrderCheck();
      await dismissToasts(tester);
    });
  });
}
