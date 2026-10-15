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
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/bloc/home_roaming_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/models/home_roaming_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/view/home_roaming_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/widgets/home_roaming_confirmation_terms_notice.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

const _message = 'accept the terms & conditions to continue';

void main() {
  late _Network network;
  late _Account account;
  late _Devices devices;
  HomePlansPaymentMethodRouteArgs? payment;

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
    account = _Account();
    devices = _Devices();
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    payment = null;
    when(() => account.state).thenReturn(const AccountInfoState());
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
  });

  tearDown(() async {
    await account.close();
    await devices.close();
    await instance.reset();
  });

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    bool forceNow = true,
    DateTime? beginDate,
  }) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => HomeRoamingConfirmationScreen(
            args: HomeRoamingConfirmationRouteArgs(
              phoneNumber: '2428011616',
              selectedPlan: BasePlanModel.fromApiMap({
                'PlanID': '321',
                'PlanName': 'travel plan',
                'PlanType': 'A',
                'PlanAmount': 30,
              }),
              beginDate: beginDate ?? DateTime.now(),
              showDateField: !forceNow,
              forceNow: forceNow,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.homePlansPaymentMethodScreen,
          builder: (_, state) {
            payment = state.extra! as HomePlansPaymentMethodRouteArgs;
            return const Scaffold(body: Text('existing payment method'));
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
    return router;
  }

  Future<void> toggleTerms(WidgetTester tester) async {
    final notice = tester.widget<HomeRoamingConfirmationTermsNotice>(
      find.byType(HomeRoamingConfirmationTermsNotice),
    );
    notice.onToggleChecked();
    await tester.pumpAndSettle();
  }

  HomeRoamingConfirmationBloc bloc(WidgetTester tester) => tester
      .element(find.byType(HomeRoamingConfirmationTermsNotice))
      .read<HomeRoamingConfirmationBloc>();

  testWidgets('unchecked terms + continue shows TOP-004 inline and blocks', (
    tester,
  ) async {
    final router = await pumpScreen(tester);
    expect(find.text(_message), findsNothing);

    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsOneWidget);
    // Inline inside the scroll body, not a toast/snackbar/dialog.
    expect(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.text(_message),
      ),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(Dialog), findsNothing);
    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(payment, isNull);
    expect(bloc(tester).state.payNowRequestId, 0);
    verifyZeroInteractions(network);
  });

  testWidgets('accepting terms clears TOP-004 and continue is unchanged', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsOneWidget);

    await toggleTerms(tester);
    expect(find.text(_message), findsNothing);
    expect(bloc(tester).state.isTermsChecked, isTrue);

    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expect(find.text('existing payment method'), findsOneWidget);
    expect(payment!.forceNow, isTrue);
    expect(payment!.selectedItems.single.id, '321');
    expect(
      payment!.selectedItems.single.planType,
      HomePlansPaymentPlanType.standalone,
    );
  });

  testWidgets('scheduled roaming keeps its begin date through continue', (
    tester,
  ) async {
    final start = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 3)),
    );
    await pumpScreen(tester, forceNow: false, beginDate: start);
    await toggleTerms(tester);
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsNothing);
    expect(payment!.forceNow, isFalse);
    expect(payment!.selectedBeginDate, start);
  });

  testWidgets('unchecking terms again re-blocks with the same message', (
    tester,
  ) async {
    await pumpScreen(tester);
    await toggleTerms(tester);
    await toggleTerms(tester);
    expect(find.text(_message), findsNothing);
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsOneWidget);
    expect(payment, isNull);
  });
}
