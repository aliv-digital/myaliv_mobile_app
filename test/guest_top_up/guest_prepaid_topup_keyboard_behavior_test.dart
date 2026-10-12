import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/bloc/guest_topup_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/bloc/guest_topup_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/view/guest_topup_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/widgets/gradient_input_field.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  late _MockNetworkService networkService;

  setUp(() async {
    await instance.reset();
    networkService = _MockNetworkService();
    instance.registerSingleton<NetworkService>(networkService);
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
          'AccountStatus': 'AC',
          'PaymentOption': 'PrePay',
        },
      ),
    );
  });

  tearDown(() async {
    await instance.reset();
  });

  testWidgets('first phone uses TextInputAction.next', (tester) async {
    await _pumpScreen(tester);

    expect(
      tester.widget<TextField>(_phoneField(0)).textInputAction,
      TextInputAction.next,
    );
  });

  testWidgets('first phone Next focuses confirm phone', (tester) async {
    await _pumpScreen(tester);

    final firstPhone = _phoneField(0);
    final confirmPhone = _phoneField(1);
    await tester.showKeyboard(firstPhone);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(tester.widget<TextField>(firstPhone).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(confirmPhone).focusNode!.hasFocus, isTrue);
  });

  testWidgets('confirm phone uses TextInputAction.next', (tester) async {
    await _pumpScreen(tester);

    expect(
      tester.widget<TextField>(_phoneField(1)).textInputAction,
      TextInputAction.next,
    );
  });

  testWidgets('confirm phone Next focuses top-up amount', (tester) async {
    await _pumpScreen(tester);

    final confirmPhone = _phoneField(1);
    await tester.showKeyboard(confirmPhone);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(tester.widget<TextField>(confirmPhone).focusNode!.hasFocus, isFalse);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: _amountField(),
              matching: find.byType(EditableText),
            ),
          )
          .focusNode
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('top-up amount uses TextInputAction.done', (tester) async {
    await _pumpScreen(tester);

    expect(
      tester.widget<TextField>(_amountField()).textInputAction,
      TextInputAction.done,
    );
  });

  testWidgets('valid Amount Done uses the same navigation as Next button', (
    tester,
  ) async {
    final doneHarness = await _pumpScreen(tester);
    await _enterValidDetails(tester);
    await _submitAmount(tester);
    await tester.pumpAndSettle();
    final doneExtra = doneHarness.confirmExtras.single;

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final buttonHarness = await _pumpScreen(tester);
    await _enterValidDetails(tester);
    final proceedButton = _proceedButton();
    await tester.ensureVisible(proceedButton);
    await tester.tap(proceedButton);
    await tester.pumpAndSettle();

    expect(buttonHarness.confirmExtras.single, doneExtra);
    expect(doneExtra, <String, Object?>{
      'phoneNumber': '(242)-555-1234',
      'amount': 15.0,
    });
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
    ).called(2);
  });

  testWidgets('empty first phone via Done shows the GST-001 inline error', (
    tester,
  ) async {
    final harness = await _pumpScreen(tester);
    await tester.enterText(_phoneField(1), '2425551234');
    await tester.pump();
    await tester.enterText(_amountField(), '15');
    await tester.pump();

    await _submitAmount(tester);
    await tester.pump();

    expect(harness.confirmExtras, isEmpty);
    expect(find.text(GuestTopUpTheme.emptyPhoneMessage), findsOneWidget);
    expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNothing);
    verifyNever(
      () => networkService.request<dynamic>(
        Api.guestBalanceUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    );
  });

  group('GST-001 empty number', () {
    testWidgets('no inline error before proceed is tapped', (tester) async {
      await _pumpScreen(tester);
      expect(find.text(GuestTopUpTheme.emptyPhoneMessage), findsNothing);
    });

    testWidgets('proceed with empty number shows exact inline copy only', (
      tester,
    ) async {
      final harness = await _pumpScreen(tester);
      await tester.ensureVisible(_proceedButton());
      await tester.tap(_proceedButton());
      await tester.pumpAndSettle();

      expect(
        find.text('enter an active prepaid number to top up'),
        findsOneWidget,
      );
      // Inline only: no toast copy and no mismatch message.
      expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNothing);
      expect(find.text(GuestTopUpTheme.phoneMismatchMessage), findsNothing);
      expect(harness.confirmExtras, isEmpty);
      expect(find.byType(GuestTopUpScreen), findsOneWidget);
      verifyNever(
        () => networkService.request<dynamic>(
          Api.guestBalanceUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      );
    });

    testWidgets('typing a number clears the stale empty error', (tester) async {
      await _pumpScreen(tester);
      await tester.ensureVisible(_proceedButton());
      await tester.tap(_proceedButton());
      await tester.pumpAndSettle();
      expect(find.text(GuestTopUpTheme.emptyPhoneMessage), findsOneWidget);

      await tester.enterText(_phoneField(0), '2425551234');
      await tester.pump();

      expect(find.text(GuestTopUpTheme.emptyPhoneMessage), findsNothing);
      expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNothing);
    });

    testWidgets('invalid number after empty error keeps invalid handling', (
      tester,
    ) async {
      final harness = await _pumpScreen(tester);
      await tester.ensureVisible(_proceedButton());
      await tester.tap(_proceedButton());
      await tester.pumpAndSettle();

      await tester.enterText(_phoneField(0), '123');
      await tester.pump();
      expect(find.text(GuestTopUpTheme.emptyPhoneMessage), findsNothing);
      expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsOneWidget);

      await tester.tap(_proceedButton());
      await tester.pump();

      // Existing behavior: live inline error plus the invalid-phone toast.
      expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNWidgets(2));
      expect(find.text(GuestTopUpTheme.emptyPhoneMessage), findsNothing);
      expect(harness.confirmExtras, isEmpty);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('valid details after empty error proceed unchanged', (
      tester,
    ) async {
      final harness = await _pumpScreen(tester);
      await tester.ensureVisible(_proceedButton());
      await tester.tap(_proceedButton());
      await tester.pumpAndSettle();

      await _enterValidDetails(tester);
      await tester.tap(_proceedButton());
      await tester.pumpAndSettle();

      expect(harness.confirmExtras.single, <String, Object?>{
        'phoneNumber': '(242)-555-1234',
        'amount': 15.0,
      });
    });
  });

  for (final response in <String, Map<String, dynamic>>{
    'suspended prepaid': {'AccountStatus': 'SU', 'PaymentOption': 'PrePay'},
    'active postpaid': {'AccountStatus': 'AC', 'PaymentOption': 'PostPay'},
    'suspended postpaid': {'AccountStatus': 'SU', 'PaymentOption': 'PostPay'},
    'missing account status': {'PaymentOption': 'PrePay'},
    'missing payment option': {'AccountStatus': 'AC'},
  }.entries) {
    testWidgets('${response.key} shows the active prepaid error toast', (
      tester,
    ) async {
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
          data: response.value,
        ),
      );
      final harness = await _pumpScreen(tester);
      await _enterValidDetails(tester);
      await tester.ensureVisible(_proceedButton());
      await tester.tap(_proceedButton());
      await tester.pumpAndSettle();

      expect(
        find.text(GuestTopUpTheme.invalidActivePrepaidErrorMessage),
        findsOneWidget,
      );
      expect(harness.confirmExtras, isEmpty);
      expect(find.byType(GuestTopUpScreen), findsOneWidget);
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
      ).called(1);

      await tester.pump(const Duration(seconds: 4));
    });
  }

  testWidgets('confirm mismatch via Done preserves mismatch behavior', (
    tester,
  ) async {
    final harness = await _pumpScreen(tester);
    await tester.enterText(_phoneField(0), '2425551234');
    await tester.pump();
    await tester.enterText(_phoneField(1), '2425559999');
    await tester.pump();
    await tester.enterText(_amountField(), '15');
    await tester.pump();

    await _submitAmount(tester);
    await tester.pump();

    expect(harness.confirmExtras, isEmpty);
    expect(find.text(GuestTopUpTheme.phoneMismatchMessage), findsNWidgets(2));

    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets(
    'invalid or non-positive amount via Done shows the GST-004 range error',
    (tester) async {
      final harness = await _pumpScreen(tester);
      await tester.enterText(_phoneField(0), '2425551234');
      await tester.pump();
      await tester.enterText(_phoneField(1), '2425551234');
      await tester.pump();
      await tester.enterText(_amountField(), '0');
      await tester.pump();

      await _submitAmount(tester);
      await tester.pump();

      expect(harness.confirmExtras, isEmpty);
      expect(find.text(GuestTopUpTheme.amountRangeMessage), findsOneWidget);
      expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNothing);
      expect(find.text(GuestTopUpTheme.phoneMismatchMessage), findsNothing);
      expect(find.byType(GuestTopUpScreen), findsOneWidget);

      await tester.enterText(_amountField(), 'not-a-number');
      await tester.pump();
      await _submitAmount(tester);
      await tester.pump();

      expect(harness.confirmExtras, isEmpty);
      expect(find.text(GuestTopUpTheme.amountRangeMessage), findsOneWidget);
      expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNothing);
      expect(find.text(GuestTopUpTheme.phoneMismatchMessage), findsNothing);
      expect(find.byType(GuestTopUpScreen), findsOneWidget);
      _verifyNoLookup(networkService);
    },
  );

  group('GST-004 amount range', () {
    const rangeCopy = r'enter an amount between $5.00 and $100.00';

    Future<void> enterDetails(WidgetTester tester, String amount) async {
      await tester.enterText(_phoneField(0), '2425551234');
      await tester.pump();
      await tester.enterText(_phoneField(1), '2425551234');
      await tester.pump();
      await tester.enterText(_amountField(), amount);
      await tester.pump();
    }

    Future<void> tapProceed(WidgetTester tester) async {
      await tester.ensureVisible(_proceedButton());
      await tester.tap(_proceedButton());
      await tester.pumpAndSettle();
    }

    for (final amount in ['4.99', '100.01', '1', '250']) {
      for (final viaDone in [false, true]) {
        final path = viaDone ? 'Done' : 'Proceed';
        testWidgets('\$$amount via $path shows the exact inline error', (
          tester,
        ) async {
          final harness = await _pumpScreen(tester);
          await enterDetails(tester, amount);
          expect(find.text(rangeCopy), findsNothing);

          if (viaDone) {
            await _submitAmount(tester);
            await tester.pumpAndSettle();
          } else {
            await tapProceed(tester);
          }

          expect(find.text(rangeCopy), findsOneWidget);
          expect(harness.confirmExtras, isEmpty);
          expect(find.byType(GuestTopUpScreen), findsOneWidget);
          _verifyNoLookup(networkService);
        });
      }
    }

    for (final (amount, parsed) in [
      ('5', 5.0),
      ('5.00', 5.0),
      ('50.00', 50.0),
      ('100', 100.0),
      ('100.00', 100.0),
    ]) {
      testWidgets('\$$amount is valid and proceeds unchanged', (tester) async {
        final harness = await _pumpScreen(tester);
        await enterDetails(tester, amount);
        await tapProceed(tester);

        expect(find.text(rangeCopy), findsNothing);
        expect(harness.confirmExtras.single, <String, Object?>{
          'phoneNumber': '(242)-555-1234',
          'amount': parsed,
        });
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
        ).called(1);
      });
    }

    testWidgets('\$100.00 via Done proceeds like Proceed', (tester) async {
      final harness = await _pumpScreen(tester);
      await enterDetails(tester, '100.00');
      await _submitAmount(tester);
      await tester.pumpAndSettle();

      expect(find.text(rangeCopy), findsNothing);
      expect(harness.confirmExtras.single, <String, Object?>{
        'phoneNumber': '(242)-555-1234',
        'amount': 100.0,
      });
    });

    testWidgets('correcting the amount clears the error and proceeds', (
      tester,
    ) async {
      final harness = await _pumpScreen(tester);
      await enterDetails(tester, '4.99');
      await tapProceed(tester);
      expect(find.text(rangeCopy), findsOneWidget);

      await tester.enterText(_amountField(), '5.00');
      await tester.pump();
      expect(find.text(rangeCopy), findsNothing);

      await tapProceed(tester);
      expect(harness.confirmExtras.single, <String, Object?>{
        'phoneNumber': '(242)-555-1234',
        'amount': 5.0,
      });
    });

    testWidgets('phone validation still runs first and is unchanged', (
      tester,
    ) async {
      final harness = await _pumpScreen(tester);
      await tester.enterText(_amountField(), '4.99');
      await tester.pump();
      await tapProceed(tester);

      // Empty number keeps GST-001; the amount error does not compete.
      expect(find.text(GuestTopUpTheme.emptyPhoneMessage), findsOneWidget);
      expect(find.text(rangeCopy), findsNothing);
      expect(harness.confirmExtras, isEmpty);
      _verifyNoLookup(networkService);
    });
  });

  testWidgets('button and Amount Done both read the latest BLoC state', (
    tester,
  ) async {
    final harness = await _pumpScreen(tester);
    await _enterValidDetails(tester);

    final amountSubmit = tester.widget<TextField>(_amountField()).onSubmitted!;
    final proceedButton = _proceedButton();
    await tester.ensureVisible(proceedButton);
    final buttonPressed = tester
        .widget<ElevatedButton>(proceedButton)
        .onPressed!;
    final bloc = _bloc(tester);

    final invalidPhoneState = bloc.stream.firstWhere(
      (state) => state.phoneNumber == '123',
    );
    bloc.add(const GuestActivePrepaidNumberEvent('123'));
    await invalidPhoneState;

    amountSubmit('ignored');
    await tester.pump();

    expect(harness.confirmExtras, isEmpty);
    expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 4));

    final restoredPhoneState = bloc.stream.firstWhere(
      (state) => state.phoneNumber == '(242) 555-1234',
    );
    bloc.add(const GuestActivePrepaidNumberEvent('(242) 555-1234'));
    await restoredPhoneState;
    final zeroAmountState = bloc.stream.firstWhere(
      (state) => state.amount == '0',
    );
    bloc.add(const GuestTopUpAmountEvent('0'));
    await zeroAmountState;

    buttonPressed();
    await tester.pump();

    expect(harness.confirmExtras, isEmpty);
    expect(find.byType(GuestTopUpScreen), findsOneWidget);
  });

  testWidgets('GradientInputField nullable defaults preserve existing caller', (
    tester,
  ) async {
    String? changedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientInputField(
            label: 'amount',
            hint: '00.00',
            initialValue: '15.00',
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    final field = find.byType(TextField);
    final textField = tester.widget<TextField>(field);
    expect(textField.textInputAction, isNull);
    expect(textField.onSubmitted, isNull);
    expect(textField.keyboardType, const TextInputType.numberWithOptions());
    expect(textField.controller!.text, r'$15.00');

    await tester.enterText(field, '20.5');
    await tester.pump();

    expect(changedValue, '20.5');
    expect(tester.widget<TextField>(field).controller!.text, r'$20.5');
  });
}

