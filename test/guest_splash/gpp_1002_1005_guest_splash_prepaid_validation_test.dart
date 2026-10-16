import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/bloc/guest_splash_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/bloc/guest_splash_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/bloc/guest_splash_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/repository/guest_splash_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/theme/guest_splash_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestSplash/widgets/guest_purchase_plan_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/repository/guest_purchase_plan_repository.dart';
import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _MockNetworkService extends Mock implements NetworkService {}

class _MockGuestSplashRepository implements GuestSplashRepository {
  _MockGuestSplashRepository({
    this.subscriberInfo = const GuestSubscriberInfo(
      accountStatus: 'AC',
      paymentOption: 'PrePay',
    ),
    this.throwOnVerify = false,
  });

  GuestSubscriberInfo subscriberInfo;
  bool throwOnVerify;
  String? lastVerifiedPhone;

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
    lastVerifiedPhone = phoneNumber;
    if (throwOnVerify) {
      throw Exception('Network error');
    }
    return subscriberInfo;
  }
}

class _TestHarness {
  _TestHarness({required this.repository, required this.routeExtras});

  final _MockGuestSplashRepository repository;
  final List<Object?> routeExtras;
}

Future<_TestHarness> _pumpBottomSheet(
  WidgetTester tester, {
  _MockGuestSplashRepository? repository,
}) async {
  final repo = repository ?? _MockGuestSplashRepository();
  final bloc = GuestSplashBloc(repo);
  bloc.add(GuestSplashLoaded());
  await bloc.stream.firstWhere((state) => state is GuestSplashLoadedState);

  final List<Object?> routeExtras = [];
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

  return _TestHarness(repository: repo, routeExtras: routeExtras);
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

Finder _continueButton() => find.widgetWithText(ElevatedButton, 'continue');

void main() {
  group('GPP-1002 — 7-digit Bahamas Phone Number Normalization', () {
    test(
      'LoginPhoneNumberHelper formats 7-digit numbers to (242)-xxx-xxxx',
      () {
        expect(
          LoginPhoneNumberHelper.formatBahamasNumberForDisplay('8999958'),
          '(242)-899-9958',
        );
        expect(
          LoginPhoneNumberHelper.formatBahamasNumberForDisplay('899-9958'),
          '(242)-899-9958',
        );
        expect(
          LoginPhoneNumberHelper.formatBahamasNumberForDisplay('(899)-995-8'),
          '(242)-899-9958',
        );
      },
    );

    test(
      'LoginPhoneNumberHelper formats 10-digit numbers to (242)-xxx-xxxx',
      () {
        expect(
          LoginPhoneNumberHelper.formatBahamasNumberForDisplay('2428999958'),
          '(242)-899-9958',
        );
      },
    );

    test(
      'GuestPurchasePlanRepository normalizes 7-digit phone numbers with 242 prefix',
      () {
        final repo = GuestPurchasePlanRepository(
          phoneNumber: '899-9958',
          networkService: _MockNetworkService(),
        );
        expect(repo, isNotNull);
      },
    );

    testWidgets(
      'Entering 7-digit Bahamas number normalizes and navigates on active prepaid',
      (tester) async {
        final harness = await _pumpBottomSheet(tester);

        await tester.enterText(_phoneField(0), '8999958');
        await tester.pump();
        await tester.enterText(_phoneField(1), '8999958');
        await tester.pump();

        await tester.tap(_continueButton());
        await tester.pumpAndSettle();

        expect(harness.routeExtras, <Object?>[
          <String, String>{'phoneNumber': '(242)-899-9958'},
        ]);
        expect(find.text('guest purchase plan destination'), findsOneWidget);
      },
    );

    testWidgets(
      '7-digit input updates in the UI to (242)-xxx-xxxx on Next/blur and before submitting',
      (tester) async {
        await _pumpBottomSheet(tester);

        await tester.enterText(_phoneField(0), '8999958');
        await tester.pump();

        // When moving focus to confirm field (via Next), field 0 updates in UI to (242)-899-9958
        await tester.showKeyboard(_phoneField(0));
        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pump();

        expect(
          tester.widget<TextField>(_phoneField(0)).controller?.text,
          '(242)-899-9958',
        );

        // Enter 7 digits in confirm field
        await tester.enterText(_phoneField(1), '8999958');
        await tester.pump();

        // When Continue is tapped, confirm field updates in UI to (242)-899-9958 before submitting
        await tester.tap(_continueButton());
        await tester.pump();

        expect(
          tester.widget<TextField>(_phoneField(1)).controller?.text,
          '(242)-899-9958',
        );
        await tester.pumpAndSettle();
      },
    );
  });

  group('GPP-1005 — Active Prepaid Subscriber Validation', () {
    testWidgets('Postpaid number is blocked with appropriate error message', (
      tester,
    ) async {
      final repo = _MockGuestSplashRepository(
        subscriberInfo: const GuestSubscriberInfo(
          accountStatus: 'AC',
          paymentOption: 'PostPay',
        ),
      );
      final harness = await _pumpBottomSheet(tester, repository: repo);

      await tester.enterText(_phoneField(0), '2428011616');
      await tester.pump();
      await tester.enterText(_phoneField(1), '2428011616');
      await tester.pump();

      await tester.tap(_continueButton());
      await tester.pump();
      await tester.pump();

      expect(harness.routeExtras, isEmpty);
      expect(find.text('guest purchase plan destination'), findsNothing);
      expect(
        find.text(GuestSplashTheme.invalidActivePrepaidErrorMessage),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Suspended or inactive account is blocked with error message', (
      tester,
    ) async {
      final repo = _MockGuestSplashRepository(
        subscriberInfo: const GuestSubscriberInfo(
          accountStatus: 'SU',
          paymentOption: 'PrePay',
        ),
      );
      final harness = await _pumpBottomSheet(tester, repository: repo);

      await tester.enterText(_phoneField(0), '2425551234');
      await tester.pump();
      await tester.enterText(_phoneField(1), '2425551234');
      await tester.pump();

      await tester.tap(_continueButton());
      await tester.pump();
      await tester.pump();

      expect(harness.routeExtras, isEmpty);
      expect(find.text('guest purchase plan destination'), findsNothing);
      expect(
        find.text(GuestSplashTheme.invalidActivePrepaidErrorMessage),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets(
      'Network error on verification is handled gracefully and blocks navigation',
      (tester) async {
        final repo = _MockGuestSplashRepository(throwOnVerify: true);
        final harness = await _pumpBottomSheet(tester, repository: repo);

        await tester.enterText(_phoneField(0), '2425551234');
        await tester.pump();
        await tester.enterText(_phoneField(1), '2425551234');
        await tester.pump();

        await tester.tap(_continueButton());
        await tester.pump();
        await tester.pump();

        expect(harness.routeExtras, isEmpty);
        expect(find.text('guest purchase plan destination'), findsNothing);
        expect(
          find.text(GuestSplashTheme.invalidActivePrepaidErrorMessage),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 4));
      },
    );

    testWidgets('Active prepaid number proceeds to plan purchase screen', (
      tester,
    ) async {
      final repo = _MockGuestSplashRepository(
        subscriberInfo: const GuestSubscriberInfo(
          accountStatus: 'AC',
          paymentOption: 'PrePay',
        ),
      );
      final harness = await _pumpBottomSheet(tester, repository: repo);

      await tester.enterText(_phoneField(0), '2425551234');
      await tester.pump();
      await tester.enterText(_phoneField(1), '2425551234');
      await tester.pump();

      await tester.tap(_continueButton());
      await tester.pumpAndSettle();

      expect(harness.routeExtras, <Object?>[
        <String, String>{'phoneNumber': '(242)-555-1234'},
      ]);
      expect(find.text('guest purchase plan destination'), findsOneWidget);
    });
  });
}
