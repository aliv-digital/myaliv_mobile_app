import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';

import 'support/change_password_flow_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUpAll(() {
    loadChangePasswordTestFonts();
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  testWidgets(
    'Change password success redirects postpaid user to profile postpaid screen',
    (tester) async {
      await withChangePasswordFlow(tester, (h) async {
        h.config.setUserType(UserType.postpaid);
        h.accountState = const AccountInfoState(
          accountInfo: AccountInfoModel(
            idAcc: 1,
            username: 'subscriber',
            paymentOption: 'PostPay',
          ),
        );
        await h.start(tester);
        await h.select(tester);
        await h.verify(tester);

        await h.enterPasswords(tester);
        await h.submit(tester);

        expect(find.text('profile postpaid destination'), findsOneWidget);
        expect(find.text('home destination'), findsNothing);
      });
    },
  );

  testWidgets(
    'Change password success redirects prepaid user to profile prepaid screen',
    (tester) async {
      await withChangePasswordFlow(tester, (h) async {
        h.config.setUserType(UserType.prepaid);
        h.accountState = const AccountInfoState(
          accountInfo: AccountInfoModel(
            idAcc: 1,
            username: 'subscriber',
            paymentOption: 'PrePay',
          ),
        );
        await h.start(tester);
        await h.select(tester);
        await h.verify(tester);

        await h.enterPasswords(tester);
        await h.submit(tester);

        expect(find.text('profile prepaid destination'), findsOneWidget);
        expect(find.text('home destination'), findsNothing);
      });
    },
  );
}
