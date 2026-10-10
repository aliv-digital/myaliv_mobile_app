import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/bloc/refer_friend_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/repository/refer_friend_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/widgets/refer_friend_prepaid_phone_row.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/widgets/refer_friend_prepaid_refer_tab.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Repository extends Mock implements ReferFriendPrepaidRepository {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _DeviceState extends Mock implements DeviceLimitsState {}

class _Device extends Mock implements DeviceLimitsModel {}

const _invalid = 'enter a valid 10-digit mobile number';

void main() {
  late _Repository repository;
  late ReferFriendPrepaidBloc bloc;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    repository = _Repository();
    // The share flow reads the referrer's account and device first.
    final account = _Account();
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(primaryPhoneNumber: '2425550000'),
      ),
    );
    final device = _Device();
    when(() => device.deviceId).thenReturn(4242);
    final deviceState = _DeviceState();
    when(() => deviceState.deviceLimits).thenReturn(device);
    final devices = _Devices();
    when(() => devices.state).thenReturn(deviceState);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    // Stops the flow right after the eligibility check we want to observe.
    when(
      () => repository.isValidReferral(
        userPhoneNumber: any(named: 'userPhoneNumber'),
      ),
    ).thenAnswer((_) async => false);
  });

  tearDown(() async {
    await bloc.close();
    await instance.reset();
  });

  Future<void> pumpTab(WidgetTester tester) async {
    // Created inside the test zone so its stream reaches the widgets.
    bloc = ReferFriendPrepaidBloc(repository: repository);
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: Scaffold(
          body: BlocProvider<ReferFriendPrepaidBloc>.value(
            value: bloc,
            child: const SingleChildScrollView(
              child: ReferFriendPrepaidReferTab(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder phoneField() => find.descendant(
    of: find.byType(ReferFriendPrepaidPhoneRow),
    matching: find.byType(TextField),
  );

  Finder emailField() => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == 'enter email address',
  );

  Future<void> fill(WidgetTester tester, String phone) async {
    await tester.enterText(phoneField(), phone);
    await tester.enterText(emailField(), 'friend@example.com');
    await tester.pumpAndSettle();
  }

  Future<void> share(WidgetTester tester) async {
    await tester.ensureVisible(find.text('share'));
    await tester.tap(find.text('share'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> settleToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('empty number keeps its existing handling', (tester) async {
    await pumpTab(tester);
    await tester.enterText(emailField(), 'friend@example.com');
    await tester.pumpAndSettle();
    expect(find.text(_invalid), findsNothing);
    expect(find.text('invalid phone number'), findsNothing);
  });

  for (final value in ['24255', '3051234567']) {
    testWidgets('REF-002 "$value" shows the inline error and cannot share', (
      tester,
    ) async {
      await pumpTab(tester);
      await fill(tester, value);
      expect(find.text(_invalid), findsOneWidget);
      expect(find.text('invalid phone number'), findsNothing);
      await share(tester);
      expect(bloc.state.friendPhoneFieldError, isTrue);
      verifyNever(
        () => repository.isValidReferral(
          userPhoneNumber: any(named: 'userPhoneNumber'),
        ),
      );
      await settleToasts(tester);
    });
  }

  for (final (value, normalized) in [
    ('2428011616', '2428011616'),
    ('8011616', '2428011616'),
  ]) {
    testWidgets('valid "$value" clears the error and reaches the API', (
      tester,
    ) async {
      await pumpTab(tester);
      await fill(tester, '24255');
      expect(find.text(_invalid), findsOneWidget);
      // Clear first: replacing formatted text in one step reads as a
      // backspace to the existing Bahamas formatter.
      await tester.enterText(phoneField(), '');
      await tester.enterText(phoneField(), value);
      await tester.pumpAndSettle();
      expect(find.text(_invalid), findsNothing);
      await share(tester);
      verify(
        () => repository.isValidReferral(userPhoneNumber: normalized),
      ).called(1);
      await settleToasts(tester);
    });
  }
}
