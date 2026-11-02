import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

const _invalid = 'invalid Format';
const _mismatch = "these numbers don't match. re-enter the number to continue.";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Network network;

  setUp(() async {
    await instance.reset();
    network = _Network();
    instance.registerSingleton<NetworkService>(network);
    when(
      () => network.request<dynamic>(
        Api.guestBalanceUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.guestBalanceUrl),
        data: <String, dynamic>{
          'Balance': 20.0,
          'AccountStatus': 'AC',
          'PaymentOption': 'PostPay',
        },
      ),
    );
  });

  tearDown(() async {
    await instance.reset();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const GuestPayBillScreen()),
        GoRoute(
          path: AppRoutes.guestPayBillConfirm,
          builder: (_, _) => const Scaffold(body: Text('confirmation')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(key: UniqueKey(), routerConfig: router),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  Finder phone(int index) => find
      .byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'eg: (242)-899-9999',
      )
      .at(index);

  Future<void> enter(
    WidgetTester tester, {
    String? mobile,
    String? confirm,
  }) async {
    if (mobile != null) await tester.enterText(phone(0), mobile);
    if (confirm != null) await tester.enterText(phone(1), confirm);
    // Errors under the fields show once the field loses focus.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.showKeyboard(phone(1));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  bool canVerify(WidgetTester tester) => tester
      .element(find.byType(SingleChildScrollView))
      .read<GuestPayBillBloc>()
      .state
      .canVerify;

  void expectLookup(int times) {
    final call = verify(
      () => network.request<dynamic>(
        Api.guestBalanceUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    );
    times == 0 ? call.called(0) : call.called(times);
  }

  void expectNoLookup() => verifyNever(
    () => network.request<dynamic>(
      Api.guestBalanceUrl,
      method: HttpMethod.post,
      data: any(named: 'data'),
      options: any(named: 'options'),
    ),
  );

  testWidgets('empty mobile stays separate from BILL-003', (tester) async {
    await pumpScreen(tester);
    await enter(tester, mobile: '', confirm: '');
    expect(find.text(_invalid), findsNothing);
    expect(find.text(_mismatch), findsNothing);
    expect(canVerify(tester), isFalse);
  });

  testWidgets('BILL-003 non-empty invalid mobile is blocked inline', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enter(tester, mobile: '24255', confirm: '24255');
    expect(find.text(_invalid), findsNWidgets(2));
    expect(find.text('invalid phone number'), findsNothing);
    expect(find.text(_mismatch), findsNothing);
    expect(canVerify(tester), isFalse);
    await submit(tester);
    expectNoLookup();
  });

  testWidgets('BILL-003 malformed confirm shows format, not mismatch', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enter(tester, mobile: '2425551234', confirm: '24255');
    expect(find.text(_invalid), findsOneWidget);
    expect(find.text(_mismatch), findsNothing);
    await submit(tester);
    expectNoLookup();
  });

  for (final size in [const Size(320, 800), const Size(430, 932)]) {
    for (final fieldIndex in [0, 1]) {
      testWidgets(
        'field $fieldIndex keeps missing-242 error while typing at $size',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await pumpScreen(tester);
          if (fieldIndex == 1) {
            await enter(tester, mobile: '2428999208');
          }

          for (final digits in [
            '899920',
            '8999208',
            '89992080',
            '8999208000',
          ]) {
            // Clear between inputs to avoid interpreting replacement of
            // formatted text as deletion in the Bahamas input formatter.
            await tester.enterText(phone(fieldIndex), '');
            await tester.enterText(phone(fieldIndex), digits);
            await tester.pumpAndSettle();

            expect(
              tester.widget<TextField>(phone(fieldIndex)).focusNode!.hasFocus,
              isTrue,
            );
            expect(find.text(_invalid), findsOneWidget);
            expect(find.text(_mismatch), findsNothing);
            expect(canVerify(tester), isFalse);
            expect(tester.takeException(), isNull);
          }

          await submit(tester);
          expectNoLookup();
        },
      );
    }
  }

  testWidgets(
    'matching seven-digit numbers stay invalid until 242 is entered',
    (tester) async {
      await pumpScreen(tester);
      await enter(tester, mobile: '8999208', confirm: '8999208');
      expect(find.text(_invalid), findsNWidgets(2));
      expect(find.text(_mismatch), findsNothing);
      expect(canVerify(tester), isFalse);
      await submit(tester);
      expectNoLookup();

      await enter(tester, mobile: '', confirm: '');
      expect(find.text(_invalid), findsNothing);
      await enter(tester, mobile: '2428999208', confirm: '2428999208');
      expect(find.text(_invalid), findsNothing);
      expect(find.text(_mismatch), findsNothing);
      expect(canVerify(tester), isTrue);
      await submit(tester);
      verify(
        () => network.request<dynamic>(
          Api.guestBalanceUrl,
          method: HttpMethod.post,
          data: {'ChannelType': 'SelfCare', 'PhoneNumber': '2428999208'},
          options: any(named: 'options'),
        ),
      ).called(1);
    },
  );

  testWidgets('BILL-004 valid but different numbers are blocked inline', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enter(tester, mobile: '2425551234', confirm: '2425551235');
    expect(find.text(_mismatch), findsOneWidget);
    expect(find.text('phone number do not match'), findsNothing);
    expect(find.text(_invalid), findsNothing);
    expect(canVerify(tester), isFalse);
    await submit(tester);
    expectNoLookup();
  });

  testWidgets('BILL-004 is not shown while the main mobile is invalid', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enter(tester, mobile: '24255', confirm: '2425551234');
    expect(find.text(_mismatch), findsNothing);
    expect(find.text(_invalid), findsOneWidget);
    expectNoLookup();
  });

  testWidgets('fixing the confirmation clears BILL-004 and verifies', (
    tester,
  ) async {
    await pumpScreen(tester);
    await enter(tester, mobile: '2425551234', confirm: '2425551235');
    expect(find.text(_mismatch), findsOneWidget);
    // Clear first: replacing formatted text in one step reads as a backspace
    // to the existing Bahamas formatter.
    await enter(tester, confirm: '');
    await enter(tester, confirm: '2425551234');
    expect(find.text(_mismatch), findsNothing);
    expect(find.text(_invalid), findsNothing);
    expect(canVerify(tester), isTrue);
    await submit(tester);
    expectLookup(1);
  });
}