void _verifyNoLookup(NetworkService networkService) {
  verifyNever(
    () => networkService.request<dynamic>(
      Api.guestBalanceUrl,
      method: HttpMethod.post,
      data: any(named: 'data'),
      options: any(named: 'options'),
    ),
  );
}

Finder _phoneField(int index) {
  return find
      .byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == GuestTopUpTheme.phoneHintText,
      )
      .at(index);
}

Finder _amountField() {
  return find.descendant(
    of: find.byType(GradientInputField),
    matching: find.byType(TextField),
  );
}

Finder _proceedButton() {
  return find.widgetWithText(
    ElevatedButton,
    GuestTopUpTheme.proceedButtonLabel,
  );
}

GuestTopUpBloc _bloc(WidgetTester tester) {
  return tester.element(find.byType(CustomScrollView)).read<GuestTopUpBloc>();
}

Future<void> _enterValidDetails(WidgetTester tester) async {
  await tester.enterText(_phoneField(0), '2425551234');
  await tester.pump();
  await tester.enterText(_phoneField(1), '2425551234');
  await tester.pump();
  await tester.enterText(_amountField(), '15');
  await tester.pump();
}

Future<void> _submitAmount(WidgetTester tester) async {
  await tester.showKeyboard(_amountField());
  await tester.testTextInput.receiveAction(TextInputAction.done);
}

Future<_TopUpHarness> _pumpScreen(WidgetTester tester) async {
  final confirmExtras = <Object?>[];
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const GuestTopUpScreen()),
      GoRoute(
        path: AppRoutes.confirmGuestTopUp,
        builder: (context, state) {
          confirmExtras.add(state.extra);
          return const Scaffold(body: Text('guest top-up confirmation'));
        },
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(key: UniqueKey(), routerConfig: router),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();

  return _TopUpHarness(confirmExtras: confirmExtras);
}

class _TopUpHarness {
  const _TopUpHarness({required this.confirmExtras});

  final List<Object?> confirmExtras;
}
