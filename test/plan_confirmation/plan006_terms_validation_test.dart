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
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_terms_checkbox.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/purchase_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/view/home_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/widgets/terms_notice.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

const _message = 'accept the terms & conditions to continue';
const _planArgs = HomePlanConfirmationRouteArgs(
  phoneNumber: '242-801-1616',
  accountHolderName: 'Test user',
  primaryPlanId: 'primary-1',
  primaryPlanName: 'liberty70',
  primaryPlanTypeCode: 'P',
  primaryPlanPrice: 70,
  primaryPlanVatAmount: 7,
  flow: HomePlanConfirmationEntryFlow.skip,
  forceNow: false,
  futurePlanStartDate: '2026-11-01T12:00:00',
  marketingOptIn: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Network network;
  late _Devices devices;
  late _Account account;
  late AppUiConfigCubit config;

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
    account = _Account();
    config = AppUiConfigCubit();
    when(
      () => devices.state,
    ).thenReturn(const DeviceLimitsState(status: DeviceLimitsStatus.loaded));
    when(() => account.state).thenReturn(const AccountInfoState());
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<AccountInfoCubit>(account);
  });

  tearDown(() async {
    await config.close();
    await devices.close();
    await account.close();
    await instance.reset();
  });

  Future<GoRouter> pumpConfirmation(
    WidgetTester tester, {
    required bool planPurchase,
    bool postpaid = false,
    bool topUp = true,
    void Function(HomePlansPaymentMethodRouteArgs)? onPayment,
  }) async {
    config.setUserType(postpaid ? UserType.postpaid : UserType.prepaid);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => planPurchase
              ? const HomePlanConfirmationScreen(args: _planArgs)
              : ConfirmationScreen(topUpAmount: topUp ? 25 : null),
        ),
        GoRoute(
          path: AppRoutes.homePlansPaymentMethodScreen,
          builder: (_, state) {
            onPayment?.call(state.extra! as HomePlansPaymentMethodRouteArgs);
            return const Scaffold(body: Text('existing plan payment'));
          },
        ),
        GoRoute(
          path: AppRoutes.topUpPaymentPrepaidScreen,
          builder: (_, _) =>
              const Scaffold(body: Text('existing top-up payment')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppUiConfigCubit>.value(value: config),
          BlocProvider<AccountInfoCubit>.value(value: account),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> toggleTerms(WidgetTester tester, bool planPurchase) async {
    final terms = planPurchase
        ? find.byType(TermsNotice)
        : find.byType(ConfirmationTermsCheckbox);
    await tester.ensureVisible(terms);
    await tester.tap(
      find.descendant(of: terms, matching: find.byType(GestureDetector)).first,
    );
    await tester.pumpAndSettle();
  }

  for (final planPurchase in [true, false]) {
    for (final width in [320.0, 360.0, 430.0]) {
      testWidgets(
        'PLAN-006 inline, blocked, and cleared (plan: $planPurchase, width: $width)',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final router = await pumpConfirmation(
            tester,
            planPurchase: planPurchase,
          );
          expect(find.text(_message), findsNothing);
          final bloc = planPurchase
              ? tester
                    .element(find.byType(TermsNotice))
                    .read<HomePlanConfirmationBloc>()
              : null;
          await tester.tap(find.text('continue'));
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, '/');
          expect(find.text(_message), findsOneWidget);
          expect(find.byType(SnackBar), findsNothing);
          expect(find.byType(Dialog), findsNothing);
          // A toast would be in the root overlay, outside the screen's scrollable.
          expect(
            find.descendant(
              of: find.byType(
                planPurchase ? CustomScrollView : SingleChildScrollView,
              ),
              matching: find.text(_message),
            ),
            findsOneWidget,
          );
          expect(bloc?.state.payNowRequestId ?? 0, 0);
          final error = tester.widget<Text>(find.text(_message));
          expect(error.style?.fontFamily, 'CircularPro');
          expect(error.style?.fontSize, 12);
          expect(
            error.style?.color,
            Theme.of(tester.element(find.text(_message))).colorScheme.error,
          );
          await toggleTerms(tester, planPurchase);
          expect(find.text(_message), findsNothing);
          await toggleTerms(tester, planPurchase);
          expect(find.text(_message), findsNothing);
          await tester.tap(find.text('continue'));
          await tester.pumpAndSettle();
          expect(find.text(_message), findsOneWidget);
          expect(router.routeInformationProvider.value.uri.path, '/');
          verifyZeroInteractions(network);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets(
    'accepted plan terms preserve the existing payment data and action',
    (tester) async {
      HomePlansPaymentMethodRouteArgs? paymentArgs;
      await pumpConfirmation(
        tester,
        planPurchase: true,
        onPayment: (args) => paymentArgs = args,
      );
      final bloc = tester
          .element(find.byType(TermsNotice))
          .read<HomePlanConfirmationBloc>();
      await tester.tap(find.text('continue'));
      await tester.pumpAndSettle();
      await toggleTerms(tester, true);
      expect(find.text(_message), findsNothing);
      await tester.tap(find.text('continue'));
      await tester.pumpAndSettle();
      expect(
        GoRouterState.of(
          tester.element(find.text('existing plan payment')),
        ).uri.path,
        AppRoutes.homePlansPaymentMethodScreen,
      );
      expect(find.text('existing plan payment'), findsOneWidget);
      expect(bloc.state.payNowRequestId, 1);
      expect(paymentArgs!.subscriberType, HomePlansSubscriberType.prepaid);
      expect(paymentArgs!.amount, 77);
      expect(paymentArgs!.phoneNumber, _planArgs.phoneNumber);
      expect(paymentArgs!.forceNow, isFalse);
      expect(
        paymentArgs!.selectedBeginDate,
        DateTime.parse(_planArgs.futurePlanStartDate),
      );
      expect(paymentArgs!.marketingOptIn, isTrue);
      expect(paymentArgs!.selectedItems.single.id, _planArgs.primaryPlanId);
      expect(paymentArgs!.selectedItems.single.price, 70);
      verifyZeroInteractions(network);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final postpaid in [false, true]) {
    testWidgets(
      'accepted top-up terms preserve navigation (postpaid: $postpaid)',
      (tester) async {
        await pumpConfirmation(tester, planPurchase: false, postpaid: postpaid);
        await toggleTerms(tester, false);
        expect(find.text(_message), findsNothing);
        await tester.tap(find.text('continue'));
        await tester.pumpAndSettle();
        final uri = GoRouterState.of(
          tester.element(find.text('existing top-up payment')),
        ).uri;
        expect(uri.path, AppRoutes.topUpPaymentPrepaidScreen);
        expect(uri.queryParameters['amount'], '25.00');
        expect(uri.queryParameters['recipientPhone'], 'null');
        verifyZeroInteractions(network);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('postpaid unchecked terms retain the disabled button', (
    tester,
  ) async {
    final router = await pumpConfirmation(
      tester,
      planPurchase: false,
      postpaid: true,
    );
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(find.text(_message), findsNothing);
    verifyZeroInteractions(network);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('postpaid missing-plan validation retains its existing toast', (
    tester,
  ) async {
    await pumpConfirmation(
      tester,
      planPurchase: false,
      postpaid: true,
      topUp: false,
    );
    await toggleTerms(tester, false);
    await tester.tap(find.text('continue'));
    await tester.pump();
    expect(find.text('No postpaid plan selected.'), findsOneWidget);
    expect(find.text(_message), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    verifyZeroInteractions(network);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('terms validation preserves existing promo form and state', (
    tester,
  ) async {
    await pumpConfirmation(tester, planPurchase: true);
    final bloc = tester
        .element(find.byType(TermsNotice))
        .read<HomePlanConfirmationBloc>();
    bloc.add(const HomePlanConfirmationPromoCodeChanged('KEEP-CODE'));
    await tester.pumpAndSettle();
    final before = bloc.state;
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsOneWidget);
    expect(bloc.state, before);
    final promo = find.byType(TextField);
    expect(tester.widget<TextField>(promo).controller!.text, 'KEEP-CODE');
    await toggleTerms(tester, true);
    expect(bloc.state.promoCode, before.promoCode);
    expect(bloc.state.promoStatus, HomePlanConfirmationPromoStatus.idle);
    verifyZeroInteractions(network);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
