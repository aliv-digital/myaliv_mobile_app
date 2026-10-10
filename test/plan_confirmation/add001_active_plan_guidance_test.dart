import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/bloc/plan_purchase_plan_add_ons_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/bloc/plan_purchase_plan_add_ons_event.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/model/plan_purchase_plan_add_ons_route_args.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/view/plan_purchase_plan_add_ons_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_fair_use_policy_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

const _copy =
    "add-ons can only be added to your active primary plan and expire when it ends. if you don't want an add-on, select skip.";
const _oldCopy =
    "add-ons can only be added to your active primary plan and expires when it ends. if you don't want an add-on select skip.";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Account account;
  late _Devices devices;
  late _Plans plans;
  HomePlanConfirmationRouteArgs? confirmation;
  var navigationCount = 0;

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
    account = _Account();
    devices = _Devices();
    plans = _Plans();
    confirmation = null;
    navigationCount = 0;
    when(
      () => devices.state,
    ).thenReturn(const DeviceLimitsState(status: DeviceLimitsStatus.loaded));
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
  });

  tearDown(() async {
    await account.close();
    await devices.close();
    await plans.close();
    await instance.reset();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool active = true,
    bool prepaid = true,
    bool standalone = false,
    bool future = false,
    bool expired = false,
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => account.state).thenReturn(
      AccountInfoState(
        accountInfo: AccountInfoModel(
          paymentOption: prepaid ? 'PrePay' : 'PostPay',
        ),
      ),
    );
    final primary = BasePlanModel.fromApiMap({
      'PlanID': '123',
      'PlanName': 'liberty70',
      'PlanType': 'P',
      'PlanAmount': 70,
      'VatAmount': 7,
      'StartDate': future ? '2099-11-01' : '2000-01-01',
      'EndDate': expired ? '2001-01-01' : '2099-12-01',
    });
    final selected = standalone
        ? BasePlanModel.fromApiMap({...primary.toJson(), 'PlanType': 'A'})
        : primary;
    when(() => plans.state).thenReturn(
      PlansState(
        status: PlansStatus.success,
        addOnsApiPrimaryPlans: active ? [primary] : [],
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => PlanPurchasePlanAddOnsScreen(
            routeArgs: PlanPurchasePlanAddOnsRouteArgs(
              selectedApiPlan: selected,
              activePrimaryPlan: active ? primary : null,
              forceNow: true,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.homePlanConfirmationScreen,
          builder: (_, state) {
            confirmation = state.extra! as HomePlanConfirmationRouteArgs;
            navigationCount++;
            return const Scaffold(body: Text('existing confirmation'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<PlansCubit>.value(
        value: plans,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('active prepaid guidance is exact and neutral at $width', (
      tester,
    ) async {
      await pumpScreen(tester, width: width);
      expect(find.text(_copy), findsOneWidget);
      expect(find.text(_oldCopy), findsNothing);
      final text = tester.widget<Text>(find.text(_copy));
      expect(text.style!.color, const Color(0xFF222222));
      expect(find.text('skip'), findsOneWidget);
      expect(navigationCount, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'skip retains existing primary-only confirmation and ignores selected add-ons',
    (tester) async {
      await pumpScreen(tester);
      final bloc = tester
          .element(find.byType(PlanPurchaseFairUsePolicyCard))
          .read<PlanPurchasePlanAddOnsBloc>();
      bloc.add(
        const PlanPurchasePlanAddOnsSelectionToggled(
          addOnId: '456',
          selected: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('skip'));
      await tester.pumpAndSettle();
      expect(find.text('existing confirmation'), findsOneWidget);
      expect(navigationCount, 1);
      expect(confirmation!.flow, HomePlanConfirmationEntryFlow.skip);
      expect(confirmation!.primaryPlanId, '123');
      expect(confirmation!.primaryPlanPrice, 70);
      expect(confirmation!.selectedAddOns, isEmpty);
      expect(confirmation!.forceNow, isTrue);
    },
  );

  for (final scenario in [
    'no active plan',
    'postpaid',
    'standalone',
    'future primary',
    'expired primary',
  ]) {
    testWidgets('$scenario keeps existing copy and skip action', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        active: scenario != 'no active plan',
        prepaid: scenario != 'postpaid',
        standalone: scenario == 'standalone',
        future: scenario == 'future primary',
        expired: scenario == 'expired primary',
      );
      expect(find.text(_copy), findsNothing);
      expect(find.text(_oldCopy), findsOneWidget);
      expect(find.text('skip'), findsOneWidget);
      expect(navigationCount, 0);
      expect(tester.takeException(), isNull);
    });
  }
}
