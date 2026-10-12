import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/view/guest_purchase_plan_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/monthly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roam_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roaming_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/wallet_payment_activate_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/wallet_payment_activate_or_future_bottom_sheet.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

const _noActivePlan =
    'the account owner has no active plan, so their new plan will start immediately.';
const _standalone =
    'the account owner standalone plan can start immediately, or on a date of choice.';
const _ownerStandalone =
    'your standalone plan can start immediately, or on a date of your choice.';
const _liberty70Warning =
    'activating now replaces the account owner current plan, '
    'you can activate the account owner plan as a future plan and '
    'it will start when their current plan ends on XXX.';

class _FakeNetworkService extends NetworkService {
  _FakeNetworkService(this.plans)
    : super(authManager: AuthManager(), onHardLogout: _noopLogout);

  final List<Map<String, dynamic>> plans;

  static Future<void> _noopLogout() async {}

  @override
  Future<Response<T>> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String? requestId,
  }) async {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: plans as T,
    );
  }
}

Map<String, dynamic> _plan({
  required String id,
  required String name,
  required String type,
  required String frequency,
  String group = '',
}) {
  return <String, dynamic>{
    'PlanID': id,
    'PlanName': name,
    'PlanDescription': '$name plan',
    'PlanAmount': 30,
    'VATAmount': '3.00',
    'PlanType': type,
    'Frequency': frequency,
    'PaymentOption': 'PrePay',
    'PlanGroup': group,
    'PlanBuckets': <Map<String, dynamic>>[
      <String, dynamic>{
        'Name': 'Data',
        'Amount': 14,
        'Unit': 'GB',
        'BucketUnit': 'GB',
        'Suppress': false,
        'Unlimited': false,
      },
    ],
  };
}

void main() {
  late List<String> visited;
  late List<Object?> roamingExtras;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() async {
    visited = [];
    roamingExtras = [];
    await instance.reset();
    instance.registerSingleton<NetworkService>(
      _FakeNetworkService([
        _plan(id: 'p1', name: 'freedom30', type: 'P', frequency: 'M'),
        _plan(id: 'p2', name: 'liberty70', type: 'P', frequency: 'M'),
        _plan(
          id: 'r1',
          name: 'travel20',
          type: 'A',
          frequency: 'D',
          group: 'Roaming',
        ),
      ]),
    );
  });

  tearDown(() async {
    await instance.reset();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    GoRoute stub(String path) => GoRoute(
      path: path,
      builder: (_, state) {
        visited.add(path);
        if (path == AppRoutes.roamingPlanConfirmation) {
          roamingExtras.add(state.extra);
        }
        return Scaffold(body: Text('stub $path'));
      },
    );
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const GuestPurchasePlanScreen(phoneNumber: '242-555-1234'),
        ),
        stub(AppRoutes.guestPurchasePlanAddOns),
        stub(AppRoutes.guestPurchasePlanConfirmation),
        stub(AppRoutes.roamingPlanConfirmation),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).first);
    await tester.pumpAndSettle();
  }

  Future<void> purchaseNow(WidgetTester tester, String planName) async {
    final card = find.ancestor(
      of: find.text(planName),
      matching: find.byWidgetPredicate(
        (w) => w is MonthlyPlanCard || w is RoamingPlanCard,
      ),
    );
    final button = find.descendant(
      of: card.first,
      matching: find.text('purchase now'),
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('first primary uses the guest no-active-plan copy', (
    tester,
  ) async {
    await pumpScreen(tester);
    await purchaseNow(tester, 'freedom30');

    expect(find.byType(WalletPaymentActivateBottomSheet), findsOneWidget);
    expect(find.text(_noActivePlan), findsOneWidget);
    expect(find.textContaining('no current plan'), findsNothing);
    expect(find.text('activate now'), findsOneWidget);
    expect(find.text('future plan'), findsNothing);
    expect(find.text('start from'), findsNothing);

    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(visited, [AppRoutes.guestPurchasePlanAddOns]);
  });

  testWidgets('liberty70 keeps its existing replacement branch', (
    tester,
  ) async {
    await pumpScreen(tester);
    await purchaseNow(tester, 'liberty70');

    expect(find.byType(WalletPaymentActivateOrFutureBottomSheet), findsOne);
    expect(find.text(_liberty70Warning), findsOneWidget);
    expect(find.text(_noActivePlan), findsNothing);
    expect(find.text('activate now'), findsOneWidget);
    expect(find.text('future plan'), findsOneWidget);
  });

  testWidgets('standalone uses guest copy with activate now and date picker', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openTab(tester, 'roaming');
    await purchaseNow(tester, 'travel20');

    expect(find.byType(RoamBottomSheet), findsOneWidget);
    expect(find.text(_standalone), findsOneWidget);
    expect(find.text(_ownerStandalone), findsNothing);
    expect(find.text('start from'), findsOneWidget);
    expect(find.text('activate now'), findsOneWidget);

    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(visited, [AppRoutes.roamingPlanConfirmation]);
    final extra = roamingExtras.single! as Map<String, Object?>;
    expect(extra['showDateField'], isFalse);
    expect(extra['forceNow'], isTrue);
  });

  testWidgets('another standalone purchase shows the same guest copy and '
      'keeps the optional date choice', (tester) async {
    await pumpScreen(tester);
    await openTab(tester, 'roaming');
    // Guest has no owner-plan data, so a repeat purchase opens the same sheet.
    await purchaseNow(tester, 'travel20');
    await tester.tap(
      find.descendant(
        of: find.byType(RoamBottomSheet),
        matching: find.byIcon(Icons.arrow_back_rounded),
      ),
    );
    await tester.pumpAndSettle();
    await purchaseNow(tester, 'travel20');

    expect(find.text(_standalone), findsOneWidget);
    expect(find.text(_ownerStandalone), findsNothing);

    await tester.tap(
      find
          .descendant(
            of: find.byType(RoamBottomSheet),
            matching: find.byType(InkWell),
          )
          .at(1),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    await tester.tap(find.text('apply'));
    await tester.pumpAndSettle();

    expect(visited, [AppRoutes.roamingPlanConfirmation]);
    final extra = roamingExtras.single! as Map<String, Object?>;
    expect(extra['showDateField'], isTrue);
    expect(extra['forceNow'], isFalse);
  });
}
