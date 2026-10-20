import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/view/guest_pay_bill_confirm_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/widgets/guest_pay_bill_confirm_terms_row.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/model/guest_pay_bill_receipt_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/view/guest_pay_bill_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/model/guest_pay_bill_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/widgets/guest_pay_bill_primary_submit_button.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Analytics extends Mock implements AnalyticsService {}

const _pending =
    'It will take a few moments for the payment to appear on the account.';

void main() {
  late _Network network;
  late _Analytics analytics;
  late Completer<Response<dynamic>> payment;
  late GoRouter router;
  GuestPayBillConfirmArgs? confirmation;
  GuestPayBillReceiptArgs? receipt;
  Map<String, dynamic>? submitted;
  var receipts = 0;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    network = _Network();
    analytics = _Analytics();
    confirmation = null;
    receipt = null;
    submitted = null;
    receipts = 0;
    AppSession.resetAppRoute();
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AnalyticsService>(analytics);
    when(
      () => analytics.logBillPayment(
        amount: any(named: 'amount'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenAnswer((_) async {});
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
        data: {'id_acc': 77, 'Balance': 250.0, 'AccountStatus': 'AC'},
      ),
    );
    when(
      () => network.request<dynamic>(
        Api.guestFibrPayUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((invocation) {
      submitted = invocation.namedArguments[#data] as Map<String, dynamic>;
      return payment.future;
    });
  });

  tearDown(() async {
    router.dispose();
    AppSession.resetAppRoute();
    await instance.reset();
  });

  Finder field(String hint) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint,
  );
  Finder success() => find.textContaining('Your payment of');

  Future<void> open(WidgetTester tester, {double width = 390}) async {
    payment = Completer<Response<dynamic>>();
    tester.view.physicalSize = Size(width, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.guestPayBill,
      routes: [
        GoRoute(
          path: AppRoutes.guestPayBill,
          builder: (_, _) => const GuestPayBillScreen(),
        ),
        GoRoute(
          path: AppRoutes.guestPayBillConfirm,
          builder: (_, state) {
            confirmation = state.extra! as GuestPayBillConfirmArgs;
            return GuestPayBillConfirmScreen(args: confirmation!);
          },
        ),
        GoRoute(
          path: AppRoutes.guestPayBillReceipt,
          builder: (_, state) {
            receipts++;
            receipt = state.extra! as GuestPayBillReceiptArgs;
            return GuestPayBillReceiptScreen(args: receipt!);
          },
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, _) => const Scaffold(body: Text('welcome')),
        ),
        GoRoute(
          path: AppRoutes.guestSplash,
          builder: (_, _) => const Scaffold(body: Text('existing guest home')),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('existing home')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<BillService>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ALIVFibr').last);
    await tester.pumpAndSettle();
  }

  Future<void> lookup(WidgetTester tester, String account) async {
    await tester.enterText(field('enter ID'), account);
    await tester.enterText(field('enter name'), 'Jane Doe');
    await tester.pump();
    await tester.showKeyboard(field('enter name'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(success(), findsNothing);
    expect(receipts, 0);
    expect(find.text(r'$250.00'), findsOneWidget);
  }

  Future<void> confirm(WidgetTester tester, String amount) async {
    await tester.enterText(field(r'$ 0.00'), amount);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final submit = find.descendant(
      of: find.byType(GuestPayBillPrimarySubmitButton),
      matching: find.byType(ElevatedButton),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(success(), findsNothing);
    final terms = find
        .descendant(
          of: find.byType(GuestPayBillConfirmTermsRow),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
  }

  Future<void> pay(WidgetTester tester) async {
    await tester.enterText(field('name on card'), 'Jane Doe');
    await tester.enterText(field('0000 0000 0000 0000'), '4111111111111111');
    await tester.enterText(field('MM/YY'), '1235');
    await tester.enterText(field('123'), '123');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('confirm payment'));
    await tester.tap(find.text('confirm payment'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(success(), findsNothing);
    expect(receipts, 0);
    expect(submitted, isNotNull);
  }

  Future<void> finish(WidgetTester tester, Object? data) async {
    payment.complete(
      Response<dynamic>(
        requestOptions: RequestOptions(path: Api.guestFibrPayUrl),
        data: data,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  for (final (account, amount, formatted) in [
    ('348340572044', '200.00', r'$200.00'),
    ('123456789', '12.50', r'$12.50'),
    ('fibr-user', '100.00', r'$100.00'),
  ]) {
    testWidgets('ALIVFibr $account pays custom $amount instead of amount due', (
      tester,
    ) async {
      await open(tester, width: amount == '12.50' ? 320 : 390);
      await lookup(tester, ' $account ');
      verify(
        () => network.request<dynamic>(
          Api.guestFibrBalanceUrl,
          method: HttpMethod.post,
          data: {
            'ChannelType': 'SelfCare',
            'FibrName': 'JANE DOE',
            'FibrAccountID': account,
          },
          options: any(named: 'options'),
        ),
      ).called(1);
      await confirm(tester, amount);
      expect(confirmation!.identifierValue, account);
      expect(confirmation!.amount, double.parse(amount));
      await pay(tester);
      expect(submitted!['FibrAccountID'], 77);
      expect(
        (submitted!['CardPayment'] as Map)['Amount'],
        double.parse(amount),
      );
      await finish(tester, {'OrderId': 123});
      expect(
        find.text(
          'Your payment of $formatted has been successfully processed for account $account',
        ),
        findsOneWidget,
      );
      expect(find.text(_pending), findsNothing);
      expect(receipt!.identifierValue, account);
      expect(find.text('account no.'), findsOneWidget);
      expect(find.text('Acc #'), findsNothing);
      expect(receipt!.amount, (submitted!['CardPayment'] as Map)['Amount']);
      expect(receipts, 1);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('back to home page'));
      await tester.tap(find.text('back to home page'));
      await tester.pumpAndSettle();
      expect(find.text('existing guest home'), findsOneWidget);
    });
  }

  for (final response in [
    null,
    'malformed',
    {},
    {'OrderId': 0},
    {'OrderId': -1},
    {'OrderId': '123'},
  ]) {
    testWidgets('ALIVFibr invalid payment response $response keeps failure', (
      tester,
    ) async {
      await open(tester);
      await lookup(tester, '123456789');
      await confirm(tester, '12.50');
      await pay(tester);
      await finish(tester, response);
      expect(success(), findsNothing);
      expect(receipts, 0);
      expect(find.text('Payment failed. Please try again.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('ALIVFibr payment API error keeps the existing failure', (
    tester,
  ) async {
    await open(tester);
    await lookup(tester, '123456789');
    await confirm(tester, '12.50');
    await pay(tester);
    payment.completeError(Exception('Network unavailable'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(success(), findsNothing);
    expect(receipts, 0);
    expect(find.text('Network unavailable'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'ALIVFibr checkout cancellation does not submit or show success',
    (tester) async {
      await open(tester);
      await lookup(tester, '123456789');
      await confirm(tester, '12.50');
      Navigator.of(tester.element(field('name on card'))).pop();
      await tester.pumpAndSettle();
      expect(submitted, isNull);
      expect(success(), findsNothing);
      expect(receipts, 0);
    },
  );

  for (final amount in ['', '0']) {
    testWidgets('ALIVFibr amount "$amount" retains disabled submit', (
      tester,
    ) async {
      await open(tester);
      await lookup(tester, '123456789');
      await tester.enterText(field(r'$ 0.00'), amount);
      await tester.pumpAndSettle();
      final submit = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byType(GuestPayBillPrimarySubmitButton),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(submit.onPressed, isNull);
      expect(confirmation, isNull);
      expect(submitted, isNull);
      expect(success(), findsNothing);
    });
  }

  testWidgets(
    'ALIVFibr failed lookup retains its error and blocks continuation',
    (tester) async {
      when(
        () => network.request<dynamic>(
          Api.guestFibrBalanceUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(Exception('Account not found'));
      await open(tester);
      await tester.enterText(field('enter ID'), 'invalid-account');
      await tester.enterText(field('enter name'), 'Jane Doe');
      await tester.pump();
      await tester.showKeyboard(field('enter name'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(
        find.text('Account not found. Please check details.'),
        findsOneWidget,
      );
      expect(confirmation, isNull);
      expect(submitted, isNull);
      expect(success(), findsNothing);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    },
  );
}
