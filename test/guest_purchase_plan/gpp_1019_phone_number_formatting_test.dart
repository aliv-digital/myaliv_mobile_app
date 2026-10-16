import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/addOnsConfirmation/view/add_ons_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/utils/guest_plan_phone_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/view/guest_purchase_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/view/guest_purchase_plan_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/view/roaming_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

GuestPlanDisplayModel _testPlan({
  required String id,
  required String title,
  required double price,
}) => GuestPlanDisplayModel(
  id: id,
  title: title,
  subtitle: 'plan subtitle',
  price: price,
  formattedPrice: '\$$price',
  basePrice: price,
  vatAmount: 0,
  description: 'plan description',
  highlights: const [],
  benefits: const [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Network network;
  late _Auth auth;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    network = _Network();
    auth = _Auth();
    when(() => auth.currentSession).thenReturn(null);
    if (!instance.isRegistered<NetworkService>()) {
      instance.registerSingleton<NetworkService>(network);
    }
    if (!instance.isRegistered<AuthManager>()) {
      instance.registerSingleton<AuthManager>(auth);
    }
    if (!instance.isRegistered<CardPaymentService>()) {
      instance.registerSingleton<CardPaymentService>(
        CardPaymentService(networkService: network),
      );
    }
  });

  tearDown(() async {
    await instance.reset();
  });

  group('GuestPlanPhoneFormatter unit tests', () {
    test('1. Ten-digit Bahamas number formatting', () {
      expect(
        GuestPlanPhoneFormatter.format('2428011616'),
        equals('(242)-801-1616'),
      );
      expect(
        GuestPlanPhoneFormatter.format('242-801-1616'),
        equals('(242)-801-1616'),
      );
      expect(
        GuestPlanPhoneFormatter.format('242 801 1616'),
        equals('(242)-801-1616'),
      );
      expect(
        GuestPlanPhoneFormatter.format('12428011616'),
        equals('(242)-801-1616'),
      );
      expect(
        GuestPlanPhoneFormatter.format('+1 242 801 1616'),
        equals('(242)-801-1616'),
      );
    });

    test(
      '2. Seven-digit local number with confirmed Bahamas country context',
      () {
        expect(
          GuestPlanPhoneFormatter.format('8011616', isBahamas: true),
          equals('(242)-801-1616'),
        );
        expect(
          GuestPlanPhoneFormatter.format('801-1616', isBahamas: true),
          equals('(242)-801-1616'),
        );
        expect(
          GuestPlanPhoneFormatter.format('8011616', countryCode: 'BS'),
          equals('(242)-801-1616'),
        );
        expect(
          GuestPlanPhoneFormatter.format('8011616', countryCode: 'bs'),
          equals('(242)-801-1616'),
        );
        expect(
          GuestPlanPhoneFormatter.format('8011616', dialCode: '+1 242'),
          equals('(242)-801-1616'),
        );
        expect(
          GuestPlanPhoneFormatter.format('8011616', dialCode: '1-242'),
          equals('(242)-801-1616'),
        );
        expect(
          GuestPlanPhoneFormatter.format('8011616', dialCode: '242'),
          equals('(242)-801-1616'),
        );
      },
    );

    test(
      '3. Already formatted phone numbers remain unchanged and idempotent',
      () {
        expect(
          GuestPlanPhoneFormatter.format('(242)-801-1616'),
          equals('(242)-801-1616'),
        );
        expect(
          GuestPlanPhoneFormatter.format('(242)-801-1616', isBahamas: true),
          equals('(242)-801-1616'),
        );
        expect(
          GuestPlanPhoneFormatter.format(
            GuestPlanPhoneFormatter.format('(242)-801-1616'),
          ),
          equals('(242)-801-1616'),
        );
      },
    );

    test('4. Null or empty display values return empty string', () {
      expect(GuestPlanPhoneFormatter.format(null), equals(''));
      expect(GuestPlanPhoneFormatter.format(''), equals(''));
      expect(GuestPlanPhoneFormatter.format('   '), equals(''));
      expect(GuestPlanPhoneFormatter.format(null, isBahamas: true), equals(''));
      expect(GuestPlanPhoneFormatter.format('', isBahamas: true), equals(''));
    });

    test('5. Malformed or unsupported numbers without inventing digits', () {
      // 7-digit without confirmed Bahamas context is NOT assumed to be Bahamas
      expect(GuestPlanPhoneFormatter.format('8011616'), equals('8011616'));
      expect(
        GuestPlanPhoneFormatter.format('8011616', countryCode: 'JM'),
        equals('8011616'),
      );
      // Malformed short digits
      expect(GuestPlanPhoneFormatter.format('12345'), equals('12345'));
      expect(
        GuestPlanPhoneFormatter.format('12345', isBahamas: true),
        equals('12345'),
      );
      // Non-Bahamas 10-digit number
      expect(
        GuestPlanPhoneFormatter.format('3058011616'),
        equals('3058011616'),
      );
      // Arbitrary non-numeric string
      expect(GuestPlanPhoneFormatter.format('unknown'), equals('unknown'));
    });
  });

  group('Confirmation & Receipt Screen Formatting Tests', () {
    testWidgets(
      '6. GPP-1019 — Daily confirmation formats Bahamas phone number in UI',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final args = GuestPurchasePlanConfirmationRouteArgs(
          phoneNumber: '2428011616',
          accountHolderName: 'guest purchase a plan',
          primaryPlanName: 'daily plan',
          primaryPlanPrice: 5.0,
          flow: GuestPurchasePlanConfirmationEntryFlow.skip,
          selectedPlan: _testPlan(id: 'd1', title: 'daily plan', price: 5.0),
        );

        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  GuestPurchasePlanConfirmationScreen(args: args),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // UI text displays formatted phone number
        expect(find.text('(242)-801-1616'), findsOneWidget);
        // Raw canonical args remain unchanged for payment/APIs
        expect(args.phoneNumber, equals('2428011616'));
      },
    );

    testWidgets(
      '7. GPP-1051 — Weekly confirmation formats local 7-digit Bahamas phone number',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final args = GuestPurchasePlanConfirmationRouteArgs(
          phoneNumber: '8011616',
          accountHolderName: 'guest purchase a plan',
          primaryPlanName: 'weekly plan',
          primaryPlanPrice: 20.0,
          flow: GuestPurchasePlanConfirmationEntryFlow.skip,
          selectedPlan: _testPlan(id: 'w1', title: 'weekly plan', price: 20.0),
        );

        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  GuestPurchasePlanConfirmationScreen(args: args),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('(242)-801-1616'), findsOneWidget);
        expect(args.phoneNumber, equals('8011616'));
      },
    );

    testWidgets(
      '8. GPP-1083 — Monthly confirmation displays already formatted phone number',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final args = GuestPurchasePlanConfirmationRouteArgs(
          phoneNumber: '(242)-801-1616',
          accountHolderName: 'guest purchase a plan',
          primaryPlanName: 'monthly plan',
          primaryPlanPrice: 65.0,
          flow: GuestPurchasePlanConfirmationEntryFlow.skip,
          selectedPlan: _testPlan(id: 'm1', title: 'monthly plan', price: 65.0),
        );

        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  GuestPurchasePlanConfirmationScreen(args: args),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('(242)-801-1616'), findsOneWidget);
        expect(args.phoneNumber, equals('(242)-801-1616'));
      },
    );

    testWidgets(
      '9. GPP-1113 — Roaming Activate Now confirmation formats phone number in UI',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, state) => const RoamingPlanConfirmationScreen(
                phoneNumber: '2428011616',
                showDateField: false,
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('(242)-801-1616'), findsOneWidget);
      },
    );

    testWidgets(
      '10. GPP-1123 — Roaming Future Plan confirmation formats phone number in UI',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, state) => const RoamingPlanConfirmationScreen(
                phoneNumber: '2428011616',
                showDateField: true,
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('(242)-801-1616'), findsOneWidget);
      },
    );

    testWidgets(
      '11. GPP-1135 — RoamEasy confirmation formats phone number in UI',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, state) => const RoamingPlanConfirmationScreen(
                phoneNumber: '8011616',
                showDateField: false,
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('(242)-801-1616'), findsOneWidget);
      },
    );

    testWidgets(
      '12. Guest Purchase Plan success receipt formats phone number in details row',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, state) => const GuestPurchasePlanReceiptScreen(
                phoneNumber: '2428011616',
                amount: 70.0,
                dateText: 'Oct 15, 2026',
                timeText: '7:30 pm',
                planName: 'liberty70',
              ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        // Formatted phone number should appear in the receipt details
        expect(find.text('(242)-801-1616'), findsOneWidget);
        expect(find.text('phone no.'), findsOneWidget);
      },
    );

    testWidgets('AddOns confirmation formats phone number in UI', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) =>
                const AddOnsConfirmationScreen(phoneNumber: '2428011616'),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('(242)-801-1616'), findsOneWidget);
    });
  });
}
