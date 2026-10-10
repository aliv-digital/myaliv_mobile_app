import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/view/home_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/widgets/terms_notice.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

const _args = HomePlanConfirmationRouteArgs(
  phoneNumber: '242-801-1616',
  accountHolderName: 'Test user',
  primaryPlanId: '123',
  primaryPlanName: 'liberty100',
  primaryPlanTypeCode: 'P',
  primaryPlanPrice: 100,
  primaryPlanVatAmount: 10,
  flow: HomePlanConfirmationEntryFlow.skip,
  forceNow: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Network network;
  late _Devices devices;
  late Completer<Response<dynamic>> pendingPromo;
  HomePlansPaymentMethodRouteArgs? paymentArgs;

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
    devices = _Devices();
    paymentArgs = null;
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          DeviceLimitsModel.fromJson({'DeviceID': 4242}),
        ],
      ),
    );
    when(
      () => network.request<dynamic>(any(), method: HttpMethod.get),
    ).thenAnswer((_) => pendingPromo.future);
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
  });

  tearDown(() async {
    await devices.close();
    await instance.reset();
  });

  Future<HomePlanConfirmationBloc> pumpScreen(WidgetTester tester) async {
    // Create the response in the widget test's clock/zone for one-frame checks.
    pendingPromo = Completer<Response<dynamic>>();
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const HomePlanConfirmationScreen(args: _args),
        ),
        GoRoute(
          path: AppRoutes.homePlansPaymentMethodScreen,
          builder: (_, state) {
            paymentArgs = state.extra! as HomePlansPaymentMethodRouteArgs;
            return const Scaffold(body: Text('existing payment flow'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return tester
        .element(find.byType(TermsNotice))
        .read<HomePlanConfirmationBloc>();
  }

  void expectTotals(WidgetTester tester, String subtotal, String total) {
    final card = tester.widget<CustomPaymentBreakDownCard>(
      find.byType(CustomPaymentBreakDownCard),
    );
    expect(
      card.items.singleWhere((item) => item.label == 'subtotal').value,
      subtotal,
    );
    expect(
      card.items.singleWhere((item) => item.label == 'total').value,
      total,
    );
    expect(
      tester
          .widget<DefaultBottomPayBar>(find.byType(DefaultBottomPayBar))
          .amountText,
      total,
    );
    final breakdown = find.byType(CustomPaymentBreakDownCard);
    expect(
      find.descendant(of: breakdown, matching: find.text(subtotal)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: breakdown, matching: find.text(total)),
      findsOneWidget,
    );
  }

  Future<void> applyPromo(WidgetTester tester) async {
    final field = find.byType(TextField);
    await tester.ensureVisible(field);
    await tester.enterText(field, 'TEST-PROMO');
    await tester.pump();
    await tester.tap(find.text('apply'));
    await tester.pump();
  }

  void completePromo({
    required String type,
    required double quantity,
    bool accepted = true,
  }) {
    pendingPromo.complete(
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/promo-test'),
        statusCode: 200,
        data: {
          'PromoCodeID': accepted ? 57 : 0,
          'DeviceID': 4242,
          'Definition': {
            'PromoCodeDefID': 9,
            'UnitType': type,
            'UnitQty': quantity,
            'PromoCodeName': 'Backend promo name',
            'PromoCodeDesc':
                'Backend description must not replace PLAN-011 copy',
          },
        },
      ),
    );
  }

  Future<void> disposeScreen(WidgetTester tester) async {
    // Allow the existing toast's dismissal timer to finish before disposal.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  for (final sample in [
    (type: 'percentage', quantity: 20.0, subtotal: 80.0, total: 88.0),
    (type: 'dollar', quantity: 5.0, subtotal: 95.0, total: 104.5),
  ]) {
    testWidgets(
      'PLAN-011 ${sample.type}: toast and both totals in first success frame',
      (tester) async {
        final bloc = await pumpScreen(tester);
        final successes = <HomePlanConfirmationState>[];
        final subscription = bloc.stream
            .where(
              (state) =>
                  state.promoStatus == HomePlanConfirmationPromoStatus.applied,
            )
            .listen(successes.add);
        addTearDown(subscription.cancel);
        await applyPromo(tester);
        expect(
          bloc.state.promoStatus,
          HomePlanConfirmationPromoStatus.applying,
        );
        expectTotals(tester, r'$ 100.00', r'$ 110.00');
        expect(find.text('promo code applied'), findsNothing);
        completePromo(type: sample.type, quantity: sample.quantity);

        // One frame after completion must render the toast and both new totals.
        await tester.pump();
        expect(successes, hasLength(1));
        expect(successes.single.promoResponse?.isApplied, isTrue);
        expect(successes.single.displayTotals.subTotal, sample.subtotal);
        expect(successes.single.displayTotals.total, sample.total);
        expectTotals(
          tester,
          '\$ ${sample.subtotal.toStringAsFixed(2)}',
          '\$ ${sample.total.toStringAsFixed(2)}',
        );
        expect(find.text('promo code applied'), findsOneWidget);
        expect(find.text('promo applied'), findsNothing);
        expect(find.text('existing payment flow'), findsNothing);
        verify(
          () => network.request<dynamic>(
            Api.applyPromoCodeUrl(
              deviceAccountId: 4242,
              promoCode: 'TEST-PROMO',
            ),
            method: HttpMethod.get,
          ),
        ).called(1);
        verifyNever(() => devices.loadDeviceLimits());
        expect(tester.takeException(), isNull);
        await disposeScreen(tester);
      },
    );
  }

  for (final apiFailure in [false, true]) {
    testWidgets(
      'invalid promo retains toast and original totals (API failure: $apiFailure)',
      (tester) async {
        final bloc = await pumpScreen(tester);
        await applyPromo(tester);
        if (apiFailure) {
          pendingPromo.completeError(
            NetworkException('rejected', statusCode: 400),
          );
        } else {
          completePromo(type: 'percentage', quantity: 20, accepted: false);
        }
        await tester.pump();
        expect(bloc.state.promoStatus, HomePlanConfirmationPromoStatus.failure);
        expect(bloc.state.hasAppliedPromo, isFalse);
        expect(bloc.state.promoErrorMessage, 'Invalid promo');
        expect(find.text('Invalid promo'), findsOneWidget);
        expect(find.text('promo code applied'), findsNothing);
        expectTotals(tester, r'$ 100.00', r'$ 110.00');
        expect(find.byType(TextField), findsOneWidget);
        await disposeScreen(tester);
      },
    );
  }

  for (final hasPromo in [true, false]) {
    testWidgets(
      'payment flow and arguments remain unchanged (promo: $hasPromo)',
      (tester) async {
        final bloc = await pumpScreen(tester);
        if (hasPromo) {
          await applyPromo(tester);
          completePromo(type: 'percentage', quantity: 20);
          await tester.pump();
        }
        final terms = find.byType(TermsNotice);
        await tester.ensureVisible(terms);
        await tester.tap(
          find
              .descendant(of: terms, matching: find.byType(GestureDetector))
              .first,
        );
        await tester.pump();
        await tester.tap(find.text('continue'));
        await tester.pumpAndSettle();
        expect(find.text('existing payment flow'), findsOneWidget);
        expect(
          GoRouterState.of(
            tester.element(find.text('existing payment flow')),
          ).uri.path,
          AppRoutes.homePlansPaymentMethodScreen,
        );
        expect(bloc.state.payNowRequestId, 1);
        expect(paymentArgs!.subscriberType, HomePlansSubscriberType.prepaid);
        expect(paymentArgs!.phoneNumber, _args.phoneNumber);
        expect(paymentArgs!.amount, hasPromo ? 88 : 110);
        expect(paymentArgs!.forceNow, isTrue);
        expect(paymentArgs!.selectedItems.single.id, '123');
        expect(paymentArgs!.selectedItems.single.price, 100);
        if (hasPromo) {
          final promo = paymentArgs!.promoCodes.single;
          expect(promo.promoCodeId, 57);
          expect(promo.discountAmount, 20);
          expect(promo.planId, 123);
        } else {
          expect(paymentArgs!.promoCodes, isEmpty);
          verifyZeroInteractions(network);
        }
        await disposeScreen(tester);
      },
    );
  }
}
