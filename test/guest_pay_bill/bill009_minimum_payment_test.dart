import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/model/guest_pay_bill_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/widgets/guest_pay_bill_primary_submit_button.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

const _minimum = r'the minimum payment amount is $5.00';
const _invalidNumber = 'enter a valid 10-digit mobile number';
const _mismatch = "these numbers don't match. re-enter the number to continue.";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Network network;
  late List<Object?> confirmExtras;

  setUp(() async {
    await instance.reset();
    network = _Network();
    confirmExtras = [];
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
    when(
      () => network.request<dynamic>(
        Api.guestFibrBalanceUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.guestFibrBalanceUrl),
        data: <String, dynamic>{
          'id_acc': 123,
          'Balance': 20.0,
          'AccountStatus': 'active',
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
          builder: (_, state) {
            confirmExtras.add(state.extra);
            return const Scaffold(body: Text('confirmation'));
          },
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

  Finder field(String hint) => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == hint,
  );

  Finder phone(int index) => field('eg: (242)-899-9999').at(index);

  GuestPayBillState state(WidgetTester tester) => tester
      .element(find.byType(SingleChildScrollView))
      .read<GuestPayBillBloc>()
      .state;

  Future<void> submitField(WidgetTester tester, Finder target) async {
    await tester.showKeyboard(target);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> verifyPostpaid(WidgetTester tester) async {
    await tester.enterText(phone(0), '2425551234');
    await tester.enterText(phone(1), '2425551234');
    await tester.pump();
    await submitField(tester, phone(1));
    expect(state(tester).verifyStatus, GuestPayBillVerifyStatus.success);
  }

  Future<void> enterAmount(WidgetTester tester, String value) async {
    await tester.enterText(field(r'$ 0.00'), value);
    await tester.pumpAndSettle();
  }

  Future<void> tapPay(WidgetTester tester) async {
    final button = find.descendant(
      of: find.byType(GuestPayBillPrimarySubmitButton),
      matching: find.byType(ElevatedButton),
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  double? confirmedAmount() => confirmExtras.isEmpty
      ? null
      : (confirmExtras.single as GuestPayBillConfirmArgs).amount;

  for (final amount in ['0.01', '4.99']) {
    testWidgets('BILL-009 \$$amount is blocked inline', (tester) async {
      await pumpScreen(tester);
      await verifyPostpaid(tester);
      await enterAmount(tester, amount);
      expect(find.text(_minimum), findsOneWidget);
      expect(state(tester).canSubmit, isFalse);
      await tapPay(tester);
      await submitField(tester, field(r'$ 0.00'));
      expect(confirmExtras, isEmpty);
      expect(
        state(tester).submitStatus,
        isNot(GuestPayBillSubmitStatus.loading),
      );
    });
  }

  for (final (amount, expected) in [
    ('5', 5.0),
    ('5.00', 5.0),
    ('5.01', 5.01),
    ('16', 16.0),
  ]) {
    testWidgets('BILL-009 \$$amount continues the existing flow', (
      tester,
    ) async {
      await pumpScreen(tester);
      await verifyPostpaid(tester);
      await enterAmount(tester, amount);
      expect(find.text(_minimum), findsNothing);
      expect(state(tester).canSubmit, isTrue);
      await tapPay(tester);
      expect(confirmedAmount(), expected);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('BILL-009 error clears once the amount is corrected', (
    tester,
  ) async {
    await pumpScreen(tester);
    await verifyPostpaid(tester);
    await enterAmount(tester, '4.99');
    expect(find.text(_minimum), findsOneWidget);
    await enterAmount(tester, '5');
    expect(find.text(_minimum), findsNothing);
    await tapPay(tester);
    expect(confirmedAmount(), 5.0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('empty amount keeps its existing handling', (tester) async {
    await pumpScreen(tester);
    await verifyPostpaid(tester);
    await enterAmount(tester, '');
    expect(find.text(_minimum), findsNothing);
    expect(state(tester).canSubmit, isFalse);
  });

  testWidgets('ALIV Fibr amounts are unchanged by BILL-009', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.byType(DropdownButton<BillService>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ALIVFibr').last);
    await tester.pumpAndSettle();
    await tester.enterText(field('enter ID'), 'account-123');
    await tester.enterText(field('enter name'), 'Jane Doe');
    await tester.pump();
    await submitField(tester, field('enter name'));
    expect(state(tester).verifyStatus, GuestPayBillVerifyStatus.success);
    await enterAmount(tester, '4');
    expect(find.text(_minimum), findsNothing);
    expect(state(tester).canSubmit, isTrue);
  });

  testWidgets('BILL-003 / BILL-004 behaviour is unchanged', (tester) async {
    await pumpScreen(tester);
    await tester.enterText(phone(0), '24255');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text(_invalidNumber), findsOneWidget);
    await tester.enterText(phone(0), '');
    await tester.enterText(phone(0), '2425551234');
    await tester.enterText(phone(1), '2425551235');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text(_mismatch), findsOneWidget);
    expect(find.text(_minimum), findsNothing);
  });
}
