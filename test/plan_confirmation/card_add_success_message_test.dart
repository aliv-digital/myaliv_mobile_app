import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/addOrEditCards/prepaid/view/add_or_edit_cards_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Payment extends Mock implements CardPaymentService {}

const _success = 'Payment method added successfully!';

void main() {
  late _Cards cards;
  late SavedCardsState current;
  late Completer<bool> saved;
  late GoRouter router;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    cards = _Cards();
    current = const SavedCardsState(status: SavedCardsStatus.success);
    when(() => cards.state).thenAnswer((_) => current);
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await cards.close();
    await instance.reset();
  });

  Future<PaymentIFrameScreen> openHosted(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    saved = Completer<bool>();
    when(
      () => cards.saveNewCard(
        orderId: any(named: 'orderId'),
        expirationDate: any(named: 'expirationDate'),
      ),
    ).thenAnswer((_) => saved.future);
    final payment = _Payment();
    // Exercise the production callback owner without loading a platform WebView.
    final html = Completer<String?>();
    when(
      () => payment.fetch3DSHtml(
        url: any(named: 'url'),
        body: any(named: 'body'),
        skipAuth: any(named: 'skipAuth'),
      ),
    ).thenAnswer((_) => html.future);
    instance.registerSingleton<CardPaymentService>(payment);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.addOrEditCardsPrepaidScreen,
      routes: [
        GoRoute(
          path: AppRoutes.addOrEditCardsPrepaidScreen,
          builder: (_, _) => const AddOrEditCardsPrepaidScreen(),
        ),
      ],
    );
    addTearDown(() async {
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });
    await tester.pumpWidget(
      BlocProvider<SavedCardsCubit>.value(
        value: cards,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('add a new card'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(_success), findsNothing);
    verifyNever(
      () => cards.saveNewCard(
        orderId: any(named: 'orderId'),
        expirationDate: any(named: 'expirationDate'),
      ),
    );
    final hosted = tester.widget<PaymentIFrameScreen>(
      find.byType(PaymentIFrameScreen),
    );
    expect(hosted.request.url, Api.addCreditCard);
    return hosted;
  }

  Future<void> redirect(
    WidgetTester tester,
    PaymentIFrameScreen hosted, {
    String? orderId = '123',
    String? message,
  }) async {
    hosted.onSuccess(
      PaymentSuccess(
        orderId: orderId,
        queryParams: message == null ? const {} : {'Message': message},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('confirm expiration date'), findsOneWidget);
    expect(find.text(_success), findsNothing);
  }

  Future<void> confirmExpiry(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'save card'));
    await tester.pumpAndSettle();
  }

  Future<void> expectCardManagement(WidgetTester tester) async {
    expect(find.byType(AddOrEditCardsPrepaidScreen), findsOneWidget);
    expect(find.byType(PaymentIFrameScreen), findsNothing);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.addOrEditCardsPrepaidScreen,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  for (final message in [null, 'Gateway-specific success']) {
    testWidgets(
      'successful save uses QA copy despite redirect Message $message',
      (tester) async {
        final hosted = await openHosted(tester);
        await redirect(tester, hosted, message: message);
        await confirmExpiry(tester);
        expect(find.text(_success), findsNothing);
        final now = DateTime.now();
        verify(
          () => cards.saveNewCard(
            orderId: 123,
            expirationDate:
                '${now.month.toString().padLeft(2, '0')}${(now.year % 100).toString().padLeft(2, '0')}',
          ),
        ).called(1);
        saved.complete(true);
        await tester.pumpAndSettle();
        expect(find.text(_success), findsOneWidget);
        expect(
          find.text('your card has been added successfully'),
          findsNothing,
        );
        if (message != null) expect(find.text(message), findsNothing);
        await expectCardManagement(tester);
      },
    );
  }

  for (final orderId in [null, 'not-an-order']) {
    testWidgets('missing or invalid order ID $orderId shows no success', (
      tester,
    ) async {
      final hosted = await openHosted(tester);
      await redirect(tester, hosted, orderId: orderId);
      await confirmExpiry(tester);
      expect(find.text(_success), findsNothing);
      expect(find.text('Failed to save card. Try again.'), findsOneWidget);
      verifyNever(
        () => cards.saveNewCard(
          orderId: any(named: 'orderId'),
          expirationDate: any(named: 'expirationDate'),
        ),
      );
      await expectCardManagement(tester);
    });
  }

  testWidgets('expiry cancellation never saves or shows success', (
    tester,
  ) async {
    final hosted = await openHosted(tester);
    await redirect(tester, hosted);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text(_success), findsNothing);
    verifyNever(
      () => cards.saveNewCard(
        orderId: any(named: 'orderId'),
        expirationDate: any(named: 'expirationDate'),
      ),
    );
    await expectCardManagement(tester);
  });

  for (final error in [null, 'Existing save failure']) {
    testWidgets('save failure preserves existing message $error', (
      tester,
    ) async {
      final hosted = await openHosted(tester);
      await redirect(tester, hosted);
      await confirmExpiry(tester);
      current = current.copyWith(errorMessage: error);
      saved.complete(false);
      await tester.pumpAndSettle();
      expect(find.text(_success), findsNothing);
      expect(
        find.text(error ?? 'Failed to save card. Try again.'),
        findsOneWidget,
      );
      await expectCardManagement(tester);
    });
  }

  testWidgets('hosted failure preserves existing error and never saves', (
    tester,
  ) async {
    final hosted = await openHosted(tester);
    hosted.onFailure('Hosted card failure');
    await tester.pumpAndSettle();
    expect(find.text('Hosted card failure'), findsOneWidget);
    expect(find.text(_success), findsNothing);
    verifyNever(
      () => cards.saveNewCard(
        orderId: any(named: 'orderId'),
        expirationDate: any(named: 'expirationDate'),
      ),
    );
    await expectCardManagement(tester);
  });
}
