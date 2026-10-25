import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/bloc/auto_renew_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/view/auto_renew_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_payment_method_section.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_prepaid_proceed_action_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/dashed_add_card_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/repository/saved_cards_exception.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/repository/saved_cards_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _CardsRepository extends Mock implements SavedCardsRepository {}

class _Payment extends Mock implements CardPaymentService {}

class _Verification extends Mock implements CallLogsVerificationRepository {}

class _Auth extends Mock implements AuthManager {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

const _add = 'add a new card';
const _success = 'Payment method added successfully!';
const _existing = SavedCardModel(token: 'existing-token', number: '*0006');
const _new = SavedCardModel(token: 'new-token', number: '*7777');

void main() {
  late _CardsRepository repository;
  late SavedCardsCubit cards;
  late _Payment payment;
  late _Devices devices;
  late _Balance balance;
  late AppUiConfigCubit config;
  late GoRouter router;
  late List<SavedCardModel> serverCards;
  Completer<void>? saveGate;
  String? saveError;

  setUpAll(() async {
    for (final (family, assets) in [
      ('CircularPro', ['CircularPro-Book.otf', 'CircularPro-Bold.otf']),
      ('CircularProBold', ['CircularPro-Bold.otf']),
      ('CircularProBook', ['CircularPro-Book.otf']),
      ('MaterialIcons', ['MaterialIcons-Regular.otf']),
    ]) {
      final loader = FontLoader(family);
      for (final asset in assets) {
        loader.addFont(
          rootBundle.load(
            family == 'MaterialIcons' ? 'fonts/$asset' : 'assets/fonts/$asset',
          ),
        );
      }
      await loader.load();
    }
  });

  setUp(() {
    repository = _CardsRepository();
    serverCards = [_existing];
    saveGate = null;
    saveError = null;
    when(
      () => repository.fetchSavedCards(),
    ).thenAnswer((_) async => serverCards);
    when(() => repository.fetchAutoRenewToken()).thenAnswer((_) async => null);
    when(
      () => repository.saveNewCard(
        orderId: any(named: 'orderId'),
        expirationDate: any(named: 'expirationDate'),
      ),
    ).thenAnswer((_) async {
      await saveGate?.future;
      if (saveError != null) {
        throw SavedCardsException(
          type: SavedCardsErrorType.server,
          serverMessage: saveError,
        );
      }
      serverCards = [...serverCards, _new];
    });
    cards = SavedCardsCubit(repository: repository);
    payment = _Payment();
    // Keep the hosted screen on its loading state: no platform WebView or
    // external request is needed to exercise its production callbacks.
    final html = Completer<String?>();
    when(
      () => payment.fetch3DSHtml(
        url: any(named: 'url'),
        body: any(named: 'body'),
        skipAuth: any(named: 'skipAuth'),
      ),
    ).thenAnswer((_) => html.future);
    devices = _Devices();
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    balance = _Balance();
    when(() => balance.state).thenReturn(BalanceState.initial());
    config = AppUiConfigCubit();
    instance.registerSingleton<SavedCardsCubit>(cards);
    instance.registerSingleton<CardPaymentService>(payment);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<BalanceCubit>(balance);
    instance.registerSingleton<CallLogsVerificationRepository>(_Verification());
    instance.registerSingleton<AuthManager>(_Auth());
  });

  tearDown(() async {
    await cards.close();
    await devices.close();
    await balance.close();
    await config.close();
    await instance.reset();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AutoRenewPrepaidScreen()),
      ],
    );
    addTearDown(() async {
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppUiConfigCubit>.value(value: config),
          BlocProvider<BalanceCubit>.value(value: balance),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  DashedAddCardButton addButton(WidgetTester tester) =>
      tester.widget<DashedAddCardButton>(find.byType(DashedAddCardButton));

  Future<PaymentIFrameScreen> openHosted(WidgetTester tester) async {
    await tester.tap(find.text(_add));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PaymentIFrameScreen), findsOneWidget);
    return tester.widget<PaymentIFrameScreen>(find.byType(PaymentIFrameScreen));
  }

  Future<void> redirect(
    WidgetTester tester,
    PaymentIFrameScreen hosted, {
    String? orderId = '123',
  }) async {
    hosted.onSuccess(PaymentSuccess(orderId: orderId, queryParams: const {}));
    await tester.pumpAndSettle();
    expect(find.text('confirm expiration date'), findsOneWidget);
  }

