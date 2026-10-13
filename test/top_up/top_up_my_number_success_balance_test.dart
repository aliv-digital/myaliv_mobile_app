import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/view/user_profile_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/bloc/top_up_payment_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/bloc/top_up_payment_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/view/top_up_payment_screen.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/top_up_payment_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _TopUpService extends Mock implements TopUpPaymentService {}

class _CardService extends Mock implements CardPaymentService {}

const _card = SavedCardModel(token: 'token', number: '********1234');
const _prefix = 'Top-up complete! Your balance is now ';
const _ownPhone = '2428011616';

BalanceState _balanceState(double amount) => BalanceState(
      status: BalanceStatus.loaded,
      balance: BalanceModel(
        walletBalance: amount,
        bonusBalance: 50,
        bonusDetails: const [],
        fetchedAt: DateTime(2026, 10, 13),
      ),
    );

void main() {
  late _Account account;
  late _Cards cards;
  late _Balance balance;
  late _TopUpService topUp;
  late _CardService cardService;
  late Completer<ChangeBundleResult> payment;
  late TopUpPaymentPrepaidBloc bloc;
  late GoRouter router;
  late int receipts;
  UserProfileReceiptRouteArgs? receiptArgs;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });

  setUp(() {
    account = _Account();
    cards = _Cards();
    balance = _Balance();
    topUp = _TopUpService();
    cardService = _CardService();
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(primaryPhoneNumber: _ownPhone),
      ),
    );
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<SavedCardsCubit>(cards);
    instance.registerSingleton<BalanceCubit>(balance);
    instance.registerSingleton<TopUpPaymentService>(topUp);
    instance.registerSingleton<CardPaymentService>(cardService);
    receipts = 0;
    receiptArgs = null;
  });

  tearDown(() async {
    await account.close();
    await cards.close();
    await balance.close();
    await instance.reset();
  });

  Future<void> openPayment(
    WidgetTester tester, {
    double before = 10,
    double amount = 5,
    UserType userType = UserType.prepaid,
    String? recipient,
    bool hasBalance = true,
    double width = 390,
  }) async {
    payment = Completer<ChangeBundleResult>();
    final html = Completer<String?>();
    when(() => balance.state).thenReturn(
      hasBalance ? _balanceState(before) : BalanceState.initial(),
    );
    when(
      () => topUp.payWithSavedCard(
        amount: any(named: 'amount'),
        primaryPhoneNumber: any(named: 'primaryPhoneNumber'),
        cardToken: any(named: 'cardToken'),
      ),
    ).thenAnswer((_) => payment.future);
    // Keep the iframe at HTML loading; exercise its production success/failure
    // callback without constructing a platform WebView or making network calls.
    when(
      () => cardService.fetch3DSHtml(
        url: any(named: 'url'),
        body: any(named: 'body'),
        skipAuth: any(named: 'skipAuth'),
      ),
    ).thenAnswer((_) => html.future);
    final cardStates = StreamController<SavedCardsState>.broadcast();
    addTearDown(cardStates.close);
    whenListen(cards, cardStates.stream,
        initialState: const SavedCardsState(status: SavedCardsStatus.loading));
    final config = AppUiConfigCubit(
      initialConfig: HomeUiConfig(
        userType: userType,
        hasActivePlan: true,
        isFuturePlan: false,
      ),
    );
    addTearDown(config.close);
    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.topUpPaymentPrepaidScreen,
      routes: [
        GoRoute(
          path: AppRoutes.topUpPaymentPrepaidScreen,
          builder: (_, _) => TopUpPaymentScreen(
            amount: amount,
            recipientPhone: recipient,
          ),
        ),
        GoRoute(
          path: AppRoutes.userProfileReceiptScreen,
          builder: (_, state) {
            receipts++;
            receiptArgs = state.extra! as UserProfileReceiptRouteArgs;
            return UserProfileReceiptScreen(args: receiptArgs!);
          },
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('existing home')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SavedCardsCubit>.value(value: cards),
          BlocProvider<AppUiConfigCubit>.value(value: config),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    cardStates.add(
      const SavedCardsState(status: SavedCardsStatus.success, cards: [_card]),
    );
    await tester.pumpAndSettle();
    bloc = tester
        .element(find.byType(DefaultBottomPayBar))
        .read<TopUpPaymentPrepaidBloc>();
    expect(find.textContaining(_prefix), findsNothing);
  }

  Future<void> startSavedPayment(WidgetTester tester,
      {bool postpaid = false}) async {
    await tester.tap(find.text('pay now'));
    if (postpaid) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    } else {
      await tester.pumpAndSettle();
    }
    expect(find.textContaining(_prefix), findsNothing);
    if (!postpaid) {
      await tester.tap(find.text('confirm payment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.textContaining(_prefix), findsNothing);
    expect(receipts, 0);
  }

  Future<void> succeed(WidgetTester tester) async {
    payment.complete(const ChangeBundleSuccess(orderId: 42));
    await tester.pumpAndSettle();
  }

  for (final (before, amount, expected) in [
    (10.0, 5.0, r'$15.00'),
    (0.1, 5.2, r'$5.30'),
    (999.99, 5.01, r'$1,005.00'),
    (0.0, 5.0, r'$5.00'),
  ]) {
    testWidgets('own saved-card top-up $before + $amount displays $expected', (
      tester,
    ) async {
      await openPayment(tester,
          before: before, amount: amount, width: before == 0 ? 320 : 390);
      await startSavedPayment(tester);
      verify(() => topUp.payWithSavedCard(
            amount: amount,
            primaryPhoneNumber: _ownPhone,
            cardToken: _card.token,
          )).called(1);
      await succeed(tester);
      expect(find.text('$_prefix$expected.'), findsOneWidget);
      expect(find.text(UserProfileReceiptRouteArgs.topUpPendingMessage),
          findsNothing);
      expect(find.text('Payment Success!'), findsOneWidget);
      expect(receiptArgs!.amount, amount);
      expect(receipts, 1);
      verify(() => balance.state).called(1);
      verifyNoMoreInteractions(balance);
      await tester.ensureVisible(find.text('back to home page'));
      await tester.tap(find.text('back to home page'));
      await tester.pumpAndSettle();
      expect(find.text('existing home'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
    });
  }

  testWidgets('live balance changes cannot double-count the submitted amount', (
    tester,
  ) async {
    await openPayment(tester);
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
    // Snapshot must use the balance at confirmation, rather than screen entry.
    when(() => balance.state).thenReturn(_balanceState(20));
    await tester.tap(find.text('confirm payment'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    when(() => balance.state).thenReturn(_balanceState(25));
    await succeed(tester);
    expect(find.text(r'Top-up complete! Your balance is now $25.00.'),
        findsOneWidget);
    when(() => balance.state).thenReturn(_balanceState(30));
    tester.element(find.byType(UserProfileReceiptScreen)).markNeedsBuild();
    await tester.pumpAndSettle();
    expect(find.text(r'Top-up complete! Your balance is now $25.00.'),
        findsOneWidget);
    expect(find.text(r'Top-up complete! Your balance is now $30.00.'),
        findsNothing);
    verify(() => balance.state).called(1);
    verifyNoMoreInteractions(balance);
  });

  testWidgets('duplicate submit keeps one request and one success detail', (
    tester,
  ) async {
    await openPayment(tester);
    await startSavedPayment(tester);
    final button = tester.widget<ElevatedButton>(find.descendant(
      of: find.byType(DefaultBottomPayBar),
      matching: find.byType(ElevatedButton),
    ));
    expect(button.onPressed, isNull);
    bloc.add(const PaySavedCardConfirmed());
    await tester.pump();
    verify(() => topUp.payWithSavedCard(
          amount: 5,
          primaryPhoneNumber: _ownPhone,
          cardToken: _card.token,
        )).called(1);
    await succeed(tester);
    expect(find.text(r'Top-up complete! Your balance is now $15.00.'),
        findsOneWidget);
    expect(receipts, 1);
  });

  testWidgets('retry captures a new pre-payment balance after failure', (
    tester,
  ) async {
    await openPayment(tester);
    await startSavedPayment(tester);
    payment.complete(const ChangeBundleFailure('existing payment error'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    when(() => balance.state).thenReturn(_balanceState(20));
    payment = Completer<ChangeBundleResult>();
    await startSavedPayment(tester);
    await succeed(tester);
    expect(find.text(r'Top-up complete! Your balance is now $25.00.'),
        findsOneWidget);
    expect(receipts, 1);
  });

  testWidgets(
      'missing balance preserves the receipt rather than inventing zero', (
    tester,
  ) async {
    await openPayment(tester, hasBalance: false);
    await startSavedPayment(tester);
    await succeed(tester);
    expect(find.textContaining(_prefix), findsNothing);
    expect(find.text(UserProfileReceiptRouteArgs.topUpPendingMessage),
        findsOneWidget);
    expect(receipts, 1);
    verify(() => balance.state).called(1);
    verifyNoMoreInteractions(balance);
  });

  testWidgets('the existing literal null own-number route value is supported', (
    tester,
  ) async {
    await openPayment(tester, recipient: 'null');
    await startSavedPayment(tester);
    await succeed(tester);
    expect(find.text(r'Top-up complete! Your balance is now $15.00.'),
        findsOneWidget);
    expect(receiptArgs!.recipientPhone, _ownPhone);
  });

  for (final failure in [
    const ChangeBundleFailure('existing payment error'),
    Exception('network unavailable'),
  ]) {
    testWidgets(
        'failed top-up preserves its error without a success receipt: $failure',
        (
      tester,
    ) async {
      await openPayment(tester);
      await startSavedPayment(tester);
      if (failure is ChangeBundleResult) {
        payment.complete(failure);
      } else {
        payment.completeError(failure);
      }
      await tester.pumpAndSettle();
      expect(find.textContaining(_prefix), findsNothing);
      expect(receipts, 0);
      expect(
          find.text(failure is ChangeBundleFailure
              ? failure.message
              : 'network unavailable'),
          findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('cancelled saved-card confirmation makes no request or message', (
    tester,
  ) async {
    await openPayment(tester);
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('confirm payment'))).pop();
    await tester.pumpAndSettle();
    expect(find.textContaining(_prefix), findsNothing);
    expect(receipts, 0);
    verifyZeroInteractions(topUp);
    verifyZeroInteractions(balance);
  });

  for (final (type, recipient) in [
    (UserType.postpaid, '2425550000'),
    (UserType.postpaid, null),
    (UserType.prepaid, '2425550000'),
  ]) {
    testWidgets('$type recipient=$recipient retains its existing receipt', (
      tester,
    ) async {
      await openPayment(tester, userType: type, recipient: recipient);
      if (type == UserType.postpaid && recipient == null) {
        // Drive the existing shared success state to verify presentation scope.
        bloc.add(const Pay3DSSucceeded(orderId: '42'));
        await tester.pumpAndSettle();
      } else {
        await startSavedPayment(tester, postpaid: type == UserType.postpaid);
        await succeed(tester);
      }
      expect(find.textContaining(_prefix), findsNothing);
      expect(find.text(UserProfileReceiptRouteArgs.topUpPendingMessage),
          findsOneWidget);
      expect(receipts, 1);
      verifyZeroInteractions(balance);
    });
  }

  for (final success in [true, false]) {
    testWidgets('own 3DS payment success=$success uses the existing callback', (
      tester,
    ) async {
      await openPayment(tester);
      await tester.tap(find.text('pay with card'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('pay now'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final iframe = tester.widget<PaymentIFrameScreen>(
        find.byType(PaymentIFrameScreen),
      );
      expect(iframe.request.body['Amount'], 5);
      expect(find.textContaining(_prefix), findsNothing);
      expect(receipts, 0);
      when(() => balance.state).thenReturn(_balanceState(15));
      if (success) {
        iframe.onSuccess(const PaymentSuccess(orderId: '42', queryParams: {}));
      } else {
        iframe.onFailure('existing 3DS failure');
      }
      await tester.pumpAndSettle();
      if (success) {
        expect(find.text(r'Top-up complete! Your balance is now $15.00.'),
            findsOneWidget);
        expect(receipts, 1);
      } else {
        expect(find.textContaining(_prefix), findsNothing);
        expect(find.text('existing 3DS failure'), findsOneWidget);
        expect(receipts, 0);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
      verifyZeroInteractions(topUp);
      verify(() => balance.state).called(1);
      verifyNoMoreInteractions(balance);
    });
  }
}
