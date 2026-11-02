import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/services/guest_plan_presentation_mapper.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/view/guest_purchase_plan_add_ons_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/widgets/add_on_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/bloc/guest_purchase_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/bloc/guest_purchase_plan_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/bloc/guest_purchase_plan_confirmation_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/repository/guest_purchase_plan_confirmation_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/view/guest_purchase_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

BasePlanModel _catalogPlan() => BasePlanModel.fromApiMap({
  'PlanID': '123',
  'PlanName': 'freedom5',
  'PlanAmount': 4.55,
  'VATAmount': 0.45,
  'PlanType': 'P',
  'Frequency': 'Daily',
  'AvailableBoltOns': [
    {
      'PlanID': '456',
      'PlanName': 'liberty data1',
      'PlanAmount': 2.73,
      'VATAmount': 0.27,
      'PlanType': 'S',
    },
  ],
});

GuestPurchasePlanConfirmationRouteArgs _args({
  GuestPurchasePlanConfirmationEntryFlow flow =
      GuestPurchasePlanConfirmationEntryFlow.skip,
  bool forceNow = true,
}) {
  final plan = const GuestPlanPresentationMapper().map(_catalogPlan());
  return GuestPurchasePlanConfirmationRouteArgs(
    phoneNumber: '2425550100',
    accountHolderName: 'guest purchase a plan',
    primaryPlanName: plan.title,
    primaryPlanPrice: plan.price,
    // Exercise the selectedPlan base-price fallback as well.
    selectedPlan: plan,
    flow: flow,
    forceNow: forceNow,
    futurePlanStartDate: '2027-02-03',
    selectedAddOns: const [
      GuestPurchasePlanConfirmationSelectedAddOn(
        id: '456',
        title: 'liberty data1',
        price: 2.73,
        vatAmount: 0.27,
      ),
    ],
  );
}

void _expectBreakdown(
  WidgetTester tester, {
  required double subTotal,
  required double vat,
  required double total,
}) {
  final card = tester.widget<CustomPaymentBreakDownCard>(
    find.byType(CustomPaymentBreakDownCard),
  );
  expect(
    {for (final item in card.items) item.label: item.value},
    {
      'sub total': AppUtils.formatPrice(subTotal),
      'vat': AppUtils.formatPrice(vat),
      'total': AppUtils.formatPrice(total),
    },
  );
  final payBar = tester.widget<DefaultBottomPayBar>(
    find.byType(DefaultBottomPayBar),
  );
  expect(payBar.amountText, AppUtils.formatPrice(total));
  expect(payBar.isVatExclusive, isFalse);
  expect(tester.takeException(), isNull);
}

void main() {
  for (final width in [320.0, 430.0]) {
    for (final flow in GuestPurchasePlanConfirmationEntryFlow.values) {
      for (final forceNow in [true, false]) {
        testWidgets('VAT breakdown at $width, $flow, immediate=$forceNow', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              home: GuestPurchasePlanConfirmationScreen(
                args: _args(flow: flow, forceNow: forceNow),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final hasAddOn =
              flow == GuestPurchasePlanConfirmationEntryFlow.proceed;
          _expectBreakdown(
            tester,
            subTotal: hasAddOn ? 7.28 : 4.55,
            vat: hasAddOn ? 0.72 : 0.45,
            total: hasAddOn ? 8 : 5,
          );
        });
      }
    }
  }

  test('removing a taxed add-on recalculates both subtotal and VAT', () async {
    final bloc = GuestPurchasePlanConfirmationBloc(
      repository: GuestPurchasePlanConfirmationRepository(),
    );
    addTearDown(bloc.close);
    bloc.add(
      GuestPurchasePlanConfirmationStarted(
        _args(flow: GuestPurchasePlanConfirmationEntryFlow.proceed),
      ),
    );
    final loaded = await bloc.stream.firstWhere(
      (state) => state.status == GuestPurchasePlanConfirmationStatus.ready,
    );
    expect(loaded.data!.totals.total, closeTo(8, 0.001));

    bloc.add(const GuestPurchasePlanConfirmationRemoveItemPressed('456'));
    final removed = await bloc.stream.firstWhere(
      (state) => state.data!.items.length == 1,
    );
    expect(removed.data!.totals.subTotal, closeTo(4.55, 0.001));
    expect(removed.data!.totals.vat, closeTo(0.45, 0.001));
    expect(removed.data!.totals.total, closeTo(5, 0.001));

    bloc.add(const GuestPurchasePlanConfirmationRemoveItemPressed('primary'));
    final cleared = await bloc.stream.firstWhere(
      (state) => state.data!.items.isEmpty,
    );
    expect(cleared.data!.totals, const PurchaseTotals(subTotal: 0, vat: 0));
  });

  test(
    'legacy arguments without base or VAT retain their payable total',
    () async {
      final data = await GuestPurchasePlanConfirmationRepository().load(
        args: const GuestPurchasePlanConfirmationRouteArgs(
          phoneNumber: '2425550100',
          accountHolderName: 'guest purchase a plan',
          primaryPlanName: 'plan',
          primaryPlanPrice: 5,
          flow: GuestPurchasePlanConfirmationEntryFlow.skip,
        ),
      );
      expect(data.totals, const PurchaseTotals(subTotal: 5, vat: 0));
    },
  );

  testWidgets('catalog add-on VAT survives selection and navigation', (
    tester,
  ) async {
    final catalog = _catalogPlan();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => GuestPurchasePlanAddOnsScreen(
            args: GuestPurchasePlanAddOnsRouteArgs(
              phoneNumber: '2425550100',
              selectedPlan: const GuestPlanPresentationMapper().map(catalog),
              selectedBasePlan: catalog,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.guestPurchasePlanConfirmation,
          builder: (_, state) => GuestPurchasePlanConfirmationScreen(
            args: state.extra! as GuestPurchasePlanConfirmationRouteArgs,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.byType(AddOnTile), findsOneWidget);
    await tester.tap(find.text('liberty data1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('proceed'));
    await tester.pumpAndSettle();

    _expectBreakdown(tester, subTotal: 7.28, vat: 0.72, total: 8);
  });
}
