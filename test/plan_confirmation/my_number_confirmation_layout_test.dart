import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_bottom_bar.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_plan_card_my_number_content.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/purchase_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';

class _MockAccountInfoCubit extends Mock implements AccountInfoCubit {}

class _MockDeviceLimitsCubit extends Mock implements DeviceLimitsCubit {}

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockAccountInfoCubit accountInfoCubit;
  late _MockDeviceLimitsCubit deviceLimitsCubit;
  late _MockNetworkService networkService;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    accountInfoCubit = _MockAccountInfoCubit();
    deviceLimitsCubit = _MockDeviceLimitsCubit();
    networkService = _MockNetworkService();

    when(() => accountInfoCubit.state).thenReturn(
      const AccountInfoState(
        status: AccountInfoStatus.success,
        accountInfo: AccountInfoModel(
          fName: 'Jane',
          lName: 'Smith',
          primaryPhoneNumber: '2428999999',
        ),
      ),
    );
    when(
      () => deviceLimitsCubit.state,
    ).thenReturn(const DeviceLimitsState(status: DeviceLimitsStatus.loaded));

    instance.registerSingleton<NetworkService>(networkService);
    instance.registerSingleton<AccountInfoCubit>(accountInfoCubit);
    instance.registerSingleton<DeviceLimitsCubit>(deviceLimitsCubit);
  });

  tearDown(() async {
    await instance.reset();
  });

  group('ConfirmationPlanCardMyNumberContent Layout', () {
    testWidgets('renders name and phone without an explicit 4px spacer', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmationPlanCardMyNumberContent(topUpAmount: 25.0),
          ),
        ),
      );

      final nameFinder = find.text('Jane Smith');
      final phoneFinder = find.text('(242)-899-9999');

      expect(nameFinder, findsOneWidget);
      expect(phoneFinder, findsOneWidget);

      final nameRect = tester.getRect(nameFinder);
      final phoneRect = tester.getRect(phoneFinder);

      // Verify phone appears directly below name without extra 4px SizedBox.
      expect(phoneRect.top, greaterThanOrEqualTo(nameRect.bottom));
      expect(phoneRect.top - nameRect.bottom, lessThan(4.0));
    });

    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('renders without overflow at width $width with long name', (
        tester,
      ) async {
        when(() => accountInfoCubit.state).thenReturn(
          const AccountInfoState(
            status: AccountInfoStatus.success,
            accountInfo: AccountInfoModel(
              fName: 'Hubert Alexander',
              lName: 'Ingraham-Christie Jr. of the Bahamas',
              primaryPhoneNumber: '2428999999',
            ),
          ),
        );

        tester.view.physicalSize = Size(width * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ConfirmationPlanCardMyNumberContent(topUpAmount: 50.0),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text('Hubert Alexander Ingraham-Christie Jr. of the Bahamas'),
          findsOneWidget,
        );
        expect(find.text('\$ 50.00'), findsOneWidget);
      });
    }
  });

  group('ConfirmationBottomBar Safe Area & Clearance', () {
    testWidgets(
      'expands height and lifts content when useBottomSafeArea is true and bottom inset is 34',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.only(bottom: 34),
                viewPadding: EdgeInsets.only(bottom: 34),
              ),
              child: Scaffold(
                bottomNavigationBar: ConfirmationBottomBar(
                  totalText: '\$ 25.00',
                  vatLabel: 'no VAT applied',
                  enabled: true,
                  onContinue: () {},
                  useBottomSafeArea: true,
                ),
              ),
            ),
          ),
        );

        final barFinder = find.byType(ConfirmationBottomBar);
        final barSize = tester.getSize(barFinder);
        // Base content height ~50 + padding (16*2) = 82; with 34 safe area inset = 116
        expect(barSize.height, 116.0);

        final continueFinder = find.text('continue');
        final continueRect = tester.getRect(continueFinder);
        final barRect = tester.getRect(barFinder);

        // Distance from bottom of continue button to physical screen bottom edge
        final bottomClearance = barRect.bottom - continueRect.bottom;
        expect(bottomClearance, greaterThanOrEqualTo(34.0 + 16.0));
      },
    );

    testWidgets(
      'retains standard 82px height when useBottomSafeArea is true and bottom inset is 0',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
              ),
              child: Scaffold(
                bottomNavigationBar: ConfirmationBottomBar(
                  totalText: '\$ 25.00',
                  vatLabel: 'no VAT applied',
                  enabled: true,
                  onContinue: () {},
                  useBottomSafeArea: true,
                ),
              ),
            ),
          ),
        );

        final barFinder = find.byType(ConfirmationBottomBar);
        final barSize = tester.getSize(barFinder);
        expect(barSize.height, 82.0);
      },
    );

    testWidgets(
      'retains standard 82px height when useBottomSafeArea is false even with 34 inset',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.only(bottom: 34),
                viewPadding: EdgeInsets.only(bottom: 34),
              ),
              child: Scaffold(
                bottomNavigationBar: ConfirmationBottomBar(
                  totalText: '\$ 25.00',
                  vatLabel: 'no VAT applied',
                  enabled: true,
                  onContinue: () {},
                  useBottomSafeArea: false,
                ),
              ),
            ),
          ),
        );

        final barFinder = find.byType(ConfirmationBottomBar);
        final barSize = tester.getSize(barFinder);
        expect(barSize.height, 82.0);
      },
    );
  });

  group('ConfirmationScreen Scope Isolation for Bottom Inset', () {
    testWidgets(
      'passes useBottomSafeArea: true for My Number top-up (recipientPhone == null)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ConfirmationScreen(topUpAmount: 25.0, recipientPhone: null),
          ),
        );

        final bar = tester.widget<ConfirmationBottomBar>(
          find.byType(ConfirmationBottomBar),
        );
        expect(bar.useBottomSafeArea, isTrue);
      },
    );

    testWidgets(
      'passes useBottomSafeArea: true for Send Top-Up (recipientPhone is provided)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ConfirmationScreen(
              topUpAmount: 25.0,
              recipientPhone: '242-801-1616',
            ),
          ),
        );

        final bar = tester.widget<ConfirmationBottomBar>(
          find.byType(ConfirmationBottomBar),
        );
        expect(bar.useBottomSafeArea, isTrue);
      },
    );

    testWidgets(
      'passes useBottomSafeArea: false for Postpaid plan confirmation (topUpAmount is null)',
      (tester) async {
        final postpaidPlan = HomePlansPostPaidPlanModel.fromApiMap({
          'PlanID': 'pp-1',
          'PlanName': 'Liberty 70',
          'PlanAmount': 70,
          'VATAmount': 7,
          'PlanType': 'P',
        });
        final config = AppUiConfigCubit()..setUserType(UserType.postpaid);
        addTearDown(config.close);

        await tester.pumpWidget(
          MaterialApp(
            builder: (_, child) =>
                BlocProvider.value(value: config, child: child!),
            home: ConfirmationScreen(topUpAmount: null, plan: postpaidPlan),
          ),
        );

        final bar = tester.widget<ConfirmationBottomBar>(
          find.byType(ConfirmationBottomBar),
        );
        expect(bar.useBottomSafeArea, isFalse);
      },
    );
  });
}
