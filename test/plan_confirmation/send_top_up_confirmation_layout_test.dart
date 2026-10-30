import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_bottom_bar.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/confirmation/widgets/confirmation_plan_card_send_topup_content.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/purchase_confirmation_screen.dart';

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
          primaryPhoneNumber: '2428011616',
          fName: 'Sender',
          lName: 'User',
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

  group('Bug 29: ConfirmationPlanCardSendTopUpContent Layout', () {
    testWidgets(
      'renders top-up title and sender phone without an explicit 4px spacer',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfirmationPlanCardSendTopUpContent(
                topUpAmount: 15.0,
                recipientPhone: '2428999999',
              ),
            ),
          ),
        );

        final titleFinder = find.text('top-up');
        final senderPhoneFinder = find.text('(242)-801-1616');

        expect(titleFinder, findsOneWidget);
        expect(senderPhoneFinder, findsOneWidget);

        final titleRect = tester.getRect(titleFinder);
        final phoneRect = tester.getRect(senderPhoneFinder);

        expect(phoneRect.top, greaterThanOrEqualTo(titleRect.bottom));
        expect(phoneRect.top - titleRect.bottom, lessThan(4.0));
      },
    );

    testWidgets(
      'renders top-up prepaid number label with 12px CircularPro font',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfirmationPlanCardSendTopUpContent(
                topUpAmount: 15.0,
                recipientPhone: '2428999999',
              ),
            ),
          ),
        );

        final labelFinder = find.text('top-up prepaid number');
        expect(labelFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(labelFinder);
        expect(textWidget.style?.fontSize, 12.0);
        expect(textWidget.style?.fontWeight, FontWeight.w700);
        expect(textWidget.style?.fontFamily, 'CircularPro');
      },
    );

    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('renders without overflow at width $width', (tester) async {
        tester.view.physicalSize = Size(width * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ConfirmationPlanCardSendTopUpContent(
                  topUpAmount: 25.0,
                  recipientPhone: '2428999999',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('top-up prepaid number'), findsOneWidget);
        expect(find.text('(242)-899-9999'), findsOneWidget);
        expect(find.text('\$ 25.00'), findsOneWidget);
      });
    }
  });

  group('Bug 29: Send Top-Up Confirmation Bottom Gap Clearance', () {
    testWidgets('passes useBottomSafeArea: true for Send Top-Up confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConfirmationScreen(
            topUpAmount: 15.0,
            recipientPhone: '242-899-9999',
          ),
        ),
      );

      final bar = tester.widget<ConfirmationBottomBar>(
        find.byType(ConfirmationBottomBar),
      );
      expect(bar.useBottomSafeArea, isTrue);
    });

    testWidgets(
      'lifts footer content above 34px bottom inset in ConfirmationScreen',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                padding: EdgeInsets.only(bottom: 34),
                viewPadding: EdgeInsets.only(bottom: 34),
              ),
              child: ConfirmationScreen(
                topUpAmount: 15.0,
                recipientPhone: '242-899-9999',
              ),
            ),
          ),
        );

        final barFinder = find.byType(ConfirmationBottomBar);

        final continueFinder = find.text('continue');
        final continueRect = tester.getRect(continueFinder);
        final barRect = tester.getRect(barFinder);
        expect(
          barRect.bottom - tester.getRect(find.text('no VAT applied')).bottom,
          34 + 16,
        );

        final bottomClearance = barRect.bottom - continueRect.bottom;
        expect(bottomClearance, greaterThanOrEqualTo(34.0 + 16.0));
      },
    );
  });
}
