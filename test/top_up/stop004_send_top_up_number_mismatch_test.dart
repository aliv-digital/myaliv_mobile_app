import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/top_up_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/can_submit_order_result.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/send_topup_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/top_up_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/send_top_up_placeholder_tab.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _SendRepo extends Mock implements SendTopupRepository {}

class _TopUpRepo extends Mock implements TopUpPrepaidRepository {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _BalanceState extends Mock implements BalanceState {}

const _mismatch = "these numbers don't match. re-enter the number to continue.";

void main() {
  late _SendRepo sendRepo;
  late _TopUpRepo topUpRepo;
  late _Balance balance;
  late TopUpPrepaidBloc bloc;
  Uri? confirmation;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    sendRepo = _SendRepo();
    topUpRepo = _TopUpRepo();
    balance = _Balance();
    confirmation = null;
    final balanceState = _BalanceState();
    when(() => balanceState.walletBalance).thenReturn(200);
    when(() => balance.state).thenReturn(balanceState);
    when(
      () => sendRepo.phoneNumberExists(any()),
    ).thenAnswer((_) async => PhoneExistsResult.exists);
    when(() => sendRepo.transferIsValid(any())).thenAnswer((_) async => null);
    when(
      () => topUpRepo.canSubmitOrder(amount: any(named: 'amount')),
    ).thenAnswer((_) async => const CanSubmitOrderResult(''));
    bloc = TopUpPrepaidBloc(repo: topUpRepo);
    instance.registerSingleton<SendTopupRepository>(sendRepo);
  });

  tearDown(() async {
    await bloc.close();
    await balance.close();
    await instance.reset();
  });

  Future<void> pumpTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const SendTopUpPlaceholderTab(title: 'send'),
        ),
        GoRoute(
          path: AppRoutes.confirmation,
          builder: (_, state) {
            confirmation = state.uri;
            return const Scaffold(body: Text('existing confirmation'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TopUpPrepaidBloc>.value(value: bloc),
          BlocProvider<BalanceCubit>.value(value: balance),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fill(
    WidgetTester tester, {
    String phone = '',
    String confirm = '',
    String amount = '',
  }) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), phone);
    await tester.enterText(fields.at(1), confirm);
    await tester.enterText(fields.at(2), amount);
    await tester.pumpAndSettle();
  }

  ElevatedButton proceedButton(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton));

  void expectNoDownstream() {
    verifyNever(() => sendRepo.phoneNumberExists(any()));
    verifyNever(() => sendRepo.transferIsValid(any()));
    verifyNever(() => topUpRepo.canSubmitOrder(amount: any(named: 'amount')));
    expect(confirmation, isNull);
  }

  testWidgets('valid but different numbers show STOP-004 and block', (
    tester,
  ) async {
    await pumpTab(tester);
    await fill(
      tester,
      phone: '2428011616',
      confirm: '2428011617',
      amount: '10',
    );
    expect(find.text(_mismatch), findsOneWidget);
    expect(find.text('Phone number do not match'), findsNothing);
    expect(proceedButton(tester).onPressed, isNull);
    await tester.tap(find.text('proceed'));
    await tester.pumpAndSettle();
    expectNoDownstream();
  });

  testWidgets('matching valid numbers continue through the existing gates', (
    tester,
  ) async {
    await pumpTab(tester);
    await fill(
      tester,
      phone: '2428011616',
      confirm: '2428011616',
      amount: '10',
    );
    expect(find.text(_mismatch), findsNothing);
    await tester.tap(find.text('proceed'));
    await tester.pumpAndSettle();
    verify(() => sendRepo.phoneNumberExists('2428011616')).called(1);
    verify(() => sendRepo.transferIsValid('2428011616')).called(1);
    verify(() => topUpRepo.canSubmitOrder(amount: 10)).called(1);
    expect(find.text('existing confirmation'), findsOneWidget);
    expect(confirmation!.path, AppRoutes.confirmation);
    expect(confirmation!.queryParameters['amount'], '10.00');
    expect(confirmation!.queryParameters['recipient'], '2428011616');
  });

  testWidgets('malformed recipient keeps its own error, no mismatch shown', (
    tester,
  ) async {
    await pumpTab(tester);
    await fill(tester, phone: '24280', confirm: '2428011616', amount: '10');
    expect(find.text('invalid phone number'), findsOneWidget);
    expect(find.text(_mismatch), findsNothing);
    expect(proceedButton(tester).onPressed, isNull);
    expectNoDownstream();
  });

  testWidgets('empty recipient shows no mismatch and stays blocked', (
    tester,
  ) async {
    await pumpTab(tester);
    await fill(tester, confirm: '2428011616', amount: '10');
    expect(find.text(_mismatch), findsNothing);
    expect(proceedButton(tester).onPressed, isNull);
    expectNoDownstream();
  });

  testWidgets('empty confirmation shows no mismatch and stays blocked', (
    tester,
  ) async {
    await pumpTab(tester);
    await fill(tester, phone: '2428011616', amount: '10');
    expect(find.text(_mismatch), findsNothing);
    expect(proceedButton(tester).onPressed, isNull);
    expectNoDownstream();
  });

  testWidgets('correcting the confirmation clears STOP-004', (tester) async {
    await pumpTab(tester);
    await fill(
      tester,
      phone: '2428011616',
      confirm: '2428011617',
      amount: '10',
    );
    expect(find.text(_mismatch), findsOneWidget);
    final confirmField = find.byType(TextField).at(1);
    await tester.enterText(confirmField, '');
    await tester.enterText(confirmField, '2428011616');
    await tester.pumpAndSettle();
    expect(find.text(_mismatch), findsNothing);
    expect(proceedButton(tester).onPressed, isNotNull);
  });
}
