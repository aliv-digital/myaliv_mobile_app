import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/widgets/terms_notice.dart';
import 'dart:async';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/promo_subtotal_validation.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_promo_response_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/repository/home_plan_confirmation_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/view/home_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/bloc/home_roaming_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/bloc/home_roaming_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/bloc/home_roaming_confirmation_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/models/home_roaming_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/models/home_roaming_promo_response_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/repository/home_roaming_confirmation_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/purchase_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revConfirmation/prepaid/bloc/rev_confirmation_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revConfirmation/prepaid/bloc/rev_confirmation_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revConfirmation/prepaid/bloc/rev_confirmation_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revConfirmation/prepaid/repository/rev_confirmation_prepaid_repository.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class Devices extends Mock implements DeviceLimitsCubit {}

class Account extends Mock implements AccountInfoCubit {}

class Network extends Mock implements NetworkService {}

class HomeRepo extends Mock implements HomePlanConfirmationRepository {}

class RoamRepo extends Mock implements HomeRoamingConfirmationRepository {}

class RevRepo extends Mock implements RevConfirmationPrepaidRepository {}

const args = HomePlanConfirmationRouteArgs(
  phoneNumber: '2420000000',
  accountHolderName: 'Test',
  primaryPlanId: '1',
  primaryPlanName: 'Plan',
  primaryPlanPrice: 20,
  primaryPlanVatAmount: 2,
  flow: HomePlanConfirmationEntryFlow.proceed,
  forceNow: true,
  selectedAddOns: [
    HomePlanConfirmationSelectedAddOn(
      id: '2',
      title: 'Add-on',
      price: 10,
      vatAmount: 1,
    ),
  ],
);
Map<String, dynamic> payload(
  double qty, {
  String type = 'dollar',
  int id = 1,
}) => {
  'PromoCodeID': id,
  'Definition': {'UnitType': type, 'UnitQty': qty},
};
Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late Devices devices;
  setUp(() async {
    await instance.reset();
    final account = Account();
    when(() => account.state).thenReturn(const AccountInfoState());
    instance.registerSingleton<AccountInfoCubit>(account);
    devices = Devices();
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          DeviceLimitsModel.fromJson({'DeviceID': 1}),
        ],
      ),
    );
    instance.registerSingleton<DeviceLimitsCubit>(devices);
  });
  tearDown(() async {
    await instance.reset();
  });
  group('uncapped monetary validation', () {
    for (final type in ['dollar', 'percentage', 'other', ' PERCENTAGE ']) {
      for (final ratio in [0.5, 1.0, 1.25]) {
        test('$type $ratio of subtotal', () {
          final percentage = type.trim().toLowerCase() == 'percentage';
          final discount = PromoSubtotalValidation.monetaryDiscount(
            unitType: type,
            unitQty: percentage ? ratio * 100 : ratio * 20,
            subtotal: 20,
          );
          expect(discount, ratio * 20);
          expect(
            PromoSubtotalValidation.exceedsSubtotal(
              discount: discount,
              subtotal: 20,
            ),
            ratio > 1,
          );
        });
      }
    }
    test('zero subtotal retains fixed candidate', () {
      expect(
        PromoSubtotalValidation.monetaryDiscount(
          unitType: 'dollar',
          unitQty: 1,
          subtotal: 0,
        ),
        1,
      );
      expect(
        PromoSubtotalValidation.exceedsSubtotal(discount: 1, subtotal: 0),
        isTrue,
      );
      expect(
        PromoSubtotalValidation.monetaryDiscount(
          unitType: 'percentage',
          unitQty: 125,
          subtotal: 0,
        ),
        0,
      );
      expect(
        PromoSubtotalValidation.exceedsSubtotal(discount: 0, subtotal: 0),
        isFalse,
      );
    });
    test('decimal and fractional cents have no tolerance or rounding', () {
      for (final value in [19.999, 20.0, 20.001]) {
        expect(
          PromoSubtotalValidation.exceedsSubtotal(
            discount: value,
            subtotal: 20,
          ),
          value > 20,
        );
      }
      expect(
        PromoSubtotalValidation.monetaryDiscount(
          unitType: null,
          unitQty: 0.015,
          subtotal: 1,
        ),
        0.015,
      );
    });
  });
  group('home plan', () {
    late HomeRepo repo;
    late HomePlanConfirmationBloc bloc;
    setUp(() {
      repo = HomeRepo();
      when(() => repo.load(args: args)).thenAnswer(
        (_) => HomePlanConfirmationRepository(
          networkService: Network(),
        ).load(args: args),
      );
      bloc = HomePlanConfirmationBloc(
        repository: repo,
        deviceLimitsCubit: devices,
      );
    });
    tearDown(() => bloc.close());
    Future<void> ready() async {
      bloc.add(const HomePlanConfirmationStarted(args));
      await tick();
      bloc.add(const HomePlanConfirmationPromoCodeChanged('TEST'));
      await tick();
    }

    for (final qty in [15.0, 30.0, 35.0]) {
      test('fixed $qty against 30', () async {
        when(
          () => repo.applyPromo(code: 'TEST', deviceAcId: 1),
        ).thenAnswer((_) async => HomePlanPromoResponse.fromJson(payload(qty)));
        await ready();
        bloc.add(const HomePlanConfirmationPromoApplyPressed());
        await tick();
        expect(bloc.state.hasAppliedPromo, qty <= 30);
        if (qty > 30) {
          expect(
            bloc.state.promoErrorMessage,
            PromoSubtotalValidation.errorMessage,
          );
          expect(bloc.state.promoResponse, isNull);
          expect(bloc.state.displayTotals.total, 33);
        } else {
          expect(bloc.state.promoDiscount, qty);
          expect(bloc.state.displayTotals.total, (30 - qty) * 1.1);
        }
      });
    }
    for (final type in ['dollar', 'percentage']) {
      test('removal revalidates $type', () async {
        when(() => repo.applyPromo(code: 'TEST', deviceAcId: 1)).thenAnswer(
          (_) async => HomePlanPromoResponse.fromJson(
            payload(type == 'dollar' ? 25 : 50, type: type),
          ),
        );
        await ready();
        bloc.add(const HomePlanConfirmationPromoApplyPressed());
        await tick();
        bloc.add(const HomePlanConfirmationRemoveItemPressed('2'));
        await tick();
        expect(bloc.state.hasAppliedPromo, type == 'percentage');
        expect(bloc.state.displayTotals.total, type == 'percentage' ? 11 : 22);
        if (type == 'dollar') expect(bloc.state.promoResponse, isNull);
      });
    }
    test('pending response is discarded after item removal', () async {
      final pending = Completer<HomePlanPromoResponse>();
      when(
        () => repo.applyPromo(code: 'TEST', deviceAcId: 1),
      ).thenAnswer((_) => pending.future);
      await ready();
      bloc.add(const HomePlanConfirmationPromoApplyPressed());
      await tick();
      bloc.add(const HomePlanConfirmationRemoveItemPressed('2'));
      await tick();
      pending.complete(HomePlanPromoResponse.fromJson(payload(5)));
      await tick();
      expect(bloc.state.hasAppliedPromo, isFalse);
      expect(bloc.state.promoResponse, isNull);
      expect(bloc.state.displayTotals.total, 22);
    });
    test('API invalid remains Invalid promo', () async {
      when(() => repo.applyPromo(code: 'TEST', deviceAcId: 1)).thenAnswer(
        (_) async => HomePlanPromoResponse.fromJson(payload(100, id: 0)),
      );
      await ready();
      bloc.add(const HomePlanConfirmationPromoApplyPressed());
      await tick();
      expect(bloc.state.promoErrorMessage, 'Invalid promo');
    });
    for (final percentage in [50.0, 100.0, 125.0]) {
      test(
        'percentage $percentage preserves successful calculations',
        () async {
          when(() => repo.applyPromo(code: 'TEST', deviceAcId: 1)).thenAnswer(
            (_) async => HomePlanPromoResponse.fromJson(
              payload(percentage, type: 'percentage'),
            ),
          );
          await ready();
          bloc.add(const HomePlanConfirmationPromoApplyPressed());
          await tick();
          expect(bloc.state.hasAppliedPromo, percentage <= 100);
          expect(bloc.state.promoResponse == null, percentage > 100);
          if (percentage > 100) {
            expect(
              bloc.state.promoErrorMessage,
              PromoSubtotalValidation.errorMessage,
            );
          }
        },
      );
    }
    test(
      'code edit prevents older result overwriting newer application',
      () async {
        final pending = Completer<HomePlanPromoResponse>();
        when(
          () => repo.applyPromo(code: 'TEST', deviceAcId: 1),
        ).thenAnswer((_) => pending.future);
        when(
          () => repo.applyPromo(code: 'NEW', deviceAcId: 1),
        ).thenAnswer((_) async => HomePlanPromoResponse.fromJson(payload(5)));
        await ready();
        bloc.add(const HomePlanConfirmationPromoApplyPressed());
        await tick();
        bloc.add(const HomePlanConfirmationPromoCodeChanged('NEW'));
        await tick();
        bloc.add(const HomePlanConfirmationPromoApplyPressed());
        await tick();
        pending.complete(HomePlanPromoResponse.fromJson(payload(35)));
        await tick();
        expect(bloc.state.hasAppliedPromo, isTrue);
        expect(bloc.state.promoCode, 'NEW');
        expect(bloc.state.promoDiscount, 5);
      },
    );
    test('network failure message remains unchanged', () async {
      when(
        () => repo.applyPromo(code: 'TEST', deviceAcId: 1),
      ).thenThrow(Exception('Request timeout. Please try again.'));
      await ready();
      bloc.add(const HomePlanConfirmationPromoApplyPressed());
      await tick();
      expect(
        bloc.state.promoErrorMessage,
        'Request timeout. Please try again.',
      );
    });
  });
  group('roaming', () {
    late RoamRepo repo;
    late HomeRoamingConfirmationBloc bloc;
    final roamArgs = HomeRoamingConfirmationRouteArgs(
      phoneNumber: '2420000000',
      showDateField: false,
      selectedPlan: BasePlanModel.fromApiMap({
        'PlanID': '1',
        'PlanAmount': 20,
        'VATAmount': 2,
      }),
    );
    setUp(() {
      repo = RoamRepo();
      when(() => repo.load(args: roamArgs)).thenAnswer(
        (_) => HomeRoamingConfirmationRepository(
          networkService: Network(),
        ).load(args: roamArgs),
      );
      bloc = HomeRoamingConfirmationBloc(
        repository: repo,
        accountInfoCubit: Account(),
      );
    });
    tearDown(() => bloc.close());
    Future<void> ready() async {
      bloc.add(HomeRoamingConfirmationStarted(roamArgs));
      await tick();
      bloc.add(const HomeRoamingConfirmationPromoCodeChanged('TEST'));
      await tick();
    }

    test('oversized response cannot be saved', () async {
      when(
        () => repo.applyPromo(code: 'TEST', deviceAcId: 1),
      ).thenAnswer((_) async => HomeRoamingPromoResponse.fromJson(payload(25)));
      await ready();
      final total = bloc.state.data!.totals.total;
      bloc.add(const HomeRoamingConfirmationPromoApplyPressed());
      await tick();
      expect(
        bloc.state.promoStatus,
        HomeRoamingConfirmationPromoStatus.failure,
      );
      expect(
        bloc.state.promoErrorMessage,
        PromoSubtotalValidation.errorMessage,
      );
      expect(bloc.state.promoResponse, isNull);
      expect(bloc.state.data!.totals.total, total);
    });
    test('removal rejects an applied fixed promo', () async {
      when(
        () => repo.applyPromo(code: 'TEST', deviceAcId: 1),
      ).thenAnswer((_) async => HomeRoamingPromoResponse.fromJson(payload(1)));
      await ready();
      bloc.add(const HomeRoamingConfirmationPromoApplyPressed());
      await tick();
      expect(
        bloc.state.promoStatus,
        HomeRoamingConfirmationPromoStatus.applied,
      );
      bloc.add(const HomeRoamingConfirmationRemoveItemPressed('1'));
      await tick();
      expect(bloc.state.promoResponse, isNull);
      expect(
        bloc.state.promoErrorMessage,
        PromoSubtotalValidation.errorMessage,
      );
    });
    test('pending response after removal is ignored', () async {
      final pending = Completer<HomeRoamingPromoResponse>();
      when(
        () => repo.applyPromo(code: 'TEST', deviceAcId: 1),
      ).thenAnswer((_) => pending.future);
      await ready();
      bloc.add(const HomeRoamingConfirmationPromoApplyPressed());
      await tick();
      bloc.add(const HomeRoamingConfirmationRemoveItemPressed('1'));
      await tick();
      pending.complete(HomeRoamingPromoResponse.fromJson(payload(1)));
      await tick();
      expect(bloc.state.promoResponse, isNull);
      expect(bloc.state.promoStatus, HomeRoamingConfirmationPromoStatus.idle);
    });
  });
  group('REV', () {
    late RevRepo repo;
    late RevConfirmationPrepaidBloc bloc;
    setUp(() {
      repo = RevRepo();
      when(() => repo.fetchConfirmation()).thenAnswer(
        (_) async => const RevConfirmationData(
          customerName: 'Test',
          service: 'REV',
          accountNumber: '1',
          amount: 20,
          vat: 2,
        ),
      );
      bloc = RevConfirmationPrepaidBloc(repository: repo);
    });
    tearDown(() => bloc.close());
    for (final discount in [0.0, 10.0, 20.0, 25.0]) {
      test('monetary result $discount', () async {
        when(
          () => repo.applyPromo(code: 'TEST', subtotal: 20),
        ).thenAnswer((_) async => PromoResult(discount: discount));
        bloc.add(const RevConfirmationStarted());
        await tick();
        bloc.add(const RevPromoCodeChanged('TEST'));
        await tick();
        bloc.add(const RevPromoApplyPressed());
        await tick();
        expect(
          bloc.state.promoStatus,
          discount > 0 && discount <= 20
              ? RevPromoStatus.applied
              : RevPromoStatus.invalid,
        );
        expect(bloc.state.discount, discount <= 20 ? discount : 0);
        if (discount > 20) {
          expect(
            bloc.state.promoErrorMessage,
            PromoSubtotalValidation.errorMessage,
          );
          expect(bloc.state.total, 22);
        }
      });
    }
  });
  for (final qty in [15.0, 30.0, 35.0]) {
    testWidgets('home promo $qty toast and payment arguments', (tester) async {
      final network = Network();
      instance.registerSingleton<NetworkService>(network);
      when(
        () => network.request<dynamic>(any(), method: HttpMethod.get),
      ).thenAnswer(
        (_) async =>
            Response(data: payload(qty), requestOptions: RequestOptions()),
      );
      HomePlansPaymentMethodRouteArgs? payment;
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const HomePlanConfirmationScreen(args: args),
          ),
          GoRoute(
            path: AppRoutes.homePlansPaymentMethodScreen,
            builder: (_, state) {
              payment = state.extra as HomePlansPaymentMethodRouteArgs;
              return const Scaffold(body: Text('payment'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'TEST');
      await tester.ensureVisible(find.text('apply'));
      await tester.tap(find.text('apply'));
      await tester.pumpAndSettle();
      expect(
        find.text(PromoSubtotalValidation.errorMessage),
        qty > 30 ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('promo applied'),
        qty > 30 ? findsNothing : findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 4));
      final terms = find.byType(TermsNotice);
      await tester.ensureVisible(terms);
      await tester.tap(
        find.descendant(of: terms, matching: find.byType(InkWell)).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('continue'));
      await tester.pumpAndSettle();
      expect(payment!.amount, qty > 30 ? 33 : (30 - qty) * 1.1);
      expect(payment!.promoCodes.length, qty > 30 ? 0 : 1);
      if (qty <= 30) expect(payment!.promoCodes.single.discountAmount, qty);
    });
  }
  for (final qty in [10.0, 20.0, 25.0]) {
    testWidgets('postpaid apply $qty against subtotal 20', (tester) async {
      final network = Network();
      instance.registerSingleton<NetworkService>(network);
      when(
        () => network.request<dynamic>(any(), method: HttpMethod.get),
      ).thenAnswer(
        (_) async =>
            Response(data: payload(qty), requestOptions: RequestOptions()),
      );
      final plan = HomePlansPostPaidPlanModel.fromApiMap({
        'PlanID': '1',
        'PlanName': 'Test',
        'PlanAmount': 20,
      });
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: ConfirmationScreen(plan: plan),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'TEST');
      await tester.ensureVisible(find.text('apply'));
      await tester.tap(find.text('apply'));
      await tester.pumpAndSettle();
      expect(
        find.text(PromoSubtotalValidation.errorMessage),
        qty > 20 ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Promo code applied successfully.'),
        qty > 20 ? findsNothing : findsOneWidget,
      );
      // This flow already leaves the payment amount unchanged for valid promos.
      expect(find.text(r'$ 20.00'), findsWidgets);
      await tester.pump(const Duration(seconds: 4));
    });
  }
  for (final pendingChange in [false, true]) {
    testWidgets(
      'postpaid ${pendingChange ? 'pending' : 'applied'} promo and changed plan',
      (tester) async {
        final network = Network();
        instance.registerSingleton<NetworkService>(network);
        final pending = Completer<Response<dynamic>>();
        when(
          () => network.request<dynamic>(any(), method: HttpMethod.get),
        ).thenAnswer((_) => pending.future);
        HomePlansPostPaidPlanModel plan(double amount) =>
            HomePlansPostPaidPlanModel.fromApiMap({
              'PlanID': '1',
              'PlanName': 'Test',
              'PlanAmount': amount,
            });
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: rootNavigatorKey,
            home: ConfirmationScreen(plan: plan(30)),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'TEST');
        await tester.ensureVisible(find.text('apply'));
        await tester.tap(find.text('apply'));
        await tester.pump();
        if (!pendingChange) {
          pending.complete(
            Response(data: payload(25), requestOptions: RequestOptions()),
          );
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 4));
        }
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: rootNavigatorKey,
            home: ConfirmationScreen(plan: plan(20)),
          ),
        );
        await tester.pump();
        if (pendingChange) {
          pending.complete(
            Response(data: payload(5), requestOptions: RequestOptions()),
          );
          await tester.pumpAndSettle();
          expect(find.text('Promo code applied successfully.'), findsNothing);
          expect(find.text(PromoSubtotalValidation.errorMessage), findsNothing);
        } else {
          await tester.pump();
          expect(
            find.text(PromoSubtotalValidation.errorMessage),
            findsOneWidget,
          );
        }
        await tester.pump(const Duration(seconds: 4));
      },
    );
  }
}
