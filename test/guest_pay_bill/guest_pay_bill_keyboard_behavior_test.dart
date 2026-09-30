import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/model/guest_pay_bill_confirm_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/bloc/guest_pay_bill_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/model/guest_pay_bill_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/view/guest_pay_bill_screen.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockNetworkService networkService;

  setUp(() async {
    await instance.reset();
    networkService = _MockNetworkService();
    instance.registerSingleton<NetworkService>(networkService);
  });

  tearDown(() async {
    await instance.reset();
  });

  testWidgets('ALIV Postpaid mobile uses TextInputAction.next', (tester) async {
    await _pumpScreen(tester);

    expect(
      tester.widget<TextField>(_phoneField(0)).textInputAction,
      TextInputAction.next,
    );
  });

  testWidgets('ALIV Postpaid mobile Next focuses confirm mobile', (
    tester,
  ) async {
    await _pumpScreen(tester);

    final mobileField = _phoneField(0);
    final confirmField = _phoneField(1);
    await tester.showKeyboard(mobileField);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(tester.widget<TextField>(mobileField).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(confirmField).focusNode!.hasFocus, isTrue);
  });

  testWidgets('ALIV Postpaid confirm uses TextInputAction.done', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(
      tester.widget<TextField>(_phoneField(1)).textInputAction,
      TextInputAction.done,
    );
  });

  testWidgets('valid Postpaid confirm Done triggers existing verify flow', (
    tester,
  ) async {
    _stubPostpaidSuccess(networkService);
    await _pumpScreen(tester);
    await _enterValidPostpaidNumbers(tester);

    await _submitField(tester, _phoneField(1));
    await tester.pumpAndSettle();

    _verifyPostpaidLookup(networkService, called: 1);
  });

  testWidgets('invalid Postpaid confirm Done preserves disabled feedback', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await _submitField(tester, _phoneField(1));
    await tester.pump();

    expect(find.text('Please enter required details first.'), findsOneWidget);
    verifyNever(
      () => networkService.request<dynamic>(
        Api.guestBalanceUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Postpaid confirm Done does nothing while verify is loading', (
    tester,
  ) async {
    final pendingResponse = Completer<Response<dynamic>>();
    _stubPostpaidPending(networkService, pendingResponse);
    await _pumpScreen(tester);
    await _enterValidPostpaidNumbers(tester);

    await _submitField(tester, _phoneField(1));
    await tester.pump();
    expect(_bloc(tester).state.verifyStatus, GuestPayBillVerifyStatus.loading);

    await _submitField(tester, _phoneField(1));
    await tester.pump();
    _verifyPostpaidLookup(networkService, called: 1);

    pendingResponse.complete(_postpaidResponse());
    await tester.pumpAndSettle();
  });

  testWidgets('ALIV Fibr account Next focuses Name', (tester) async {
    await _pumpScreen(tester);
    await _selectService(tester, 'ALIVFibr');

    final accountField = _fieldWithHint('enter ID');
    final nameField = _fieldWithHint('enter name');
    expect(
      tester.widget<TextField>(accountField).textInputAction,
      TextInputAction.next,
    );

    await tester.showKeyboard(accountField);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(tester.widget<TextField>(accountField).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(nameField).focusNode!.hasFocus, isTrue);
  });

  testWidgets('valid ALIV Fibr Name Done triggers existing verify flow', (
    tester,
  ) async {
    _stubFibrSuccess(networkService);
    await _pumpScreen(tester);
    await _selectService(tester, 'ALIVFibr');
    await _enterValidFibrDetails(tester);

    final nameField = _fieldWithHint('enter name');
    expect(
      tester.widget<TextField>(nameField).textInputAction,
      TextInputAction.done,
    );
    await _submitField(tester, nameField);
    await tester.pumpAndSettle();

    _verifyFibrLookup(networkService, called: 1);
  });

  testWidgets('invalid ALIV Fibr Name Done preserves existing AppToast', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await _selectService(tester, 'ALIVFibr');

    await _submitField(tester, _fieldWithHint('enter name'));
    await tester.pump();

    expect(find.text('Please enter required details first'), findsOneWidget);
    verifyNever(
      () => networkService.request<dynamic>(
        Api.guestFibrBalanceUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    );
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('ALIV Fibr Name Done does nothing while verify is loading', (
    tester,
  ) async {
    final pendingResponse = Completer<Response<dynamic>>();
    _stubFibrPending(networkService, pendingResponse);
    await _pumpScreen(tester);
    await _selectService(tester, 'ALIVFibr');
    await _enterValidFibrDetails(tester);

    final nameField = _fieldWithHint('enter name');
    await _submitField(tester, nameField);
    await tester.pump();
    expect(_bloc(tester).state.verifyStatus, GuestPayBillVerifyStatus.loading);

    await _submitField(tester, _fieldWithHint('enter name'));
    await tester.pump();
    _verifyFibrLookup(networkService, called: 1);

    pendingResponse.complete(_fibrResponse());
    await tester.pumpAndSettle();
  });

  testWidgets('custom amount uses TextInputAction.done', (tester) async {
    await _pumpScreen(tester);

    expect(
      tester.widget<TextField>(_amountField()).textInputAction,
      TextInputAction.done,
    );
  });

  testWidgets('amount Done does nothing while final Submit is disabled', (
    tester,
  ) async {
    final harness = await _pumpScreen(tester);
    await tester.enterText(_amountField(), '15');
    await tester.pump();

    await _submitField(tester, _amountField());
    await tester.pumpAndSettle();

    expect(harness.confirmExtras, isEmpty);
    expect(find.text('pay bills'), findsOneWidget);
  });

  testWidgets('enabled amount Done uses existing final submit navigation', (
    tester,
  ) async {
    _stubPostpaidSuccess(networkService);
    final harness = await _pumpScreen(tester);
    await _verifyValidPostpaidAccount(tester);
    await tester.enterText(_amountField(), '15.50');
    await tester.pump();

    await _submitField(tester, _amountField());
    await tester.pump();

    expect(harness.confirmExtras, hasLength(1));
    final args = harness.confirmExtras.single as GuestPayBillConfirmArgs;
    expect(args.serviceName, 'ALIV Postpaid');
    expect(args.identifierLabel, 'phone no.');
    expect(args.identifierValue, '242-555-1234');
    expect(args.amount, 15.50);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('amount Done does not bypass final submit loading state', (
    tester,
  ) async {
    _stubPostpaidSuccess(networkService);
    final harness = await _pumpScreen(tester);
    await _verifyValidPostpaidAccount(tester);
    await tester.enterText(_amountField(), '15.50');
    await tester.pump();

    final bloc = _bloc(tester);
    bloc.add(const GuestPayBillSubmitPressed());
    await tester.pump();
    expect(bloc.state.submitStatus, GuestPayBillSubmitStatus.loading);

    await _submitField(tester, _amountField());
    await tester.pump();
    expect(harness.confirmExtras, isEmpty);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('REV remains a selection-only flow with no editable fields', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await _selectService(tester, 'REV');

    expect(find.byType(TextField), findsNothing);
    expect(find.text('continue to pay'), findsOneWidget);
  });
}

Finder _phoneField(int index) {
  return find
      .byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'eg: (242)-899-9999',
      )
      .at(index);
}

Finder _fieldWithHint(String hint) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint,
  );
}

Finder _amountField() => _fieldWithHint(r'$ 0.00');

GuestPayBillBloc _bloc(WidgetTester tester) {
  return tester
      .element(find.byType(SingleChildScrollView))
      .read<GuestPayBillBloc>();
}

Future<void> _submitField(WidgetTester tester, Finder field) async {
  await tester.showKeyboard(field);
  await tester.testTextInput.receiveAction(TextInputAction.done);
}

Future<void> _enterValidPostpaidNumbers(WidgetTester tester) async {
  await tester.enterText(_phoneField(0), '2425551234');
  await tester.pump();
  await tester.enterText(_phoneField(1), '2425551234');
  await tester.pump();
}

Future<void> _enterValidFibrDetails(WidgetTester tester) async {
  await tester.enterText(_fieldWithHint('enter ID'), 'account-123');
  await tester.pump();
  await tester.enterText(_fieldWithHint('enter name'), 'Jane Doe');
  await tester.pump();
}

Future<void> _verifyValidPostpaidAccount(WidgetTester tester) async {
  await _enterValidPostpaidNumbers(tester);
  await _submitField(tester, _phoneField(1));
  await tester.pumpAndSettle();
  expect(_bloc(tester).state.verifyStatus, GuestPayBillVerifyStatus.success);
}

Future<void> _selectService(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DropdownButton<BillService>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<_PayBillHarness> _pumpScreen(WidgetTester tester) async {
  final confirmExtras = <Object?>[];
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const GuestPayBillScreen(),
      ),
      GoRoute(
        path: AppRoutes.guestPayBillConfirm,
        builder: (context, state) {
          confirmExtras.add(state.extra);
          return const Scaffold(body: Text('confirmation destination'));
        },
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(key: UniqueKey(), routerConfig: router),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();

  return _PayBillHarness(confirmExtras: confirmExtras);
}

void _stubPostpaidSuccess(_MockNetworkService networkService) {
  when(
    () => networkService.request<dynamic>(
      Api.guestBalanceUrl,
      method: HttpMethod.post,
      data: any(named: 'data'),
      options: any(named: 'options'),
    ),
  ).thenAnswer((_) async => _postpaidResponse());
}

void _stubPostpaidPending(
  _MockNetworkService networkService,
  Completer<Response<dynamic>> pendingResponse,
) {
  when(
    () => networkService.request<dynamic>(
      Api.guestBalanceUrl,
      method: HttpMethod.post,
      data: any(named: 'data'),
      options: any(named: 'options'),
    ),
  ).thenAnswer((_) => pendingResponse.future);
}

void _stubFibrSuccess(_MockNetworkService networkService) {
  when(
    () => networkService.request<dynamic>(
      Api.guestFibrBalanceUrl,
      method: HttpMethod.post,
      data: any(named: 'data'),
      options: any(named: 'options'),
    ),
  ).thenAnswer((_) async => _fibrResponse());
}

void _stubFibrPending(
  _MockNetworkService networkService,
  Completer<Response<dynamic>> pendingResponse,
) {
  when(
    () => networkService.request<dynamic>(
      Api.guestFibrBalanceUrl,
      method: HttpMethod.post,
      data: any(named: 'data'),
      options: any(named: 'options'),
    ),
  ).thenAnswer((_) => pendingResponse.future);
}

Response<dynamic> _postpaidResponse() {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: Api.guestBalanceUrl),
    data: <String, dynamic>{'Balance': 20.0, 'AccountStatus': 'active'},
  );
}

Response<dynamic> _fibrResponse() {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: Api.guestFibrBalanceUrl),
    data: <String, dynamic>{
      'id_acc': 123,
      'Balance': 20.0,
      'AccountStatus': 'active',
    },
  );
}

void _verifyPostpaidLookup(
  _MockNetworkService networkService, {
  required int called,
}) {
  verify(
    () => networkService.request<dynamic>(
      Api.guestBalanceUrl,
      method: HttpMethod.post,
      data: <String, dynamic>{
        'ChannelType': 'SelfCare',
        'PhoneNumber': '2425551234',
      },
      options: any(named: 'options'),
    ),
  ).called(called);
}

void _verifyFibrLookup(
  _MockNetworkService networkService, {
  required int called,
}) {
  verify(
    () => networkService.request<dynamic>(
      Api.guestFibrBalanceUrl,
      method: HttpMethod.post,
      data: <String, dynamic>{
        'ChannelType': 'SelfCare',
        'FibrName': 'JANE DOE',
        'FibrAccountID': 'account-123',
      },
      options: any(named: 'options'),
    ),
  ).called(called);
}

class _PayBillHarness {
  const _PayBillHarness({required this.confirmExtras});

  final List<Object?> confirmExtras;
}
