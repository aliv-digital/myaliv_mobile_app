import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/view/guest_purchase_plan_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/daily_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/weekly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/monthly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roam_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roaming_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roameasy_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/liberty_global_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/wallet_payment_activate_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/wallet_payment_activate_or_future_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

const _noActivePlan =
    'the account owner has no active plan, so their new plan will start immediately.';
const _standalone =
    'the account owner standalone plan can start immediately, or on a date of choice.';
const _ownerStandalone =
    'your standalone plan can start immediately, or on a date of your choice.';

class _FakeNetworkService extends NetworkService {
  _FakeNetworkService(this.plans, {required this.existingPlans})
    : super(authManager: AuthManager(), onHardLogout: _noopLogout);

  final List<Map<String, dynamic>> plans;
  final Map<String, dynamic> existingPlans;

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
      data: (path == Api.guestExistingPlansUrl ? existingPlans : plans) as T,
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
  late List<Object?> confirmationExtras;
  late List<Object?> addOnExtras;
  late Map<String, dynamic> existingPlans;
  late List<Map<String, dynamic>> plans;

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
    confirmationExtras = [];
    addOnExtras = [];
    existingPlans = {
      'PrimaryPlans': <Map<String, dynamic>>[],
      'SecondaryPlans': <Map<String, dynamic>>[],
      'StandAlonePlans': <Map<String, dynamic>>[],
    };
    await instance.reset();
    plans = [
      _plan(id: 'p1', name: 'liberty40', type: 'P', frequency: 'M'),
      _plan(id: 'p2', name: 'liberty70', type: 'P', frequency: 'M'),
      _plan(
        id: 'r1',
        name: 'roam20',
        type: 'A',
        frequency: 'D',
        group: 'Roaming',
      ),
    ];
    instance.registerSingleton<NetworkService>(
      _FakeNetworkService(plans, existingPlans: existingPlans),
    );
  });

  tearDown(() async {
    await instance.reset();
  });

  Future<void> pumpScreen(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 1400);
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
        if (path == AppRoutes.guestPurchasePlanConfirmation) {
          confirmationExtras.add(state.extra);
        }
        if (path == AppRoutes.guestPurchasePlanAddOns) {
          addOnExtras.add(state.extra);
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
        (w) =>
            w is DailyPlanCard ||
            w is WeeklyPlanCard ||
            w is MonthlyPlanCard ||
            w is RoamingPlanCard ||
            w is RoamEasyPlanCard ||
            w is LibertyGlobalPlanCard,
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

  for (final width in [320.0, 430.0]) {
    testWidgets(
      'guest liberty global shows only the four listed destinations at $width',
      (tester) async {
        const allowed = [
          'liberty global Caribbean',
          'liberty global China',
          'liberty global Europe',
          'liberty global Haiti',
        ];
        plans.addAll([
          for (final name in [
            ...allowed,
            'global20',
            'liberty global Caribbean bundle',
          ])
            _plan(
              id: name,
              name: name,
              type: 'A',
              frequency: 'M',
              group: 'liberty global',
            ),
        ]);
        await pumpScreen(tester, width: width);
        await openTab(tester, 'liberty global');
        final verticalScroll = find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        );
        for (final name in allowed) {
          await tester.scrollUntilVisible(
            find.text(name),
            250,
            scrollable: verticalScroll,
          );
          expect(find.text(name), findsOneWidget);
        }
        expect(find.text('global20'), findsNothing);
        expect(find.text('liberty global Caribbean bundle'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'guest roameasy shows only the three listed destinations at $width',
      (tester) async {
        const allowed = [
          'roameasy usa & can',
          'roameasy carib',
          'roameasy europe',
        ];
        plans.addAll([
          for (final name in [
            ...allowed,
            'roameasy20',
            'roameasy europe bundle',
          ])
            _plan(
              id: name,
              name: name,
              type: 'A',
              frequency: 'W',
              group: 'roameasy',
            ),
        ]);
        await pumpScreen(tester, width: width);
        await openTab(tester, 'roameasy');
        for (final name in allowed) {
          expect(find.text(name), findsOneWidget);
        }
        expect(find.text('roameasy20'), findsNothing);
        expect(find.text('roameasy europe bundle'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('guest roaming shows only the three listed plans at $width', (
      tester,
    ) async {
      plans.removeWhere((plan) => plan['PlanGroup'] == 'Roaming');
      plans.addAll([
        for (final name in [
          'roam50',
          'roam30',
          'roam20',
          'roam500',
          'roam20 bundle',
        ])
          _plan(
            id: name,
            name: name,
            type: 'A',
            frequency: 'W',
            group: 'Roaming',
          ),
      ]);
      await pumpScreen(tester, width: width);
      await openTab(tester, 'roaming');
      for (final name in ['roam50', 'roam30', 'roam20']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('roam500'), findsNothing);
      expect(find.text('roam20 bundle'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'guest MiFi shows only the listed mifi and tab plans at $width',
      (tester) async {
        const allowed = [
          'mifi140',
          'mifi90',
          'mifi75',
          'tab140',
          'tab90',
          'tab75',
        ];
        plans.addAll([
          for (final name in [...allowed, 'mifi150', 'tab75 bundle'])
            _plan(
              id: name,
              name: name,
              type: 'P',
              frequency: 'M',
              group: 'mifi (30 day)',
            ),
        ]);
        await pumpScreen(tester, width: width);
        await openTab(tester, 'mifi');
        final verticalScroll = find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        );
        for (final name in allowed) {
          await tester.scrollUntilVisible(
            find.text(name),
            250,
            scrollable: verticalScroll,
          );
          expect(find.text(name), findsOneWidget);
        }
        expect(find.text('mifi150'), findsNothing);
        expect(find.text('tab75 bundle'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('guest primary tabs show only listed plans at $width', (
      tester,
    ) async {
      plans.clear();
      const namesByTab = {
        'daily': ('D', ['freedom5'], ['freedom50']),
        'weekly': (
          'W',
          ['freedom45', 'freedom15', 'freedom8'],
          ['freedom35', 'freedom12+'],
        ),
        'monthly': (
          'M',
          ['liberty120', 'liberty70', 'liberty40'],
          [r'liberty40 bundle for $90', 'liberty700'],
        ),
      };
      for (final (frequency, allowed, hidden) in namesByTab.values) {
        for (final name in [...allowed, ...hidden]) {
          plans.add(
            _plan(id: name, name: name, type: 'P', frequency: frequency),
          );
        }
      }
      await pumpScreen(tester, width: width);
      for (final tab in namesByTab.keys) {
        await openTab(tester, tab);
        final (_, allowed, hidden) = namesByTab[tab]!;
        for (final name in allowed) {
          expect(find.text(name), findsOneWidget);
        }
        for (final name in hidden) {
          expect(find.text(name), findsNothing);
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'a primary tab disappears when all of its plans are filtered out',
    (tester) async {
      plans.clear();
      plans.addAll([
        _plan(id: 'hidden', name: 'freedom35', type: 'P', frequency: 'W'),
        _plan(
          id: 'hidden-mifi',
          name: 'mifi150',
          type: 'P',
          frequency: 'M',
          group: 'mifi (30 day)',
        ),
        _plan(
          id: 'hidden-roaming',
          name: 'roam500',
          type: 'A',
          frequency: 'W',
          group: 'Roaming',
        ),
        _plan(
          id: 'hidden-roameasy',
          name: 'roameasy20',
          type: 'A',
          frequency: 'W',
          group: 'roameasy',
        ),
        _plan(
          id: 'hidden-global',
          name: 'global20',
          type: 'A',
          frequency: 'M',
          group: 'liberty global',
        ),
        _plan(id: 'allowed', name: 'liberty70', type: 'P', frequency: 'M'),
      ]);
      await pumpScreen(tester);
      expect(find.text('weekly'), findsNothing);
      expect(find.text('mifi'), findsNothing);
      expect(find.text('roaming'), findsNothing);
      expect(find.text('roameasy'), findsNothing);
      expect(find.text('liberty global'), findsNothing);
      expect(find.text('freedom35'), findsNothing);
      expect(find.text('liberty70'), findsOneWidget);
    },
  );

  for (final scenario in [
    'no primary',
    'future primary',
    'expired primary',
    'no add-ons',
    'no matches',
    'matching add-ons',
    'reordered name',
    'empty catalogue',
    'expired then active primary',
    'only numbered plan add-ons',
    'generic and numbered plan add-ons',
  ]) {
    testWidgets('guest add-ons tab visibility: $scenario', (tester) async {
      final now = DateTime.now();
      if (scenario == 'empty catalogue') {
        plans.clear();
      } else if (scenario != 'no primary') {
        existingPlans['PrimaryPlans'] = [
          {
            ..._plan(
              id: 'active',
              name: 'freedom45',
              type: 'P',
              frequency: 'W',
            ),
            'StartDate': now
                .add(Duration(days: scenario == 'future primary' ? 1 : -2))
                .toIso8601String(),
            'EndDate': now
                .add(Duration(days: scenario == 'expired primary' ? -1 : 7))
                .toIso8601String(),
            'AvailableBoltOns': scenario == 'no add-ons'
                ? []
                : [
                    _plan(
                      id: 'addon',
                      name: switch (scenario) {
                        'no matches' => 'travel data1',
                        'reordered name' => 'DATA freedom 10 offer',
                        _ => 'freedom data1',
                      },
                      type: 'S',
                      frequency: 'W',
                    ),
                  ],
          },
        ];
        if (scenario == 'only numbered plan add-ons' ||
            scenario == 'generic and numbered plan add-ons') {
          final primary = (existingPlans['PrimaryPlans'] as List).single as Map;
          primary['AvailableBoltOns'] = [
            for (final name in [
              'freedom45 data1',
              'freedom45 data10',
              'freedom45 data2',
              'freedom45 data3',
              'freedom35 data1',
              'freedom35 data2',
            ])
              _plan(id: name, name: name, type: 'S', frequency: 'W'),
            if (scenario == 'generic and numbered plan add-ons')
              _plan(
                id: 'generic',
                name: 'freedom data1',
                type: 'S',
                frequency: 'W',
              ),
          ];
        }
        if (scenario == 'expired then active primary') {
          (existingPlans['PrimaryPlans'] as List).insert(0, {
            ..._plan(
              id: 'expired',
              name: 'liberty-expired',
              type: 'P',
              frequency: 'M',
            ),
            'StartDate': now
                .subtract(const Duration(days: 5))
                .toIso8601String(),
            'EndDate': now.subtract(const Duration(days: 3)).toIso8601String(),
          });
        }
      }
      await pumpScreen(tester);
      final shouldShow =
          scenario == 'matching add-ons' ||
          scenario == 'reordered name' ||
          scenario == 'expired then active primary' ||
          scenario == 'generic and numbered plan add-ons';
      expect(find.text('add-ons'), shouldShow ? findsOneWidget : findsNothing);
      if (shouldShow) {
        await openTab(tester, 'add-ons');
        expect(
          find.text(
            scenario == 'reordered name'
                ? 'DATA freedom 10 offer'
                : 'freedom data1',
          ),
          findsOneWidget,
        );
        expect(find.text('proceed'), findsOneWidget);
        expect(find.text('freedom45'), findsOneWidget);
        expect(find.text('liberty-expired'), findsNothing);
        expect(find.text('freedom45 data10'), findsNothing);
        expect(find.text('freedom35 data1'), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('first primary uses the guest no-active-plan copy', (
    tester,
  ) async {
    await pumpScreen(tester);
    await purchaseNow(tester, 'liberty40');

    expect(find.byType(WalletPaymentActivateBottomSheet), findsOneWidget);
    expect(find.text(_noActivePlan), findsOneWidget);
    expect(find.textContaining('no current plan'), findsNothing);
    expect(find.text('activate now'), findsOneWidget);
    expect(find.text('future plan'), findsNothing);
    expect(find.text('start from'), findsNothing);

    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(visited, [AppRoutes.guestPurchasePlanConfirmation]);
    final args =
        confirmationExtras.single! as GuestPurchasePlanConfirmationRouteArgs;
    expect(args.phoneNumber, '242-555-1234');
    expect(args.primaryPlanName, 'liberty40');
    expect(args.primaryPlanPrice, 33);
    expect(args.primaryPlanBasePrice, 30);
    expect(args.selectedPlan?.id, 'p1');
    expect(args.forceNow, isTrue);
    expect(args.flow, GuestPurchasePlanConfirmationEntryFlow.skip);
    expect(args.selectedAddOns, isEmpty);
  });

  testWidgets('empty /Guest/existingplans uses direct confirmation for every '
      'primary (no plan-name special cases)', (tester) async {
    // /Guest/existingplans returns empty plan lists. The sheet
    // decision tree must pick WalletPaymentActivateBottomSheet (the "no
    // active plan" branch) uniformly — no plan-name routing.
    await pumpScreen(tester);
    await purchaseNow(tester, 'liberty70');

    expect(find.byType(WalletPaymentActivateBottomSheet), findsOneWidget);
    expect(find.text(_noActivePlan), findsOneWidget);
    expect(find.byType(WalletPaymentActivateOrFutureBottomSheet), findsNothing);
    expect(find.text('activate now'), findsOneWidget);
    expect(find.text('future plan'), findsNothing);
    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(visited, [AppRoutes.guestPurchasePlanConfirmation]);
  });

  for (final scenario in [
    'expired primary',
    'future primary',
    'secondary only',
  ]) {
    testWidgets('$scenario does not open add-ons for a primary purchase', (
      tester,
    ) async {
      final now = DateTime.now();
      final plan = _plan(
        id: 'existing',
        name: 'liberty70',
        type: scenario == 'secondary only' ? 'S' : 'P',
        frequency: 'M',
      );
      plan['StartDate'] = now
          .add(Duration(days: scenario == 'future primary' ? 2 : -30))
          .toIso8601String();
      plan['EndDate'] = now
          .add(Duration(days: scenario == 'expired primary' ? -1 : 30))
          .toIso8601String();
      existingPlans[scenario == 'secondary only'
          ? 'SecondaryPlans'
          : 'PrimaryPlans'] = [
        plan,
      ];
      await pumpScreen(tester);
      await purchaseNow(tester, 'liberty40');
      expect(find.text(_noActivePlan), findsOneWidget);
      await tester.tap(find.text('activate now'));
      await tester.pumpAndSettle();
      expect(visited, [AppRoutes.guestPurchasePlanConfirmation]);
    });
  }

  testWidgets('active primary keeps the existing add-ons route', (
    tester,
  ) async {
    plans.first['AvailableBoltOns'] = [
      _plan(id: 'allowed', name: 'freedom data1', type: 'S', frequency: 'M'),
    ];
    final now = DateTime.now();
    existingPlans['PrimaryPlans'] = [
      {
        ..._plan(id: 'active', name: 'liberty70', type: 'P', frequency: 'M'),
        'StartDate': now.subtract(const Duration(days: 1)).toIso8601String(),
        'EndDate': now.add(const Duration(days: 30)).toIso8601String(),
      },
    ];
    await pumpScreen(tester);
    await purchaseNow(tester, 'liberty40');
    expect(
      find.byType(WalletPaymentActivateOrFutureBottomSheet),
      findsOneWidget,
    );
    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(visited, [AppRoutes.guestPurchasePlanAddOns]);
    final args = addOnExtras.single! as GuestPurchasePlanAddOnsRouteArgs;
    expect(args.selectedPlan.id, 'p1');
    expect(args.selectedBasePlan?.planId, 'p1');
    expect(args.existingActivePlan?.planId, 'active');
  });

  for (final planName in ['freedom5', '  FrEeDoM5  ', 'freedom15']) {
    testWidgets(
      'active primary buying $planName uses the expected guest route',
      (tester) async {
        plans.add({
          ..._plan(
            id: 'd1',
            name: planName,
            type: 'P',
            frequency: planName == 'freedom15' ? 'W' : 'D',
          ),
          'AvailableBoltOns': [
            _plan(
              id: 'allowed',
              name: 'freedom data1',
              type: 'S',
              frequency: 'D',
            ),
          ],
        });
        final now = DateTime.now();
        existingPlans['PrimaryPlans'] = [
          {
            ..._plan(
              id: 'active',
              name: 'liberty70',
              type: 'P',
              frequency: 'M',
            ),
            'StartDate': now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
            'EndDate': now.add(const Duration(days: 30)).toIso8601String(),
          },
        ];
        await pumpScreen(tester);
        await openTab(tester, planName == 'freedom15' ? 'weekly' : 'daily');
        await purchaseNow(tester, planName.trim());
        expect(
          find.byType(WalletPaymentActivateOrFutureBottomSheet),
          findsOneWidget,
        );

        await tester.tap(find.text('activate now'));
        await tester.pumpAndSettle();

        if (planName == 'freedom15') {
          expect(visited, [AppRoutes.guestPurchasePlanAddOns]);
          final args = addOnExtras.single! as GuestPurchasePlanAddOnsRouteArgs;
          expect(args.selectedPlan.id, 'd1');
          expect(args.existingActivePlan?.planId, 'active');
        } else {
          expect(visited, [AppRoutes.guestPurchasePlanConfirmation]);
          expect(addOnExtras, isEmpty);
          final args =
              confirmationExtras.single!
                  as GuestPurchasePlanConfirmationRouteArgs;
          expect(args.phoneNumber, '242-555-1234');
          expect(args.primaryPlanName, planName.trim());
          expect(args.selectedPlan?.id, 'd1');
          expect(args.primaryPlanPrice, 33);
          expect(args.primaryPlanBasePrice, 30);
          expect(args.primaryPlanVatAmount, 3);
          expect(args.forceNow, isTrue);
          expect(args.flow, GuestPurchasePlanConfirmationEntryFlow.skip);
          expect(args.selectedAddOns, isEmpty);
        }
      },
    );
  }

  for (final (scenario, names, shouldShow) in [
    ('no add-ons', <String>[], false),
    (
      'numbered add-ons',
      ['freedom45 data1', 'freedom45 data10', 'freedom35 data2'],
      false,
    ),
    ('unrelated add-ons', ['travel data1'], false),
    ('generic add-on', ['freedom data1'], true),
    ('mixed add-ons', ['freedom45 data1', 'liberty data2'], true),
    ('reordered name', ['DATA freedom 10 offer'], true),
  ]) {
    testWidgets(
      'active primary purchase with $scenario chooses the right route',
      (tester) async {
        plans[0] = {
          ..._plan(id: 'p1', name: 'freedom45', type: 'P', frequency: 'W'),
          'AvailableBoltOns': [
            for (final name in names)
              _plan(id: name, name: name, type: 'S', frequency: 'W'),
          ],
        };
        final now = DateTime.now();
        existingPlans['PrimaryPlans'] = [
          {
            ..._plan(
              id: 'active',
              name: 'liberty70',
              type: 'P',
              frequency: 'M',
            ),
            'StartDate': now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
            'EndDate': now.add(const Duration(days: 30)).toIso8601String(),
            'AvailableBoltOns': [
              _plan(
                id: 'existing-addon',
                name: 'liberty data1',
                type: 'S',
                frequency: 'M',
              ),
            ],
          },
        ];
        await pumpScreen(tester);
        await openTab(tester, 'weekly');
        await purchaseNow(tester, 'freedom45');
        await tester.tap(find.text('activate now'));
        await tester.pumpAndSettle();

        if (shouldShow) {
          expect(visited, [AppRoutes.guestPurchasePlanAddOns]);
          final args = addOnExtras.single! as GuestPurchasePlanAddOnsRouteArgs;
          expect(args.selectedPlan.id, 'p1');
          expect(args.selectedBasePlan?.planName, 'freedom45');
          expect(args.existingActivePlan?.planId, 'active');
        } else {
          expect(visited, [AppRoutes.guestPurchasePlanConfirmation]);
          expect(addOnExtras, isEmpty);
          final args =
              confirmationExtras.single!
                  as GuestPurchasePlanConfirmationRouteArgs;
          expect(args.selectedPlan?.id, 'p1');
          expect(args.primaryPlanName, 'freedom45');
          expect(args.phoneNumber, '242-555-1234');
          expect(args.primaryPlanPrice, 33);
          expect(args.primaryPlanBasePrice, 30);
          expect(args.primaryPlanVatAmount, 3);
          expect(args.forceNow, isTrue);
          expect(args.flow, GuestPurchasePlanConfirmationEntryFlow.skip);
          expect(args.selectedAddOns, isEmpty);
        }
      },
    );
  }

  testWidgets(
    'allowed liberty global retains immediate standalone confirmation',
    (tester) async {
      plans.add(
        _plan(
          id: 'global',
          name: 'liberty global Haiti',
          type: 'A',
          frequency: 'M',
          group: 'liberty global',
        ),
      );
      await pumpScreen(tester);
      await openTab(tester, 'liberty global');
      await purchaseNow(tester, 'liberty global Haiti');
      expect(find.byType(RoamBottomSheet), findsOneWidget);
      expect(find.text('start from'), findsOneWidget);
      await tester.tap(find.text('activate now'));
      await tester.pumpAndSettle();
      expect(visited, [AppRoutes.roamingPlanConfirmation]);
      final args = roamingExtras.single! as Map<String, Object?>;
      expect(args['forceNow'], isTrue);
      expect(args['showDateField'], isFalse);
      expect(args['planName'], 'liberty global Haiti');
      expect(args['planPrice'], 33);
      expect(args['planBasePrice'], 30);
      expect(args['planVatAmount'], 3);
    },
  );

  testWidgets('allowed roameasy retains immediate standalone confirmation', (
    tester,
  ) async {
    plans.add(
      _plan(
        id: 'easy',
        name: 'roameasy usa & can',
        type: 'A',
        frequency: 'W',
        group: 'roameasy',
      ),
    );
    await pumpScreen(tester);
    await openTab(tester, 'roameasy');
    await purchaseNow(tester, 'roameasy usa & can');
    expect(find.byType(RoamBottomSheet), findsOneWidget);
    expect(find.text('start from'), findsOneWidget);
    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(visited, [AppRoutes.roamingPlanConfirmation]);
    final args = roamingExtras.single! as Map<String, Object?>;
    expect(args['forceNow'], isTrue);
    expect(args['showDateField'], isFalse);
    expect(args['planName'], 'roameasy usa & can');
    expect(args['planPrice'], 33);
    expect(args['planBasePrice'], 30);
    expect(args['planVatAmount'], 3);
  });

  testWidgets('standalone uses guest copy with activate now and date picker', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openTab(tester, 'roaming');
    await purchaseNow(tester, 'roam20');

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
    await purchaseNow(tester, 'roam20');
    await tester.tap(
      find.descendant(
        of: find.byType(RoamBottomSheet),
        matching: find.byIcon(Icons.arrow_back_rounded),
      ),
    );
    await tester.pumpAndSettle();
    await purchaseNow(tester, 'roam20');

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