  Future<void> confirm(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'save card'));
    await tester.pumpAndSettle();
  }

  void expectNotSaved() {
    verifyNever(
      () => repository.saveNewCard(
        orderId: any(named: 'orderId'),
        expirationDate: any(named: 'expirationDate'),
      ),
    );
  }

  testWidgets('dashed button sits between payment methods and confirmation', (
    tester,
  ) async {
    await pumpScreen(tester);
    for (final width in [320.0, 393.0, 430.0]) {
      tester.view.physicalSize = Size(width, 1000);
      await tester.pumpAndSettle();
      final section = tester.getRect(
        find.byType(AutoRenewPaymentMethodSection),
      );
      final add = tester.getRect(find.byType(DashedAddCardButton));
      final proceed = tester.getRect(
        find.byType(AutoRenewPrepaidProceedActionButton),
      );
      expect(add.left, section.left);
      expect(add.width, section.width);
      expect(add.height, 50);
      expect(add.top - section.bottom, 24);
      expect(proceed.top - add.bottom, 24);
      expect(addButton(tester).isEnabled, isTrue);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('button is available with no saved cards', (tester) async {
    serverCards = [];
    await pumpScreen(tester);
    expect(find.text('no saved cards'), findsOneWidget);
    final hosted = await openHosted(tester);
    expect(hosted.request.url, Api.addCreditCard);
    expect(hosted.request.skipAuth, isFalse);
    expect(hosted.request.body, ChangeBundleRequestFactory.addCardBodyFor3DS());
    hosted.onFailure('cancelled');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('rapid taps open only one hosted card form', (tester) async {
    await pumpScreen(tester);
    final tap = addButton(tester).onTap;
    tap();
    tap();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PaymentIFrameScreen), findsOneWidget);
    verify(
      () => payment.fetch3DSHtml(
        url: Api.addCreditCard,
        body: any(named: 'body'),
        skipAuth: false,
      ),
    ).called(1);
    final context = tester.element(find.byType(PaymentIFrameScreen));
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(addButton(tester).isLoading, isFalse);
    expectNotSaved();
  });

  testWidgets('gateway error restores the screen without saving', (
    tester,
  ) async {
    await pumpScreen(tester);
    final hosted = await openHosted(tester);
    hosted.onFailure('Gateway unavailable');
    await tester.pumpAndSettle();
    expect(find.text('Gateway unavailable'), findsOneWidget);
    expect(addButton(tester).isLoading, isFalse);
    expectNotSaved();
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('cancelling expiry never saves the card', (tester) async {
    await pumpScreen(tester);
    final hosted = await openHosted(tester);
    await redirect(tester, hosted);
    expectNotSaved();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text(_success), findsNothing);
    expect(addButton(tester).isLoading, isFalse);
    expectNotSaved();
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('missing order id reports failure after expiry confirmation', (
    tester,
  ) async {
    await pumpScreen(tester);
    final hosted = await openHosted(tester);
    await redirect(tester, hosted, orderId: null);
    await confirm(tester);
    expect(find.text('Failed to save card. Try again.'), findsOneWidget);
    expect(addButton(tester).isLoading, isFalse);
    expectNotSaved();
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('successful save refreshes cards and keeps the current selection', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.text('pay from wallet'));
    await tester.pumpAndSettle();
    final selection = tester
        .element(find.text(_add))
        .read<AutoRenewPrepaidBloc>();
    expect(selection.state.isWalletSelected, isTrue);
    saveGate = Completer<void>();
    final hosted = await openHosted(tester);
    await redirect(tester, hosted);
    await tester.tap(find.widgetWithText(ElevatedButton, 'save card'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(cards.state.isAddingCard, isTrue);
    expect(addButton(tester).isLoading, isTrue);
    addButton(tester).onTap();
    saveGate!.complete();
    await tester.pumpAndSettle();
    final now = DateTime.now();
    verify(
      () => repository.saveNewCard(
        orderId: 123,
        expirationDate:
            '${now.month.toString().padLeft(2, '0')}${(now.year % 100).toString().padLeft(2, '0')}',
      ),
    ).called(1);
    verify(() => repository.fetchSavedCards()).called(2);
    expect(find.text(_new.displayLabel), findsOneWidget);
    expect(find.text(_success), findsOneWidget);
    expect(selection.state.isWalletSelected, isTrue);
    expect(addButton(tester).isLoading, isFalse);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('save failure retains existing cards and allows retry', (
    tester,
  ) async {
    saveError = 'Card could not be saved';
    await pumpScreen(tester);
    final hosted = await openHosted(tester);
    await redirect(tester, hosted);
    await confirm(tester);
    expect(find.text(saveError!), findsOneWidget);
    expect(find.text(_existing.displayLabel), findsOneWidget);
    expect(find.text(_new.displayLabel), findsNothing);
    expect(find.text(_success), findsNothing);
    expect(addButton(tester).isLoading, isFalse);
    saveError = null;
    final retry = await openHosted(tester);
    retry.onFailure('cancelled');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
  });
}
