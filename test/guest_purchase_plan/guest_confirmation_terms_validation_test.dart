import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/view/guest_purchase_plan_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/bloc/guest_purchase_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/view/guest_purchase_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/widgets/terms_notice.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/view/guest_purchase_plan_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

class _NavigationObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

const _message = 'accept the terms & conditions to continue';
const _purchased = 'The plan was purchased successfully.';
const _plan = GuestPlanDisplayModel(
  id: '70',
  title: 'liberty70',
  subtitle: '',
  price: 70,
  formattedPrice: '\$70.00',
  basePrice: 70,
  vatAmount: 0,
  description: '',
  highlights: [],
  benefits: [],
);

GuestPurchasePlanConfirmationRouteArgs _args({
  bool forceNow = true,
  GuestPurchasePlanConfirmationEntryFlow flow =
      GuestPurchasePlanConfirmationEntryFlow.proceed,
}) => GuestPurchasePlanConfirmationRouteArgs(
  phoneNumber: '242-801-1616',
  accountHolderName: 'guest purchase a plan',
  primaryPlanName: 'liberty70',
  primaryPlanPrice: 70,
  flow: flow,
  selectedPlan: _plan,
  forceNow: forceNow,
  futurePlanStartDate: forceNow ? '' : '01-11-26',
  selectedAddOns: const [
    GuestPurchasePlanConfirmationSelectedAddOn(
      id: 'a1',
      title: 'liberty data 1',
      price: 5,
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Network network;
  late _Auth auth;
  late _NavigationObserver observer;

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
    network = _Network();
    auth = _Auth();
    observer = _NavigationObserver();
    when(() => auth.currentSession).thenReturn(null);
    when(
      () => network.request<dynamic>(
        Api.guestPurchasePlanUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.guestPurchasePlanUrl),
        statusCode: 200,
        // No bank HTML: exercise the existing action without a native WebView.
        data: <String, dynamic>{},
      ),
    );
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<CardPaymentService>(
      CardPaymentService(networkService: network),
    );
  });

  tearDown(() async => instance.reset());

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    double width = 390,
    bool forceNow = true,
    GuestPurchasePlanConfirmationEntryFlow flow =
        GuestPurchasePlanConfirmationEntryFlow.proceed,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      observers: [observer],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => GuestPurchasePlanConfirmationScreen(
            args: _args(forceNow: forceNow, flow: flow),
          ),
        ),
        GoRoute(
          path: AppRoutes.guestPurchasePlanReceipt,
          builder: (_, state) {
            final extra = state.extra! as Map;
            return GuestPurchasePlanReceiptScreen(
              phoneNumber: extra['phoneNumber'] as String,
              amount: extra['amount'] as double,
              dateText: extra['dateText'] as String,
              timeText: extra['timeText'] as String,
              planName: extra['planName'] as String?,
              addOnNames: extra['addOnNames'] as List<String>,
              emailAddress: extra['emailAddress'] as String,
              orderId: extra['orderId'] as String?,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.logIn,
          builder: (_, _) => const Scaffold(body: Text('login')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> toggleTerms(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(TermsNotice));
    await tester.tap(
      find.descendant(
        of: find.byType(TermsNotice),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<PaymentIFrameScreen> startPayment(WidgetTester tester) async {
    expect(find.text(_purchased), findsNothing);
    await toggleTerms(tester);
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
    expect(find.text(_purchased), findsNothing);
    return tester.widget<PaymentIFrameScreen>(find.byType(PaymentIFrameScreen));
  }

  for (final forceNow in [true, false]) {
    testWidgets(
        'confirmed Guest purchase shows one success (forceNow: $forceNow)', (
      tester,
    ) async {
      final router = await pumpScreen(tester, forceNow: forceNow);
      final payment = await startPayment(tester);
      payment
          .onSuccess(const PaymentSuccess(orderId: '804441', queryParams: {}));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.last.route.path,
          AppRoutes.guestPurchasePlanReceipt);
      expect(find.text(_purchased), findsOneWidget);
      expect(
          find.text(
              'It will take a few moments for the plan to appears on the account.'),
          findsNothing);
      expect(find.byType(PaymentIFrameScreen), findsNothing);
      final receipt = tester.widget<GuestPurchasePlanReceiptScreen>(
          find.byType(GuestPurchasePlanReceiptScreen));
      expect(receipt.orderId, '804441');
      expect(receipt.phoneNumber, '242-801-1616');
      expect(receipt.amount, 75);
      expect(receipt.planName, 'liberty70');
      expect(receipt.addOnNames, ['liberty data 1']);
      verify(() => network.request<dynamic>(Api.guestPurchasePlanUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
          options: any(named: 'options'))).called(1);
      await tester.ensureVisible(find.text('back to login page'));
      await tester.tap(find.text('back to login page'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.logIn);
      expect(find.text('login'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final orderId in [null, '', '0', '-1', 'invalid']) {
    testWidgets(
        'unconfirmed Guest order "$orderId" never reports purchase success', (
      tester,
    ) async {
      final router = await pumpScreen(tester);
      final payment = await startPayment(tester);
      payment
          .onSuccess(PaymentSuccess(orderId: orderId, queryParams: const {}));
      await tester.pumpAndSettle();
      expect(find.text('Payment could not be confirmed. Please try again.'),
          findsOneWidget);
      expect(find.text(_purchased), findsNothing);
      expect(find.byType(GuestPurchasePlanReceiptScreen), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final failure in [
    'Payment declined',
    'Purchase failed',
    'Network unavailable'
  ]) {
    testWidgets(
        'Guest failure "$failure" preserves its message without success', (
      tester,
    ) async {
      final router = await pumpScreen(tester);
      final payment = await startPayment(tester);
      payment.onFailure(failure);
      await tester.pumpAndSettle();
      expect(find.text(failure), findsOneWidget);
      expect(find.text(_purchased), findsNothing);
      expect(find.text('The number you entered is invalid'), findsNothing);
      expect(find.byType(GuestPurchasePlanReceiptScreen), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/');
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final orderId in [null, '0']) {
    testWidgets(
        'receipt without confirmed order "$orderId" keeps its prior copy', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(
          home: GuestPurchasePlanReceiptScreen(
        phoneNumber: '242-801-1616',
        amount: 75,
        dateText: 'Oct 13, 2026',
        timeText: '10:00 am',
        orderId: orderId,
      )));
      await tester.pumpAndSettle();
      expect(find.text(_purchased), findsNothing);
      expect(
          find.text(
              'It will take a few moments for the plan to appears on the account.'),
          findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
      'catalogue loading and plan selection never report purchase success', (
    tester,
  ) async {
    when(() => network.request<dynamic>(
          Api.guestAvailablePlansUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: Api.guestAvailablePlansUrl),
          statusCode: 200,
          data: [
            <String, dynamic>{
              'PlanID': '30',
              'PlanName': 'freedom30',
              'PlanDescription': '30-day plan',
              'PlanAmount': 30,
              'VATAmount': '3.00',
              'PlanType': 'P',
              'Frequency': 'M',
              'PaymentOption': 'PrePay',
              'PlanGroup': '',
              'PlanBuckets': <Map<String, dynamic>>[],
            }
          ],
        ));
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: GuestPurchasePlanScreen(phoneNumber: '242-801-1616')));
    await tester.pumpAndSettle();
    expect(find.text(_purchased), findsNothing);
    await tester.ensureVisible(find.text('purchase now'));
    await tester.tap(find.text('purchase now'));
    await tester.pumpAndSettle();
    expect(find.text('activate now'), findsOneWidget);
    expect(find.text(_purchased), findsNothing);
    verifyNever(() => network.request<dynamic>(
          Api.guestPurchasePlanUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('Guest inline terms validation and clearing at $width', (
      tester,
    ) async {
      final router = await pumpScreen(tester, width: width);
      final bloc = tester
          .element(find.byType(TermsNotice))
          .read<GuestPurchasePlanConfirmationBloc>();
      final initialState = bloc.state;
      expect(
        tester.widget<TermsNotice>(find.byType(TermsNotice)).isChecked,
        false,
      );
      expect(find.text(_message), findsNothing);
      expect(
        tester
            .widget<DefaultBottomPayBar>(find.byType(DefaultBottomPayBar))
            .isButtonEnabled,
        isTrue,
      );
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      final pushes = observer.pushes;

      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(find.text('pay now'));
        await tester.pumpAndSettle();
        expect(find.text(_message), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.text(_message),
          ),
          findsOneWidget,
        );
        expect(bloc.state, initialState);
        expect(bloc.state.payNowRequestId, 0);
        expect(observer.pushes, pushes);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.byType(PaymentIFrameScreen), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
        expect(find.byType(Dialog), findsNothing);
        verifyZeroInteractions(network);

        final error = tester.widget<Text>(find.text(_message));
        expect(error.style!.fontFamily, 'CircularPro');
        expect(error.style!.fontSize, 12);
        expect(
          error.style!.color,
          Theme.of(tester.element(find.text(_message))).colorScheme.error,
        );
        await toggleTerms(tester);
        expect(find.text(_message), findsNothing);
        expect(bloc.state.isTermsChecked, isTrue);
        await toggleTerms(tester);
        expect(find.text(_message), findsNothing);
        expect(bloc.state.isTermsChecked, isFalse);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final forceNow in [true, false]) {
    testWidgets(
      'checked Guest pay keeps existing request (forceNow: $forceNow)',
      (tester) async {
        await pumpScreen(tester, forceNow: forceNow);
        await tester.tap(find.text('pay now'));
        await tester.pumpAndSettle();
        verifyZeroInteractions(network);
        await toggleTerms(tester);
        expect(find.text(_message), findsNothing);
        await tester.tap(find.text('pay now'));
        await tester.pumpAndSettle();
        final payment = tester.widget<PaymentIFrameScreen>(
          find.byType(PaymentIFrameScreen),
        );
        final expectedBody = <String, dynamic>{
          'Bundle': <String, dynamic>{
            'PrimaryPlans': [70],
            'SecondaryPlans': <int>[],
            'StandalonePlans': <int>[],
            if (!forceNow) 'StartDate': '2026-11-01 00:00',
          },
          'ForceNow': forceNow,
          'ChannelType': 'SelfCare',
          'RedirectURL': 'myaliv://topup-callback',
          'Branch': 'branch',
          'PhoneNumber': '2428011616',
        };
        expect(payment.request.url, Api.guestPurchasePlanUrl);
        expect(payment.request.body, expectedBody);
        expect(payment.request.skipAuth, isTrue);
        expect(payment.request.redirectScheme, 'myaliv');
        final call = verify(
          () => network.request<dynamic>(
            Api.guestPurchasePlanUrl,
            method: HttpMethod.post,
            data: captureAny(named: 'data'),
            options: captureAny(named: 'options'),
          ),
        )..called(1);
        expect(call.captured[0], expectedBody);
        expect((call.captured[1] as Options).extra, {'skipAuth': true});
        verifyNoMoreInteractions(network);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('Guest skip entry preserves its existing checked default', (
    tester,
  ) async {
    await pumpScreen(tester, flow: GuestPurchasePlanConfirmationEntryFlow.skip);
    expect(
      tester.widget<TermsNotice>(find.byType(TermsNotice)).isChecked,
      true,
    );
    expect(find.text(_message), findsNothing);
    verifyZeroInteractions(network);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Guest Terms link opens the unchanged prepaid modal', (
    tester,
  ) async {
    final requests = <http.Request>[];
    await http.runWithClient(
      () async {
        await pumpScreen(tester);
        await tester.tap(find.text('pay now'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(TermsNotice));
        final richText = find.descendant(
          of: find.byType(TermsNotice),
          matching: find.byType(RichText),
        );
        final paragraph = tester.renderObject<RenderParagraph>(richText);
        final text = paragraph.text.toPlainText();
        final start = text.indexOf('Terms & Conditions.');
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: start + 5),
        );
        await tester.tapAt(
          paragraph.localToGlobal(boxes.first.toRect().center),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TermsAndConditionsDialog), findsOneWidget);
        expect(find.text('Terms & Conditions'), findsOneWidget);
        expect(requests.single.url.toString(), Api.prepaidTermsConditions);
        expect(requests.single.method, 'GET');
        expect(
          tester.widget<TermsNotice>(find.byType(TermsNotice)).isChecked,
          false,
        );
        verifyZeroInteractions(network);
        await tester.tap(find.byType(TermsDialogCloseButton));
        await tester.pumpAndSettle();
        expect(find.byType(TermsAndConditionsDialog), findsNothing);
        expect(find.text(_message), findsOneWidget);
        await toggleTerms(tester);
        expect(find.text(_message), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient((request) async {
        requests.add(request);
        return http.Response(
          '{"success":true,"data":{"value":"<p>Terms</p>"}}',
          200,
        );
      }),
    );
  });
}
