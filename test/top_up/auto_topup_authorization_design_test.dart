import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/view/auto_top_up_authorization_screen.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';

class _MockDevices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _MockAccount extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

void main() {
  late _MockDevices devices;
  late _MockAccount account;

  setUp(() {
    devices = _MockDevices();
    account = _MockAccount();

    whenListen(
      devices,
      const Stream<DeviceLimitsState>.empty(),
      initialState: DeviceLimitsState.initial(),
    );
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(fName: 'James', lName: 'Brown'),
      ),
    );

    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<AccountInfoCubit>(account);
  });

  tearDown(() async {
    await devices.close();
    await account.close();
    await instance.reset();
  });

  group('Bug 34: Auto Top-up Authorization Form Design Verification', () {
    testWidgets(
      'Consent texts, heading, and subscriber name match Figma specs',
      (tester) async {
        final verifiedResult = ActionVerifiedResult<ProtectedAccountAction>(
          attemptId: Object(),
          paymentMethod: ProtectedAccountAction.autoTopUp,
          canConsume: () => true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: AutoTopUpAuthorizationScreen(
              balanceThreshold: 10,
              autoTopUpAmount: 15,
              cardToken: 'tok-1234',
              cardLastDigits: '1234',
              verifiedResult: verifiedResult,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Heading "electronic communication consent"
        final headingFinder = find.text('electronic communication consent');
        expect(headingFinder, findsOneWidget);
        final headingText = tester.widget<Text>(headingFinder);
        expect(headingText.style?.color, const Color(0xFF707070));
        expect(headingText.style?.fontSize, 16);
        expect(headingText.style?.fontWeight, FontWeight.w700);
        expect(headingText.style?.height, 1.25);

        // 2. Subscriber name "James Brown"
        final nameFinder = find.text('James Brown');
        expect(nameFinder, findsOneWidget);
        final nameText = tester.widget<Text>(nameFinder);
        expect(nameText.style?.color, const Color(0xFF707070));
        expect(nameText.style?.fontSize, 14);
        expect(nameText.style?.fontWeight, FontWeight.w700);
        expect(nameText.style?.height, 1.43);

        // 3. Paragraph 1
        final p1Finder = find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.startsWith('by providing my credit card ending') ??
                  false),
        );
        expect(p1Finder, findsOneWidget);
        final p1Text = tester.widget<Text>(p1Finder);
        expect(p1Text.style?.color, const Color(0xFF707070));
        expect(p1Text.style?.fontSize, 14);
        expect(p1Text.style?.height, 1.43);

        // 4. Paragraph 2
        final p2Finder = find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.startsWith('by entering my pin, full name') ?? false),
        );
        expect(p2Finder, findsOneWidget);
        final p2Text = tester.widget<Text>(p2Finder);
        expect(p2Text.style?.color, const Color(0xFF707070));
        expect(p2Text.style?.fontSize, 14);
        expect(p2Text.style?.height, 1.43);
        expect(p2Text.data, contains('terms I am to which I am agreeing'));
      },
    );
  });
}
