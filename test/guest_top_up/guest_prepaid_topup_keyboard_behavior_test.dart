import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/bloc/guest_topup_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/bloc/guest_topup_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/view/guest_topup_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/widgets/gradient_input_field.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

void main() {
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
  });

  testWidgets('invalid first phone via Done preserves invalid-phone behavior', (
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
    expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
  });

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
    'invalid or non-positive amount via Done remains a silent no-op',
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
      expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNothing);
      expect(find.text(GuestTopUpTheme.phoneMismatchMessage), findsNothing);
      expect(find.byType(GuestTopUpScreen), findsOneWidget);

      await tester.enterText(_amountField(), 'not-a-number');
      await tester.pump();
      await _submitAmount(tester);
      await tester.pump();

      expect(harness.confirmExtras, isEmpty);
      expect(find.text(GuestTopUpTheme.invalidPhoneMessage), findsNothing);
      expect(find.text(GuestTopUpTheme.phoneMismatchMessage), findsNothing);
      expect(find.byType(GuestTopUpScreen), findsOneWidget);
    },
  );

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
