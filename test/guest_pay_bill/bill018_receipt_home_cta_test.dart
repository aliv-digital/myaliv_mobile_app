import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/model/guest_pay_bill_receipt_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/view/guest_pay_bill_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/bloc/guest_purchase_plan_receipt_state.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_receipt_success_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

const _title = 'Payment Success!';
const _body =
    'It will take a few moments for the payment to appear on the account.';
const _cta = 'back to home page';

const _args = GuestPayBillReceiptArgs(
  serviceName: 'ALIV Postpaid',
  identifierLabel: 'phone no.',
  identifierValue: '242-555-1234',
  amount: 16,
  dateText: 'Oct 11, 2026',
  timeText: '10:00 am',
  paymentMethod: 'credit card',
);

void main() {
  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  tearDown(AppSession.resetAppRoute);

  Future<GoRouter> pumpReceipt(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/receipt',
      routes: [
        GoRoute(
          path: '/receipt',
          builder: (_, _) => const GuestPayBillReceiptScreen(args: _args),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, _) => const Scaffold(body: Text('welcome')),
        ),
        GoRoute(
          path: AppRoutes.guestSplash,
          builder: (context, _) => Scaffold(
            body: TextButton(
              // Mirrors the guest home's back arrow (context.pop()).
              onPressed: () => context.pop(),
              child: const Text('guest home'),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.logIn,
          builder: (_, _) => const Scaffold(body: Text('login')),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('BILL-018 guest receipt shows the exact copy', (tester) async {
    await pumpReceipt(tester);
    expect(find.text(_title), findsOneWidget);
    expect(find.text(_body), findsOneWidget);
    expect(find.text(_cta), findsOneWidget);
    expect(find.text('back to login page'), findsNothing);
  });

  testWidgets('BILL-018 CTA returns a guest to the guest home', (tester) async {
    await pumpReceipt(tester);
    await tester.ensureVisible(find.text(_cta));
    await tester.tap(find.text(_cta));
    await tester.pumpAndSettle();
    expect(find.text('guest home'), findsOneWidget);
    expect(find.text('login'), findsNothing);
    expect(find.text('home'), findsNothing);
    // The guest home's own back still lands on welcome, as before.
    await tester.tap(find.text('guest home'));
    await tester.pumpAndSettle();
    expect(find.text('welcome'), findsOneWidget);
  });

  testWidgets('regular postpaidPayment receipt still goes to home', (
    tester,
  ) async {
    AppSession.appRoute = 'postpaidPayment';
    await pumpReceipt(tester);
    expect(find.text(_cta), findsOneWidget);
    await tester.ensureVisible(find.text(_cta));
    await tester.tap(find.text(_cta));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(AppSession.appRoute, isNot('postpaidPayment'));
  });

  testWidgets('shared card keeps its label when no override is passed', (
    tester,
  ) async {
    // e.g. the guest purchase-plan receipt, which is untouched.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DefaultReceiptSuccessCard(
              data: const GuestPurchasePlanReceiptData(
                leftType: 'plan',
                rightType: 'freedom',
                dateText: 'Oct 11, 2026',
                timeText: '10:00 am',
                phoneNumber: '242-555-1234',
                paymentMethod: 'credit card',
                amount: 10,
                details: [],
              ),
              onBackHome: () {},
              pageBackground: Colors.white,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('back to login page'), findsOneWidget);
  });
}
