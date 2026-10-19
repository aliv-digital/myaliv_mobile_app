import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/bloc/guest_splash_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/bloc/guest_splash_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/bloc/guest_splash_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/repository/guest_splash_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/theme/guest_splash_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/widgets/guest_purchase_plan_bottom_sheet.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _FakeGuestSplashRepository implements GuestSplashRepository {
  @override
  Future<GuestSplashData> loadData() async {
    return const GuestSplashData(isLoaded: true);
  }

  @override
  String? validatePurchasePlanInput({
    required Country? country,
    required String phone,
    required String confirmPhone,
  }) {
    return null;
  }

  @override
  Future<GuestSubscriberInfo> verifySubscriber(String phoneNumber) async {
    return const GuestSubscriberInfo(
      accountStatus: 'AC',
      paymentOption: 'PrePay',
    );
  }
}

void main() {
  testWidgets('first field has TextInputAction.next', (tester) async {
    await _pumpBottomSheet(tester);

    expect(
      tester.widget<TextField>(_phoneField(0)).textInputAction,
      TextInputAction.next,
    );
  });

  testWidgets('confirm field has TextInputAction.done', (tester) async {
    await _pumpBottomSheet(tester);

    expect(
      tester.widget<TextField>(_phoneField(1)).textInputAction,
      TextInputAction.done,
    );
  });

  testWidgets('first-field Next focuses confirm field', (tester) async {
    await _pumpBottomSheet(tester);

    final firstField = _phoneField(0);
    final confirmField = _phoneField(1);
    await tester.showKeyboard(firstField);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(tester.widget<TextField>(firstField).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(confirmField).focusNode!.hasFocus, isTrue);
  });

  testWidgets('valid confirm-field Done uses existing Continue navigation', (
    tester,
  ) async {
    final harness = await _pumpBottomSheet(tester);
    await _enterValidMatchingNumbers(tester);

    final confirmField = _phoneField(1);
    await tester.showKeyboard(confirmField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(harness.routeExtras, <Object?>[
      <String, String>{'phoneNumber': '(242)-555-1234'},
    ]);
    expect(find.text('guest purchase plan destination'), findsOneWidget);
  });

  testWidgets('empty first phone via Done shows the GST-005 inline error', (
    tester,
  ) async {
    final harness = await _pumpBottomSheet(tester);
    await tester.enterText(_phoneField(1), '2425551234');
    await tester.pump();

    await tester.showKeyboard(_phoneField(1));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(harness.routeExtras, isEmpty);
    expect(find.text(GuestSplashTheme.emptyPhoneMessage), findsOneWidget);
    expect(find.text(GuestSplashTheme.invalidPhoneMessage), findsNothing);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  group('GST-005 empty mobile number', () {
    const emptyCopy = 'enter your mobile number';
    Finder continueButton() => find.widgetWithText(ElevatedButton, 'continue');

    testWidgets('no inline error before continue is tapped', (tester) async {
      await _pumpBottomSheet(tester);
      expect(find.text(emptyCopy), findsNothing);
      // Continue stays tappable so the empty state can be validated.
      expect(
        tester.widget<ElevatedButton>(continueButton()).onPressed,
        isNotNull,
      );
    });

    testWidgets('continue with empty number shows exact inline copy only', (
      tester,
    ) async {
      final harness = await _pumpBottomSheet(tester);
      await tester.tap(continueButton());
      await tester.pumpAndSettle();

      expect(find.text(emptyCopy), findsOneWidget);
      expect(find.text(GuestSplashTheme.invalidPhoneMessage), findsNothing);
      expect(find.text(GuestSplashTheme.phoneMismatchMessage), findsNothing);
      expect(harness.routeExtras, isEmpty);
      expect(find.text('guest purchase plan destination'), findsNothing);
      // Sheet stays open on the same screen.
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('typing a number clears the stale empty error', (tester) async {
      await _pumpBottomSheet(tester);
      await tester.tap(continueButton());
      await tester.pumpAndSettle();
      expect(find.text(emptyCopy), findsOneWidget);

      await tester.enterText(_phoneField(0), '2');
      await tester.pump();

      expect(find.text(emptyCopy), findsNothing);
    });

    testWidgets('invalid number keeps the existing inline error and toast', (
      tester,
    ) async {
      final harness = await _pumpBottomSheet(tester);
      await tester.tap(continueButton());
      await tester.pumpAndSettle();

      await tester.enterText(_phoneField(0), '123');
      await tester.pump();
      expect(find.text(emptyCopy), findsNothing);
      expect(find.text('invalid Format'), findsOneWidget);
      expect(find.text(GuestSplashTheme.invalidPhoneMessage), findsNothing);

      await tester.tap(continueButton());
      await tester.pump();

      expect(find.text('invalid Format'), findsOneWidget);
      expect(find.text(GuestSplashTheme.invalidPhoneMessage), findsOneWidget);
      expect(find.text(emptyCopy), findsNothing);
      expect(harness.routeExtras, isEmpty);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('valid numbers after empty error follow the same flow', (
      tester,
    ) async {
      final harness = await _pumpBottomSheet(tester);
      await tester.tap(continueButton());
      await tester.pumpAndSettle();

      await _enterValidMatchingNumbers(tester);
      expect(find.text('The plan was purchased successfully.'), findsNothing);
      await tester.tap(continueButton());
      await tester.pumpAndSettle();

      expect(find.text('The plan was purchased successfully.'), findsNothing);
      expect(harness.routeExtras, <Object?>[
        <String, String>{'phoneNumber': '(242)-555-1234'},
      ]);
    });
  });

  testWidgets('confirm-phone mismatch via Done preserves mismatch path', (
    tester,
  ) async {
    final harness = await _pumpBottomSheet(tester);
    await tester.enterText(_phoneField(0), '2425551234');
    await tester.pump();
    await tester.enterText(_phoneField(1), '2425559999');
    await tester.pump();

    expect(find.text(GuestSplashTheme.phoneMismatchMessage), findsOneWidget);

    await tester.showKeyboard(_phoneField(1));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(harness.routeExtras, isEmpty);
    expect(find.text(GuestSplashTheme.phoneMismatchMessage), findsNWidgets(2));
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('button tap and Done use equivalent navigation behavior', (
    tester,
  ) async {
    final doneHarness = await _pumpBottomSheet(tester);
    await _enterValidMatchingNumbers(tester);
    await tester.showKeyboard(_phoneField(1));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final doneExtra = doneHarness.routeExtras.single;

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final buttonHarness = await _pumpBottomSheet(tester);
    await _enterValidMatchingNumbers(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'continue'));
    await tester.pumpAndSettle();

    expect(buttonHarness.routeExtras.single, doneExtra);
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

Future<void> _enterValidMatchingNumbers(WidgetTester tester) async {
  await tester.enterText(_phoneField(0), '2425551234');
  await tester.pump();
  await tester.enterText(_phoneField(1), '2425551234');
  await tester.pump();
}

Future<_BottomSheetHarness> _pumpBottomSheet(WidgetTester tester) async {
  final bloc = GuestSplashBloc(_FakeGuestSplashRepository());
  bloc.add(GuestSplashLoaded());
  await bloc.stream.firstWhere((state) => state is GuestSplashLoadedState);

  final routeExtras = <Object?>[];
  late final GoRouter router;
  router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return BlocProvider<GuestSplashBloc>.value(
            value: bloc,
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showGuestSplashPurchasePlanBottomSheet(context);
                    },
                    child: const Text('open sheet'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.guestPurchasePlan,
        builder: (context, state) {
          routeExtras.add(state.extra);
          return const Scaffold(body: Text('guest purchase plan destination'));
        },
      ),
    ],
  );

  addTearDown(() async {
    router.dispose();
    await bloc.close();
  });

  await tester.pumpWidget(
    MaterialApp.router(key: UniqueKey(), routerConfig: router),
  );
  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();

  return _BottomSheetHarness(routeExtras: routeExtras);
}

class _BottomSheetHarness {
  const _BottomSheetHarness({required this.routeExtras});

  final List<Object?> routeExtras;
}
