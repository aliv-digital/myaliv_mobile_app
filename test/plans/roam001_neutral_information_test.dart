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
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/theme/theme.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_purchase_sheet_launcher.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/roam_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Plans/homeRoamingConfirmation/models/home_roaming_confirmation_models.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

const _copy =
    'when to start? — your standalone plan can start immediately, or on a date of your choice.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Plans plans;
  late _Account account;
  late BasePlanModel selectedPlan;
  HomeRoamingConfirmationRouteArgs? confirmation;

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
    plans = _Plans();
    account = _Account();
    confirmation = null;
    selectedPlan = BasePlanModel.fromApiMap({
      'PlanID': '321',
      'PlanName': 'travel plan',
      'PlanType': 'A',
      'PlanAmount': 30,
    });
    when(() => plans.state).thenReturn(const PlansState());
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(
          paymentOption: 'PrePay',
          primaryPhoneNumber: '2428011616',
        ),
      ),
    );
    instance.registerSingleton<AccountInfoCubit>(account);
  });

  tearDown(() async {
    await plans.close();
    await account.close();
    await instance.reset();
  });

  Future<void> openSheet(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showHomePlanPurchaseBottomSheet(
                  context: context,
                  selectedTab: HomePlanTab.roaming,
                  selectedApiPlan: selectedPlan,
                  plan: const HomePlanModel(
                    id: '321',
                    title: 'travel plan',
                    subtitle: '30 days',
                    price: 30,
                    description: '',
                    benefits: [],
                  ),
                ),
                child: const Text('purchase now'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.homeRoamingConfirmation,
          builder: (_, state) {
            confirmation = state.extra! as HomeRoamingConfirmationRouteArgs;
            return const Scaffold(body: Text('existing roaming confirmation'));
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
    await tester.tap(find.text('purchase now'));
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'ROAM-001 exact neutral guidance preserves sheet controls at $width',
      (tester) async {
        await openSheet(tester, width: width);
        expect(find.text(_copy), findsOneWidget);
        expect(find.text('when to start?'), findsOneWidget);
        expect(find.text('start from'), findsOneWidget);
        expect(find.text('activate now'), findsOneWidget);
        final text = tester.widget<Text>(find.text(_copy));
        expect(text.style!.color, HomePlanTheme.subtitleColor);
        expect(text.style!.fontSize, 12);
        expect(text.style!.fontWeight, FontWeight.w400);
        final container = tester.widget<Container>(
          find
              .ancestor(of: find.text(_copy), matching: find.byType(Container))
              .first,
        );
        final decoration = container.decoration! as BoxDecoration;
        expect(
          decoration.color,
          HomePlanTheme.roamBottomSheetDateFieldBackgroundColor,
        );
        expect(
          (decoration.border! as Border).top.color,
          HomePlanTheme.roamBottomSheetOrDividerColor,
        );
        expect(confirmation, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'immediate start retains forceNow, selected plan and confirmation destination',
    (tester) async {
      await openSheet(tester);
      await tester.tap(find.text('activate now'));
      await tester.pumpAndSettle();
      expect(find.text('existing roaming confirmation'), findsOneWidget);
      expect(confirmation!.forceNow, isTrue);
      expect(confirmation!.showDateField, isFalse);
      expect(confirmation!.selectedPlan, same(selectedPlan));
      expect(confirmation!.phoneNumber, '2428011616');
    },
  );

  testWidgets(
    'chosen future date retains scheduling arguments and confirmation destination',
    (tester) async {
      await openSheet(tester);
      final field = find
          .descendant(
            of: find.byType(HomePlanRoamBottomSheet),
            matching: find.byType(InkWell),
          )
          .at(1);
      await tester.tap(field);
      await tester.pumpAndSettle();
      final picker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      final chosen = DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 2)),
      );
      picker.onDateChanged(chosen);
      await tester.pump();
      await tester.tap(find.text(HomePlanTheme.roamCalendarApplyLabel));
      await tester.pumpAndSettle();
      expect(find.text('existing roaming confirmation'), findsOneWidget);
      expect(confirmation!.forceNow, isFalse);
      expect(confirmation!.showDateField, isTrue);
      expect(confirmation!.beginDate, chosen);
      expect(confirmation!.selectedPlan, same(selectedPlan));
    },
  );

  testWidgets(
    'cancel date picker preserves informational sheet and does not navigate',
    (tester) async {
      await openSheet(tester);
      await tester.tap(
        find
            .descendant(
              of: find.byType(HomePlanRoamBottomSheet),
              matching: find.byType(InkWell),
            )
            .at(1),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(HomePlanTheme.roamCalendarCancelLabel));
      await tester.pumpAndSettle();
      expect(find.text(_copy), findsOneWidget);
      expect(find.byType(CalendarDatePicker), findsNothing);
      expect(confirmation, isNull);
    },
  );
}
