import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/widgets/auth_name_input.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/enterPassword/prepaid/widgets/enter_password_prepaid_password_input.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/otp/prepaid/bloc/otp_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/otp/prepaid/bloc/otp_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/otp/prepaid/bloc/otp_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/otp/prepaid/widgets/otp_prepaid_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/widgets/mp_custom_amount_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/revBillPay/revBill/prepaid/view/rev_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/widgets/refer_friend_prepaid_labeled_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/Otp/prepaid/bloc/forgetPass_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/Otp/prepaid/bloc/forgetPass_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/Otp/prepaid/bloc/forgetPass_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/Otp/prepaid/widgets/forgetOtp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/enterPassword/prepaid/widgets/enter_password_prepaid_password_input.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/gift_data_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/view/gift_data_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/widgets/currency_amount_input.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_amount_box.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/view/upgrade_credit_limit_screen.dart';
import 'package:myaliv_mobile_app/app/Security/secuirity_common_verification_code_page.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';

class _LoginOtp extends MockBloc<LoginOtpEvent, LoginOtpState>
    implements LoginOtpBloc {}

class _ProfileOtp
    extends MockBloc<OtpProfilePrepaidEvent, OtpProfilePrepaidState>
    implements OtpProfilePrepaidBloc {}

class _RenewOtp
    extends MockBloc<OtpAutoRenewPrepaidEvent, OtpAutoRenewPrepaidState>
    implements OtpAutoRenewPrepaidBloc {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _GiftRepository extends Mock implements GiftDataRepository {}

class _Auth extends Mock implements AuthManager {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

void main() {
  setUpAll(() async {
    registerFallbackValue(const LoginOtpCodeChanged(''));
    registerFallbackValue(const OtpProfilePrepaidCodeChanged(''));
    registerFallbackValue(const OtpAutoRenewPrepaidCodeChanged(''));
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  tearDown(() async => instance.reset());

  Future<void> open(
    WidgetTester tester,
    Widget child,
    TargetPlatform platform,
    Size size, {
    bool isPage = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        home: isPage
            ? child
            : Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> showKeyboard(WidgetTester tester, Finder input) async {
    await tester.ensureVisible(input);
    await tester.showKeyboard(input);
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pumpAndSettle();
  }

  Future<void> traverse(WidgetTester tester, int count, Size size) async {
    final inputs = find.byType(TextField);
    expect(inputs, findsNWidgets(count));
    await showKeyboard(tester, inputs.first);
    for (var i = 0; i < count; i++) {
      final field = tester.widget<TextField>(inputs.at(i));
      expect(field.focusNode!.hasFocus, isTrue);
      final label = i == count - 1 ? 'Done' : 'Next';
      final button = find.widgetWithText(TextButton, label);
      expect(button, findsOneWidget);
      expect(find.text(label == 'Next' ? 'Done' : 'Next'), findsNothing);
      expect(
        tester.getRect(button).bottom,
        lessThanOrEqualTo(size.height - 250),
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
    }
    expect(find.text('Done'), findsNothing);
    for (final field in tester.widgetList<TextField>(inputs)) {
      expect(field.focusNode!.hasFocus, isFalse);
    }
    expect(tester.takeException(), isNull);
  }

  final singleFields = <String, Widget Function(VoidCallback action)>{
    'redeem referral code': (_) => ReferFriendPrepaidLabeledField(
      label: 'referral code',
      hint: 'code',
      keyboardType: TextInputType.text,
      value: '',
      onChanged: (_) {},
    ),
    'postpaid custom amount': (_) =>
        MpCustomAmountField(value: '', onChanged: (_) {}),
    'own-number top-up amount': (_) =>
        TopUpPrepaidAmountBox(value: '', onChanged: (_) {}),
    'standalone auto top-up amount': (_) =>
        const TopUpFormInputField(hint: 'amount', isAmountType: true),
    'auto-renew signature': (_) =>
        AuthNameInput(value: '', hintText: 'name', onChanged: (_) {}),
    'profile password': (action) => EnterPasswordPrepaidPasswordInput(
      value: '',
      obscure: true,
      onChanged: (_) {},
      onToggle: action,
    ),
    'auto-renew password': (action) =>
        EnterPasswordAutoRenewPrepaidPasswordInput(
          value: '',
          obscure: true,
          onChanged: (_) {},
          onToggle: action,
        ),
    'shared confirmation promo': (action) => CustomPaymentBreakDownCard(
      items: const [],
      input: CustomPaymentBreakdownInputConfig(
        value: '',
        onActionTap: action,
        onChanged: (_) {},
      ),
    ),
  };

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final size in [const Size(320, 700), const Size(443, 958)]) {
      for (final entry in singleFields.entries) {
        testWidgets(
          '${entry.key}: Done dismisses without action on $platform $size',
          (tester) async {
            var actions = 0;
            await open(tester, entry.value(() => actions++), platform, size);
            final input = find.byType(TextField);
            expect(find.text('Done'), findsNothing);
            await showKeyboard(tester, input);
            await tester.enterText(input, '25');
            await tester.pumpAndSettle();
            final before = tester
                .widget<EditableText>(find.byType(EditableText))
                .controller
                .text;
            expect(find.widgetWithText(TextButton, 'Done'), findsOneWidget);
            await tester.tap(find.widgetWithText(TextButton, 'Done'));
            await tester.pumpAndSettle();
            expect(
              tester
                  .widget<EditableText>(find.byType(EditableText))
                  .focusNode
                  .hasFocus,
              isFalse,
            );
            expect(
              tester
                  .widget<EditableText>(find.byType(EditableText))
                  .controller
                  .text,
              before,
            );
            expect(find.text('Done'), findsNothing);
            expect(actions, 0);
            expect(tester.takeException(), isNull);
          },
        );
      }

      testWidgets('REV: Next traverses all fields on $platform $size', (
        tester,
      ) async {
        await open(
          tester,
          const RevPrepaidScreen(),
          platform,
          size,
          isPage: true,
        );
        await traverse(tester, 3, size);
      });

      testWidgets(
        'credit limits: Next traverses five fields on $platform $size',
        (tester) async {
          final devices = _Devices();
          final auth = _Auth();
          final challenge = _Challenge();
          instance.registerSingleton<AuthManager>(auth);
          instance.registerSingleton<CallLogsVerificationRepository>(challenge);
          final balance = _Balance();
          whenListen(
            devices,
            const Stream<DeviceLimitsState>.empty(),
            initialState: DeviceLimitsState.initial(),
          );
          when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
          whenListen(
            balance,
            const Stream<BalanceState>.empty(),
            initialState: BalanceState.initial(),
          );
          instance.registerSingleton<DeviceLimitsCubit>(devices);
          addTearDown(devices.close);
          addTearDown(balance.close);
          await open(
            tester,
            BlocProvider<BalanceCubit>.value(
              value: balance,
              child: const UpgradeCreditLimitScreen(),
            ),
            platform,
            size,
            isPage: true,
          );
          await traverse(tester, 5, size);
          verify(() => devices.loadDeviceLimits()).called(1);
          verifyZeroInteractions(auth);
          verifyZeroInteractions(challenge);
        },
      );

      testWidgets(
        'Gift Data: validation keeps Next/Done working on $platform $size',
        (tester) async {
          final account = _Account();
          final repo = _GiftRepository();
          when(() => account.state).thenReturn(
            const AccountInfoState(
              accountInfo: AccountInfoModel(primaryPhoneNumber: '2425550100'),
            ),
          );
          instance.registerSingleton<AccountInfoCubit>(account);
          instance.registerSingleton<GiftDataRepository>(repo);
          addTearDown(account.close);
          await open(
            tester,
            const GiftDataScreen(),
            platform,
            size,
            isPage: true,
          );
          await traverse(tester, 2, size);

          final inputs = find.byType(TextField);
          await tester.showKeyboard(inputs.first);
          await tester.enterText(inputs.first, '899');
          await tester.pumpAndSettle();
          expect(
            find.text(GiftDataTheme.invalidFormatErrorMessage),
            findsOneWidget,
          );
          await tester.tap(find.widgetWithText(TextButton, 'Next'));
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(inputs.last).focusNode!.hasFocus,
            isTrue,
          );

          await tester.enterText(inputs.last, '2425550101');
          await tester.pumpAndSettle();
          expect(
            find.text(GiftDataTheme.phoneMismatchErrorMessage),
            findsOneWidget,
          );
          final recipient = tester
              .widget<TextField>(inputs.first)
              .controller!
              .text;
          final confirmation = tester
              .widget<TextField>(inputs.last)
              .controller!
              .text;
          await tester.tap(find.widgetWithText(TextButton, 'Done'));
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(inputs.last).focusNode!.hasFocus,
            isFalse,
          );
          expect(
            tester.widget<TextField>(inputs.first).controller!.text,
            recipient,
          );
          expect(
            tester.widget<TextField>(inputs.last).controller!.text,
            confirmation,
          );

          // Native keyboard actions use the same nodes as the toolbar.
          await tester.showKeyboard(inputs.first);
          await tester.testTextInput.receiveAction(TextInputAction.next);
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(inputs.last).focusNode!.hasFocus,
            isTrue,
          );
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(inputs.last).focusNode!.hasFocus,
            isFalse,
          );
          expect(find.text('Done'), findsNothing);
          verifyZeroInteractions(repo);
        },
      );
    }
  }

  for (final kind in ['shared', 'profile', 'auto-renew', 'common security']) {
    testWidgets(
      '$kind OTP toolbar navigates without verifying or clearing digits',
      (tester) async {
        late Widget widget;
        final login = _LoginOtp();
        final profile = _ProfileOtp();
        final renew = _RenewOtp();
        whenListen(
          login,
          const Stream<LoginOtpState>.empty(),
          initialState: const LoginOtpState(),
        );
        whenListen(
          profile,
          const Stream<OtpProfilePrepaidState>.empty(),
          initialState: const OtpProfilePrepaidState(),
        );
        whenListen(
          renew,
          const Stream<OtpAutoRenewPrepaidState>.empty(),
          initialState: const OtpAutoRenewPrepaidState(),
        );
        addTearDown(login.close);
        addTearDown(profile.close);
        addTearDown(renew.close);
        widget = switch (kind) {
          'shared' => BlocProvider<LoginOtpBloc>.value(
            value: login,
            child: const OtpCodeFields(),
          ),
          'profile' => BlocProvider<OtpProfilePrepaidBloc>.value(
            value: profile,
            child: const OtpProfilePrepaidCodeFields(),
          ),
          'auto-renew' => BlocProvider<OtpAutoRenewPrepaidBloc>.value(
            value: renew,
            child: const OtpAutoRenewPrepaidCodeFields(),
          ),
          _ => const VerificationCodePage(nextRoute: 'home'),
        };
        await open(
          tester,
          widget,
          TargetPlatform.iOS,
          const Size(443, 958),
          isPage: kind == 'common security',
        );
        final count = kind == 'shared' ? 6 : 5;
        await traverse(tester, count, const Size(443, 958));
        verifyNever(() => login.add(any()));
        verifyNever(() => profile.add(any()));
        verifyNever(() => renew.add(any()));
        // Reopening and editing still preserves OTP auto-advance.
        await tester.showKeyboard(find.byType(TextField).first);
        await tester.enterText(find.byType(TextField).first, '1');
        await tester.pumpAndSettle();
        if (kind != 'common security') {
          expect(
            tester
                .widget<TextField>(find.byType(TextField).at(1))
                .focusNode!
                .hasFocus,
            isTrue,
          );
        }
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText).first)
              .controller
              .text,
          '1',
        );
        // Closing the OS keyboard hides the toolbar even while focus remains.
        tester.view.viewInsets = FakeViewPadding.zero;
        await tester.pumpAndSettle();
        expect(find.text('Next'), findsNothing);
        expect(find.text('Done'), findsNothing);
      },
    );
  }
}
