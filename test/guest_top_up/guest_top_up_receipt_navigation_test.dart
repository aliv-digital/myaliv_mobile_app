import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/view/guest_top_up_receipt_screen.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  tearDown(() {
    AppSession.resetAppRoute();
    if (AppSession.isTopUp == true) {
      AppSession.resetFlagForTopUp();
    }
  });

  Future<void> pumpReceipt(
    WidgetTester tester, {
    bool isPaymentFailed = false,
  }) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/receipt',
      routes: [
        GoRoute(
          path: '/receipt',
          builder: (_, _) => GuestTopUpReceiptScreen(
            phoneNumber: '242-555-1234',
            amount: 15.0,
            dateText: 'Nov 4, 2026',
            timeText: '8:00 pm',
            isPaymentFailed: isPaymentFailed,
          ),
        ),
        GoRoute(
          path: AppRoutes.logIn,
          builder: (_, _) => const Scaffold(body: Text('login page screen')),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('home screen')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'guest topup payment success shows "back to login page" and redirects to login',
    (tester) async {
      await pumpReceipt(tester, isPaymentFailed: false);

      expect(find.text('back to login page'), findsOneWidget);
      expect(find.text('back to home page'), findsNothing);

      await tester.tap(find.text('back to login page'));
      await tester.pumpAndSettle();

      expect(find.text('login page screen'), findsOneWidget);
    },
  );

  testWidgets(
    'guest topup payment failed shows "back to login page" and redirects to login',
    (tester) async {
      await pumpReceipt(tester, isPaymentFailed: true);

      expect(find.text('back to login page'), findsOneWidget);
      expect(find.text('back to home page'), findsNothing);

      await tester.tap(find.text('back to login page'));
      await tester.pumpAndSettle();

      expect(find.text('login page screen'), findsOneWidget);
    },
  );

  testWidgets(
    'authenticated sendTopUp payment success shows "back to home page" and redirects to home',
    (tester) async {
      AppSession.appRoute = 'sendTopUp';

      await pumpReceipt(tester, isPaymentFailed: false);

      expect(find.text('back to home page'), findsOneWidget);
      expect(find.text('back to login page'), findsNothing);

      await tester.tap(find.text('back to home page'));
      await tester.pumpAndSettle();

      expect(find.text('home screen'), findsOneWidget);
    },
  );

  testWidgets(
    'authenticated sendTopUp payment failed shows "back to home page" and redirects to home',
    (tester) async {
      AppSession.appRoute = 'sendTopUp';

      await pumpReceipt(tester, isPaymentFailed: true);

      expect(find.text('back to home page'), findsOneWidget);
      expect(find.text('back to login page'), findsNothing);

      await tester.tap(find.text('back to home page'));
      await tester.pumpAndSettle();

      expect(find.text('home screen'), findsOneWidget);
    },
  );
}

