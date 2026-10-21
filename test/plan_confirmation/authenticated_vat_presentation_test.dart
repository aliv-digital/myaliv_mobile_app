import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/purchase_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_bottom_bar.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_terms_checkbox.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_plan_card_postpaid_content.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/view/home_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/widgets/purchase_item_row.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/bloc/home_roaming_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/bloc/home_roaming_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/models/home_roaming_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/view/home_roaming_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/widgets/home_roaming_confirmation_purchase_item_row.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

void main() {
  late _Devices devices;
  late _Account account;
  HomePlansPaymentMethodRouteArgs? payment;

  setUp(() {
    devices = _Devices();
    account = _Account();
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    when(() => account.state).thenReturn(const AccountInfoState());
    instance.registerSingleton<NetworkService>(_Network());
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<AccountInfoCubit>(account);
    payment = null;
  });
  tearDown(() async {
    await devices.close();
    await account.close();
    await instance.reset();
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => screen),
        GoRoute(
          path: AppRoutes.homePlansPaymentMethodScreen,
          builder: (_, state) {
            payment = state.extra! as HomePlansPaymentMethodRouteArgs;
            return const Scaffold(body: Text('payment destination'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<AccountInfoCubit>.value(
        value: account,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectTotals(WidgetTester tester, double base, double vat) {
    final card = tester.widget<CustomPaymentBreakDownCard>(
      find.byType(CustomPaymentBreakDownCard),
    );
    String value(String label) => card.items
        .firstWhere((x) => x.label.replaceAll(' ', '') == label)
        .value;
    expect(value('subtotal'), AppUtils.formatPrice(base));
    expect(value('vat'), AppUtils.formatPrice(vat));
    expect(value('total'), AppUtils.formatPrice(base + vat));
    expect(
      tester
          .widget<DefaultBottomPayBar>(find.byType(DefaultBottomPayBar))
          .amountText,
      AppUtils.formatPrice(base + vat),
    );
  }

  for (final vat in [0.0, 3.17]) {
    for (final scenario in ['primary', 'combined', 'addons', 'skip']) {
      testWidgets('home $scenario VAT $vat: base rows, totals and handoff', (
        tester,
      ) async {
        final primary = BasePlanModel.fromApiMap({
          'PlanID': '101',
          'PlanName': 'primary',
          'PlanAmount': 47.23,
          'VATAmount': vat,
        });
        final addon = BasePlanModel.fromApiMap({
          'PlanID': '202',
          'PlanName': 'addon',
          'PlanAmount': 12.41,
          'VATAmount': vat == 0 ? 0 : 0.83,
        });
        final active = scenario == 'addons';
        final includeAddon = scenario == 'combined' || active;
        final args = HomePlanConfirmationRouteArgs(
          phoneNumber: '2428011616',
          accountHolderName: 'Test',
          primaryPlanId: primary.planId,
          primaryPlanName: primary.planName,
          primaryPlanPrice: primary.planAmount,
          primaryPlanVatAmount: primary.vatAmount,
          primaryPlanTypeCode: 'P',
          isPrimaryPlanActive: active,
          forceNow: true,
          flow: scenario == 'skip'
              ? HomePlanConfirmationEntryFlow.skip
              : HomePlanConfirmationEntryFlow.proceed,
          selectedAddOns: scenario == 'primary'
              ? []
              : [
                  HomePlanConfirmationSelectedAddOn(
                    id: addon.planId,
                    title: addon.planName,
                    price: addon.planAmount,
                    vatAmount: addon.vatAmount,
                  ),
                ],
        );
        await pump(tester, HomePlanConfirmationScreen(args: args));
        final rows = tester
            .widgetList<PurchaseItemRow>(find.byType(PurchaseItemRow))
            .toList();
        expect(rows.length, (active ? 0 : 1) + (includeAddon ? 1 : 0));
        for (final row in rows) {
          expect(
            find.descendant(
              of: find.byWidget(row),
              matching: find.text(AppUtils.formatPrice(row.item.price)),
            ),
            findsOneWidget,
          );
        }
        final bloc = tester
            .element(find.byType(PurchaseItemRow).first)
            .read<HomePlanConfirmationBloc>();
        var base =
            (active ? 0.0 : primary.planAmount) +
            (includeAddon ? addon.planAmount : 0);
        var tax =
            (active ? 0.0 : primary.vatAmount) +
            (includeAddon ? addon.vatAmount : 0);
        expectTotals(tester, base, tax);
        if (scenario == 'combined') {
          bloc.add(HomePlanConfirmationRemoveItemPressed(addon.planId));
          await tester.pumpAndSettle();
          base = primary.planAmount;
          tax = primary.vatAmount;
          expectTotals(tester, base, tax);
        }
        bloc.add(const HomePlanConfirmationTermsCheckboxToggled(true));
        await tester.pumpAndSettle();
        await tester.tap(find.text('continue'));
        await tester.pumpAndSettle();
        expect(payment?.amount, closeTo(base + tax, 0.000001));
        expect(
          payment?.selectedItems.length,
          scenario == 'combined' ? 1 : rows.length,
        );
      });
    }

    testWidgets('roaming VAT $vat: base price, totals, handoff', (
      tester,
    ) async {
      final plan = BasePlanModel.fromApiMap({
        'PlanID': '303',
        'PlanName': 'travel',
        'PlanType': 'A',
        'PlanAmount': 23.67,
        'VATAmount': vat,
      });
      await pump(
        tester,
        HomeRoamingConfirmationScreen(
          args: HomeRoamingConfirmationRouteArgs(
            phoneNumber: '2428011616',
            selectedPlan: plan,
            showDateField: false,
            forceNow: true,
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(HomeRoamingConfirmationPurchaseItemRow),
          matching: find.text(AppUtils.formatPrice(plan.planAmount)),
        ),
        findsOneWidget,
      );
      expectTotals(tester, plan.planAmount, vat);
      final bloc = tester
          .element(find.byType(HomeRoamingConfirmationPurchaseItemRow))
          .read<HomeRoamingConfirmationBloc>();
      bloc.add(const HomeRoamingConfirmationTermsCheckboxToggled(true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('continue'));
      await tester.pumpAndSettle();
      expect(payment?.amount, plan.planAmount + vat);
      expect(payment?.selectedItems.single.price, plan.planAmount);
    });

    testWidgets(
      'roaming VAT $vat: removal clears tax and blocks callback and Bloc',
      (tester) async {
        final plan = BasePlanModel.fromApiMap({
          'PlanID': '303',
          'PlanName': 'travel',
          'PlanType': 'A',
          'PlanAmount': 23.67,
          'VATAmount': vat,
        });
        await pump(
          tester,
          HomeRoamingConfirmationScreen(
            args: HomeRoamingConfirmationRouteArgs(
              phoneNumber: '2428011616',
              selectedPlan: plan,
              showDateField: false,
              forceNow: true,
            ),
          ),
        );
        final bloc = tester
            .element(find.byType(HomeRoamingConfirmationPurchaseItemRow))
            .read<HomeRoamingConfirmationBloc>();
        bloc.add(const HomeRoamingConfirmationTermsCheckboxToggled(true));
        bloc.add(HomeRoamingConfirmationRemoveItemPressed(plan.planId));
        await tester.pumpAndSettle();
        expectTotals(tester, 0, 0);
        final bar = tester.widget<DefaultBottomPayBar>(
          find.byType(DefaultBottomPayBar),
        );
        expect(bar.isButtonEnabled, isFalse);
        bar.onPayNow();
        bloc.add(const HomeRoamingConfirmationPayNowPressed());
        await tester.pumpAndSettle();
        expect(bloc.state.payNowRequestId, 0);
        expect(payment, isNull);
      },
    );

    testWidgets('postpaid confirmation shows API base with VAT $vat', (
      tester,
    ) async {
      final plan = HomePlansPostPaidPlanModel.fromApiMap({
        'PlanID': '404',
        'PlanName': 'postpaid',
        'PlanAmount': 61.29,
        'VATAmount': vat,
      });
      final config = AppUiConfigCubit()..setUserType(UserType.postpaid);
      addTearDown(config.close);
      await pump(
        tester,
        BlocProvider<AppUiConfigCubit>.value(
          value: config,
          child: ConfirmationScreen(plan: plan),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(ConfirmationPlanCardPostpaidContent),
          matching: find.text(AppUtils.formatPrice(plan.planAmount)),
        ),
        findsOneWidget,
      );
      final card = tester.widget<CustomPaymentBreakDownCard>(
        find.byType(CustomPaymentBreakDownCard),
      );
      expect(card.items.map((x) => x.value), [
        AppUtils.formatPrice(plan.planAmount),
        AppUtils.formatPrice(vat),
        AppUtils.formatPrice(plan.planAmountWithVat),
      ]);
      expect(
        tester
            .widget<ConfirmationBottomBar>(find.byType(ConfirmationBottomBar))
            .totalText,
        AppUtils.formatPrice(plan.planAmountWithVat),
      );
      tester
          .widget<ConfirmationTermsCheckbox>(
            find.byType(ConfirmationTermsCheckbox),
          )
          .onChanged(true);
      await tester.pumpAndSettle();
      await tester.tap(find.text('continue'));
      await tester.pumpAndSettle();
      expect(payment?.amount, plan.planAmountWithVat);
      expect(payment?.selectedItems.single.price, plan.planAmount);
    });
  }
}
