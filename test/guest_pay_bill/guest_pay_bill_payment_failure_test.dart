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
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/widgets/receipt_failure_card.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_receipt_success_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

const _confirmArgs = GuestPayBillConfirmArgs(
  serviceName: 'ALIV Postpaid',
  identifierLabel: 'phone no.',
  identifierValue: '242-801-1616',
  amount: 45.0,
);

void main() {
  late _Network network;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    network = _Network();
    when(
      () => network.request<dynamic>(
        Api.guestBillPay3DSUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.guestBillPay3DSUrl),
        statusCode: 200,
        data: <String, dynamic>{},
      ),
    );

    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<CardPaymentService>(
      CardPaymentService(networkService: network),
    );
  });

  tearDown(() async {
    AppSession.resetAppRoute();
    await instance.reset();
  });

  Future<GoRouter> pumpConfirmScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const GuestPayBillConfirmScreen(args: _confirmArgs),
        ),
        GoRoute(
          path: AppRoutes.guestPayBillReceipt,
          builder: (_, state) {
            final args = state.extra! as GuestPayBillReceiptArgs;
            return GuestPayBillReceiptScreen(args: args);
          },
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, _) => const Scaffold(body: Text('welcome')),
        ),
        GoRoute(
          path: AppRoutes.guestSplash,
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(),
              child: const Text('guest home'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    return router;
  }

  Future<PaymentIFrameScreen> startPayment(WidgetTester tester) async {
    // Check Terms checkbox to enable pay button
    await tester.ensureVisible(find.byType(GuestPayBillConfirmTermsRow));
    await tester.tap(
      find
          .descendant(
            of: find.byType(GuestPayBillConfirmTermsRow),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pumpAndSettle();

    // Tap Pay Now
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();

    return tester.widget<PaymentIFrameScreen>(find.byType(PaymentIFrameScreen));
  }

  testWidgets(
    '3DS failure navigates to failure receipt and returns to guest home',
    (tester) async {
      await pumpConfirmScreen(tester);
      final payment = await startPayment(tester);

      payment.onFailure('Payment declined');
      await tester.pumpAndSettle();

      expect(find.byType(PaymentIFrameScreen), findsNothing);
      expect(find.byType(GuestPayBillReceiptScreen), findsOneWidget);
      expect(find.byType(ReceiptFailureCard), findsOneWidget);
      expect(find.byType(DefaultReceiptSuccessCard), findsNothing);
      expect(find.text('Payment Failed'), findsOneWidget);
      expect(
        find.text('There was a problem processing\nyour order.'),
        findsOneWidget,
      );
      expect(find.text('back to home page'), findsOneWidget);

      await tester.ensureVisible(find.text('back to home page'));
      await tester.tap(find.text('back to home page'));
      await tester.pumpAndSettle();

      expect(find.text('guest home'), findsOneWidget);
    },
  );

  for (final orderId in [null, '', '0', '-1']) {
    testWidgets('unconfirmed 3DS order "$orderId" shows failure receipt', (
      tester,
    ) async {
      await pumpConfirmScreen(tester);
      final payment = await startPayment(tester);

      payment.onSuccess(
        PaymentSuccess(orderId: orderId, queryParams: const {}),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaymentIFrameScreen), findsNothing);
      expect(find.byType(GuestPayBillReceiptScreen), findsOneWidget);
      expect(find.byType(ReceiptFailureCard), findsOneWidget);
      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('back to home page'), findsOneWidget);
    });
  }

  testWidgets('confirmed 3DS order shows success receipt', (tester) async {
    await pumpConfirmScreen(tester);
    final payment = await startPayment(tester);

    payment.onSuccess(const PaymentSuccess(orderId: '804441', queryParams: {}));
    await tester.pumpAndSettle();

    expect(find.byType(PaymentIFrameScreen), findsNothing);
    expect(find.byType(GuestPayBillReceiptScreen), findsOneWidget);
    expect(find.byType(DefaultReceiptSuccessCard), findsOneWidget);
    expect(find.byType(ReceiptFailureCard), findsNothing);
    expect(find.text('Payment Success!'), findsOneWidget);
    expect(find.text('back to home page'), findsOneWidget);

    await tester.ensureVisible(find.text('back to home page'));
    await tester.tap(find.text('back to home page'));
    await tester.pumpAndSettle();

    expect(find.text('guest home'), findsOneWidget);
  });
}
