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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/bloc/make_payment_postpaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/bloc/make_payment_postpaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/bloc/make_payment_postpaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/repository/make_payment_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/view/make_payment_postpaid_pay_flow.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/view/make_payment_postpaid_side_effects.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/view/user_profile_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/postpaid_receipt_navigator.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repository extends Mock implements MakePaymentPostPaidRepository {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _BalanceState extends Mock implements BalanceState {}

class _CardService extends Mock implements CardPaymentService {}

const _success =
    'Thank you for your payment! Confirmation has been sent to your email.';
const _oldInvalid = 'Unable to process payment, please check card information';
const _invalid = 'Unable to process payment. Please check card information.';

void main() {
  late _Repository repository;
  late _Account account;
  late _Balance balance;
  late _CardService cardService;
  late MakePaymentPostPaidBloc bloc;
  late BuildContext paymentContext;
  late GoRouter router;
  UserProfileReceiptRouteArgs? receiptArgs;
  var receiptPushes = 0;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = _Repository();
    account = _Account();
    balance = _Balance();
    cardService = _CardService();
    final balanceState = _BalanceState();
    when(() => balanceState.walletBalance).thenReturn(42);
    when(() => balance.state).thenReturn(balanceState);
    when(() => account.state).thenReturn(const AccountInfoState(
      status: AccountInfoStatus.success,
      accountInfo: AccountInfoModel(primaryPhoneNumber: '2425551234'),
    ));
    when(() => cardService.fetch3DSHtml(
          url: any(named: 'url'),
          body: any(named: 'body'),
          skipAuth: any(named: 'skipAuth'),
        )).thenAnswer((_) => Completer<String?>().future);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<BalanceCubit>(balance);
    instance.registerSingleton<CardPaymentService>(cardService);
    receiptArgs = null;
    receiptPushes = 0;
  });

  tearDown(() async {
    router.dispose();
    await bloc.close();
    await account.close();
    await balance.close();
    await instance.reset();
  });

  Future<void> open(WidgetTester tester, {bool newCard = false}) async {
    bloc = MakePaymentPostPaidBloc(repository: repository);
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    bloc.add(const MpAmountOptionChanged(MpAmountOption.other));
    bloc.add(const MpCustomAmountChanged('25.50'));
    bloc.add(const MpTermsToggled(true));
    bloc.add(newCard
        ? const MpPayWithCardSelected()
        : const MpPaymentMethodSelected('saved-token'));
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.makePaymentPostpaidScreen,
      routes: [
        GoRoute(
          path: AppRoutes.makePaymentPostpaidScreen,
          builder: (context, _) => BlocProvider.value(
            value: bloc,
            child:
                BlocConsumer<MakePaymentPostPaidBloc, MakePaymentPostPaidState>(
              listenWhen: (previous, current) =>
                  previous.navTarget != current.navTarget ||
                  previous.errorMessage != current.errorMessage ||
                  previous.status != current.status,
              listener: MakePaymentPostPaidSideEffects.onState,
              builder: (context, state) {
                paymentContext = context;
                return const Scaffold(body: Text('payment form'));
              },
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.userProfileReceiptScreen,
          builder: (_, state) {
            receiptPushes++;
            receiptArgs = state.extra! as UserProfileReceiptRouteArgs;
            return UserProfileReceiptScreen(args: receiptArgs!);
          },
        ),
        GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const Scaffold(body: Text('existing home'))),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('saved-card success copy follows API success once and keeps Home',
      (tester) async {
    final result = Completer<bool>();
    when(() => repository.payWithSavedCard(
        amount: 25.50,
        cardToken: 'saved-token')).thenAnswer((_) => result.future);
    await open(tester);
    expect(find.text(_success), findsNothing);
    bloc.add(const MpPaySavedCardConfirmed());
    await tester.pump();
    expect(bloc.state.status, MpPaymentStatus.paying);
    expect(find.text(_success), findsNothing);
    expect(receiptPushes, 0);
    result.complete(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(bloc.state.status, MpPaymentStatus.success,
        reason: bloc.state.errorMessage);
    expect(receiptArgs, isNotNull);
    expect(find.text(_success), findsOneWidget);
    expect(find.text('Payment Success!'), findsOneWidget);
    expect(receiptPushes, 1);
    expect(receiptArgs!.amount, 25.50);
    expect(receiptArgs!.recipientPhone, '2425551234');
    expect(receiptArgs!.paymentMethod, 'credit card');
    expect(bloc.state.navTarget, MpNavTarget.none);
    bloc.add(const MpTermsToggled(false));
    await tester.pumpAndSettle();
    expect(receiptPushes, 1);
    await tester.ensureVisible(find.text('back to home page'));
    await tester.tap(find.text('back to home page'));
    await tester.pumpAndSettle();
    expect(find.text('existing home'), findsOneWidget);
    verify(() => repository.payWithSavedCard(
        amount: 25.50, cardToken: 'saved-token')).called(1);
  });

  testWidgets(
      '3DS opens without success; existing success callback shows receipt',
      (tester) async {
    await open(tester, newCard: true);
    await MakePaymentPostPaidPayFlow.onPayNow(paymentContext, bloc.state);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(_success), findsNothing);
    expect(receiptPushes, 0);
    tester
        .widget<PaymentIFrameScreen>(find.byType(PaymentIFrameScreen))
        .onSuccess(const PaymentSuccess(orderId: '123', queryParams: {}));
    await tester.pumpAndSettle();
    expect(find.text(_success), findsOneWidget);
    expect(receiptArgs!.paymentMethod, 'visa');
    expect(receiptArgs!.amount, 25.50);
    expect(receiptPushes, 1);
    verifyZeroInteractions(repository);
  });

  testWidgets('failed payment never opens the success receipt', (tester) async {
    when(() => repository.payWithSavedCard(
        amount: 25.50,
        cardToken: 'saved-token')).thenAnswer((_) async => false);
    await open(tester);
    bloc.add(const MpPaySavedCardConfirmed());
    await tester.pumpAndSettle();
    expect(find.text('Payment failed. Try again.'), findsOneWidget);
    expect(find.text(_success), findsNothing);
    expect(receiptPushes, 0);
    expect(bloc.state.navTarget, MpNavTarget.none);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  for (final newCard in [false, true]) {
    for (final message in [
      _oldInvalid,
      'Backend unavailable',
      'Request timeout. Please try again.'
    ]) {
      testWidgets('newCard=$newCard presents "$message" and preserves retry',
          (tester) async {
        when(() => repository.payWithSavedCard(
              amount: 25.50,
              cardToken: 'saved-token',
            )).thenThrow(Exception(message));
        await open(tester, newCard: newCard);
        if (newCard) {
          await MakePaymentPostPaidPayFlow.onPayNow(paymentContext, bloc.state);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          tester
              .widget<PaymentIFrameScreen>(find.byType(PaymentIFrameScreen))
              .onFailure(message);
        } else {
          bloc.add(const MpPaySavedCardConfirmed());
        }
        await tester.pumpAndSettle();
        expect(find.text(message == _oldInvalid ? _invalid : message),
            findsOneWidget);
        expect(find.text(_oldInvalid), findsNothing);
        expect(find.text(_success), findsNothing);
        expect(find.text('payment form'), findsOneWidget);
        expect(receiptPushes, 0);
        expect(bloc.state.navTarget, MpNavTarget.none);
        if (!newCard) {
          expect(bloc.state.status, MpPaymentStatus.failure);
          expect(bloc.state.errorMessage, message);
        }
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        if (newCard) {
          await MakePaymentPostPaidPayFlow.onPayNow(paymentContext, bloc.state);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          tester
              .widget<PaymentIFrameScreen>(find.byType(PaymentIFrameScreen))
              .onSuccess(const PaymentSuccess(orderId: '123', queryParams: {}));
          verifyZeroInteractions(repository);
        } else {
          when(() => repository.payWithSavedCard(
                amount: 25.50,
                cardToken: 'saved-token',
              )).thenAnswer((_) async => true);
          bloc.add(const MpPaySavedCardConfirmed());
        }
        await tester.pumpAndSettle();
        expect(find.text(_success), findsOneWidget);
        expect(receiptPushes, 1);
        if (!newCard) {
          verify(() => repository.payWithSavedCard(
                amount: 25.50,
                cardToken: 'saved-token',
              )).called(2);
        }
      });
    }
  }

  testWidgets('other navigator consumers retain their default receipt message',
      (tester) async {
    await open(tester);
    PostpaidReceiptNavigator.push(paymentContext,
        amount: 25.50, method: PostpaidPaymentMethod.newCard);
    await tester.pumpAndSettle();
    expect(find.text(UserProfileReceiptRouteArgs.postpaidPaymentPendingMessage),
        findsOneWidget);
    expect(find.text(_success), findsNothing);
  });
}
