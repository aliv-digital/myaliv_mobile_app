import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/view/guest_pay_bill_confirm_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/model/guest_pay_bill_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/theme/guest_pay_bill_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/widgets/guest_pay_bill_primary_submit_button.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  late _MockNetworkService networkService;
  late GoRouter router;
  GuestPayBillConfirmArgs? confirmationArgs;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    networkService = _MockNetworkService();
    confirmationArgs = null;
    AppSession.resetAppRoute();
    instance.registerSingleton<NetworkService>(networkService);
  });

  tearDown(() async {
    router.dispose();
    AppSession.resetAppRoute();
    await instance.reset();
  });

  Finder fieldByHint(String hint) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint,
  );

  void stubFibrBalance({dynamic accountStatus, double balance = 150.0}) {
    when(
      () => networkService.request<dynamic>(
        Api.guestFibrBalanceUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.guestFibrBalanceUrl),
        data: <String, dynamic>{
          'id_acc': 1001,
          'Balance': balance,
          if (accountStatus != null) 'AccountStatus': accountStatus,
        },
      ),
    );
  }

  void stubPostpaidBalance({
    String accountStatus = 'AC',
    String paymentOption = 'PostPay',
    double balance = 80.0,
  }) {
    when(
      () => networkService.request<dynamic>(
        Api.guestBalanceUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.guestBalanceUrl),
        data: <String, dynamic>{
          'Balance': balance,
          'AccountStatus': accountStatus,
          'PaymentOption': paymentOption,
        },
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
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
            confirmationArgs = state.extra as GuestPayBillConfirmArgs?;
            return GuestPayBillConfirmScreen(args: confirmationArgs!);
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  Future<void> selectAlivFibr(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownButton<BillService>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ALIVFibr').last);
    await tester.pumpAndSettle();
  }

  Future<void> verifyFibrAccount(
    WidgetTester tester, {
    String account = '25161463',
    String name = 'Jane Doe',
  }) async {
    await tester.enterText(fieldByHint('enter ID'), account);
    await tester.enterText(fieldByHint('enter name'), name);
    await tester.pump();
    await tester.showKeyboard(fieldByHint('enter name'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> enterAmountAndSubmit(WidgetTester tester, String amount) async {
    await tester.enterText(fieldByHint(r'$ 0.00'), amount);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final submitButton = find.descendant(
      of: find.byType(GuestPayBillPrimarySubmitButton),
      matching: find.byType(ElevatedButton),
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  group('GAF-1004: AlivFibr Account Status Validation', () {
    testWidgets(
      'AC (Active) status allows submission and proceeds to confirm',
      (tester) async {
        stubFibrBalance(accountStatus: 'AC', balance: 150.0);

        await pumpScreen(tester);
        await selectAlivFibr(tester);
        await verifyFibrAccount(tester);

        expect(find.text(r'$150.00'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);

        await enterAmountAndSubmit(tester, '50');

        // Successfully redirected to confirmation screen
        expect(confirmationArgs, isNotNull);
        expect(confirmationArgs!.serviceName, 'ALIVFibr');
        expect(confirmationArgs!.amount, 50.0);
        expect(find.byType(GuestPayBillConfirmScreen), findsOneWidget);
      },
    );

    final rejectedStatuses = <String, String>{
      'SU': 'suspended',
      'DC': 'disconnected',
      'PF': 'pending disconnect',
      'CB': 'call barred',
      'CL': 'closed',
    };

    for (final entry in rejectedStatuses.entries) {
      final code = entry.key;
      final label = entry.value;

      testWidgets(
        '$code ($label) blocks submission and displays error without navigation',
        (tester) async {
          stubFibrBalance(accountStatus: code, balance: 100.0);

          await pumpScreen(tester);
          await selectAlivFibr(tester);
          await verifyFibrAccount(tester);

          expect(find.text(label), findsOneWidget);

          await enterAmountAndSubmit(tester, '40');

          // Blocks navigation and shows error
          expect(confirmationArgs, isNull);
          expect(find.byType(GuestPayBillConfirmScreen), findsNothing);
          expect(
            find.text(GuestPayBillTheme.invalidActiveFibrErrorMessage),
            findsOneWidget,
          );
          await tester.pump(const Duration(seconds: 4));
        },
      );
    }

    testWidgets('null AccountStatus blocks submission and displays error', (
      tester,
    ) async {
      stubFibrBalance(accountStatus: null, balance: 100.0);

      await pumpScreen(tester);
      await selectAlivFibr(tester);
      await verifyFibrAccount(tester);

      await enterAmountAndSubmit(tester, '30');

      expect(confirmationArgs, isNull);
      expect(find.byType(GuestPayBillConfirmScreen), findsNothing);
      expect(
        find.text(GuestPayBillTheme.invalidActiveFibrErrorMessage),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('empty AccountStatus blocks submission and displays error', (
      tester,
    ) async {
      stubFibrBalance(accountStatus: '', balance: 100.0);

      await pumpScreen(tester);
      await selectAlivFibr(tester);
      await verifyFibrAccount(tester);

      await enterAmountAndSubmit(tester, '30');

      expect(confirmationArgs, isNull);
      expect(find.byType(GuestPayBillConfirmScreen), findsNothing);
      expect(
        find.text(GuestPayBillTheme.invalidActiveFibrErrorMessage),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('unrecognized status blocks submission and displays error', (
      tester,
    ) async {
      stubFibrBalance(accountStatus: 'UNKNOWN_CODE', balance: 100.0);

      await pumpScreen(tester);
      await selectAlivFibr(tester);
      await verifyFibrAccount(tester);

      await enterAmountAndSubmit(tester, '30');

      expect(confirmationArgs, isNull);
      expect(find.byType(GuestPayBillConfirmScreen), findsNothing);
      expect(
        find.text(GuestPayBillTheme.invalidActiveFibrErrorMessage),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('repeated invalid submissions display error on each attempt', (
      tester,
    ) async {
      stubFibrBalance(accountStatus: 'SU', balance: 100.0);

      await pumpScreen(tester);
      await selectAlivFibr(tester);
      await verifyFibrAccount(tester);

      await enterAmountAndSubmit(tester, '25');

      expect(confirmationArgs, isNull);
      expect(
        find.text(GuestPayBillTheme.invalidActiveFibrErrorMessage),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));

      // Re-tap submit
      final submitButton = find.descendant(
        of: find.byType(GuestPayBillPrimarySubmitButton),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(confirmationArgs, isNull);
      expect(
        find.text(GuestPayBillTheme.invalidActiveFibrErrorMessage),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets(
      'ALIV Postpaid validation remains intact for active vs non-active accounts',
      (tester) async {
        stubPostpaidBalance(
          accountStatus: 'SU',
          paymentOption: 'PostPay',
          balance: 60.0,
        );

        await pumpScreen(tester);
        // Default selected service is ALIV Postpaid
        await tester.enterText(find.byType(TextField).at(0), '2425551234');
        await tester.enterText(find.byType(TextField).at(1), '2425551234');
        await tester.pump();
        await tester.showKeyboard(find.byType(TextField).at(1));
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        await enterAmountAndSubmit(tester, '20');

        // Postpaid still rejects SU with its own error message
        expect(confirmationArgs, isNull);
        expect(find.byType(GuestPayBillConfirmScreen), findsNothing);
        expect(
          find.text(GuestPayBillTheme.invalidActivePostpaidErrorMessage),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });
}
