import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/bloc/make_payment_postpaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/bloc/make_payment_postpaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/bloc/make_payment_postpaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/repository/make_payment_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/view/make_payment_postpaid_side_effects.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/widgets/mp_pay_bottom_bar.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/widgets/mp_payment_due_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/saved_card_payment_bottom_sheet.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Repository extends Mock implements MakePaymentPostPaidRepository {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _BalanceState extends Mock implements BalanceState {}

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Navigation extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}

const _zeroError = r'Payment cannot be $0. Please try again.';
const _card = SavedCardModel(token: 'token-1234', number: '*1234');

void main() {
  late _Repository repository;
  late _Balance balance;
  late _BalanceState balanceState;
  late _Cards cards;
  late _Navigation navigation;
  late MakePaymentPostPaidBloc bloc;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    repository = _Repository();
    balance = _Balance();
    balanceState = _BalanceState();
    cards = _Cards();
    navigation = _Navigation();
    when(() => balanceState.walletBalance).thenReturn(42);
    when(() => balance.state).thenReturn(balanceState);
    when(() => cards.state).thenReturn(const SavedCardsState(cards: [_card]));
    when(
      () => repository.payWithSavedCard(
        amount: any(named: 'amount'),
        cardToken: any(named: 'cardToken'),
      ),
    ).thenAnswer((_) async => true);
    instance.registerSingleton<BalanceCubit>(balance);
    instance.registerSingleton<SavedCardsCubit>(cards);
  });

  tearDown(() async {
    await bloc.close();
    await balance.close();
    await cards.close();
    await instance.reset();
  });

  Future<void> pumpPayment(
    WidgetTester tester, {
    MpPaymentMode mode = MpPaymentMode.card,
    MpAmountOption option = MpAmountOption.other,
    bool termsAccepted = true,
  }) async {
    bloc = MakePaymentPostPaidBloc(repository: repository);
    bloc.add(MpAmountOptionChanged(option));
    bloc.add(MpTermsToggled(termsAccepted));
    bloc.add(
      mode == MpPaymentMode.card
          ? const MpPaymentMethodSelected('token-1234')
          : const MpPayWithCardSelected(),
    );
    await tester.pumpWidget(
      BlocProvider<MakePaymentPostPaidBloc>.value(
        value: bloc,
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          navigatorObservers: [navigation],
          home: BlocConsumer<MakePaymentPostPaidBloc, MakePaymentPostPaidState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                MakePaymentPostPaidSideEffects.onState(context, state);
              }
            },
            builder: (context, state) => Scaffold(
              body: MpPaymentDueCard(
                amountText: r'$ 42.00',
                selectedOption: state.amountOption,
                customAmount: state.customAmount,
                onOptionChanged: (option) =>
                    bloc.add(MpAmountOptionChanged(option)),
                onCustomAmountChanged: (value) =>
                    bloc.add(MpCustomAmountChanged(value)),
              ),
              bottomNavigationBar: MpPayBottomBar(state: state),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField), value);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      value,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(bloc.state.customAmount, value);
    expect(
      tester
          .widget<MpPayBottomBar>(find.byType(MpPayBottomBar))
          .state
          .customAmount,
      value,
    );
  }

  Future<void> pay(WidgetTester tester) async {
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester, double amount) async {
    final sheet = tester.widget<SavedCardPaymentBottomSheet>(
      find.byType(SavedCardPaymentBottomSheet),
    );
    expect(sheet.amountText, '\$${amount.toStringAsFixed(2)}');
    await tester.tap(find.text('confirm payment'));
    await tester.pumpAndSettle();
    verify(
      () =>
          repository.payWithSavedCard(amount: amount, cardToken: 'token-1234'),
    ).called(1);
  }

  for (final mode in MpPaymentMode.values) {
    for (final value in ['0', '0.0', '0.00', ' 0.00 ', '-0.00']) {
      testWidgets('custom "$value" blocks $mode before payment opens', (
        tester,
      ) async {
        await pumpPayment(tester, mode: mode);
        await enter(tester, value);
        expect(bloc.state.canPayNow, isTrue);
        final pushes = navigation.pushes;
        await pay(tester);
        expect(find.text(_zeroError), findsOneWidget);
        expect(find.byType(SavedCardPaymentBottomSheet), findsNothing);
        expect(find.byType(PaymentIFrameScreen), findsNothing);
        expect(navigation.pushes, pushes);
        expect(bloc.state.status, MpPaymentStatus.ready);
        expect(bloc.state.navTarget, MpNavTarget.none);
        verifyZeroInteractions(repository);
        await tester.pump(const Duration(seconds: 4));
      });
    }
  }

  for (final value in ['', '   ', '-1', 'invalid', r'$0.00']) {
    testWidgets('custom "$value" retains the existing balance fallback', (
      tester,
    ) async {
      await pumpPayment(tester);
      await enter(tester, value);
      await pay(tester);
      expect(find.text(_zeroError), findsNothing);
      await confirm(tester, 42);
      expect(bloc.state.status, MpPaymentStatus.success);
      expect(bloc.state.navTarget, MpNavTarget.paid);
    });
  }

  for (final value in ['0.01', '25.50']) {
    testWidgets('positive custom $value still charges the entered amount', (
      tester,
    ) async {
      await pumpPayment(tester);
      await enter(tester, value);
      await pay(tester);
      expect(find.text(_zeroError), findsNothing);
      await confirm(tester, double.parse(value));
      expect(bloc.state.navTarget, MpNavTarget.paid);
    });
  }

  testWidgets('zero can be corrected to a positive custom amount', (
    tester,
  ) async {
    await pumpPayment(tester);
    await enter(tester, '0');
    await pay(tester);
    await tester.pump(const Duration(seconds: 4));
    await enter(tester, '15');
    await pay(tester);
    expect(find.text(_zeroError), findsNothing);
    await confirm(tester, 15);
  });

  testWidgets('current amount ignores custom zero; returning restores guard', (
    tester,
  ) async {
    await pumpPayment(tester);
    await enter(tester, '0');
    await tester.tap(find.text('pay current\namount'));
    await tester.pumpAndSettle();
    await pay(tester);
    expect(find.text(_zeroError), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('other\namount'));
    await tester.pumpAndSettle();
    await pay(tester);
    expect(find.text(_zeroError), findsOneWidget);
    verifyZeroInteractions(repository);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('current amount with zero balance retains its existing path', (
    tester,
  ) async {
    when(() => balanceState.walletBalance).thenReturn(0);
    await pumpPayment(tester, option: MpAmountOption.current);
    await pay(tester);
    expect(find.text(_zeroError), findsNothing);
    await confirm(tester, 0);
  });

  testWidgets('rapid zero taps never open confirmation or call payment', (
    tester,
  ) async {
    await pumpPayment(tester);
    await enter(tester, '0');
    for (var tap = 0; tap < 3; tap++) {
      await tester.tap(find.text('pay now'));
    }
    await tester.pumpAndSettle();
    expect(find.text(_zeroError), findsOneWidget);
    expect(find.byType(SavedCardPaymentBottomSheet), findsNothing);
    verifyZeroInteractions(repository);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('terms gating is unchanged even for custom zero', (tester) async {
    await pumpPayment(tester, termsAccepted: false);
    await enter(tester, '0');
    await pay(tester);
    expect(find.text(_zeroError), findsNothing);
    expect(find.byType(SavedCardPaymentBottomSheet), findsNothing);
    verifyZeroInteractions(repository);
  });

  for (final message in ['Payment failed. Try again.', 'Backend unavailable']) {
    testWidgets('positive custom amount preserves failure "$message"', (
      tester,
    ) async {
      when(
        () => repository.payWithSavedCard(
          amount: any(named: 'amount'),
          cardToken: any(named: 'cardToken'),
        ),
      ).thenAnswer((_) async {
        if (message == 'Payment failed. Try again.') return false;
        throw Exception(message);
      });
      await pumpPayment(tester);
      await enter(tester, '25');
      await pay(tester);
      await confirm(tester, 25);
      expect(find.text(message), findsOneWidget);
      expect(find.text(_zeroError), findsNothing);
      expect(bloc.state.status, MpPaymentStatus.failure);
      expect(bloc.state.navTarget, MpNavTarget.none);
      await tester.pump(const Duration(seconds: 4));
    });
  }
}
