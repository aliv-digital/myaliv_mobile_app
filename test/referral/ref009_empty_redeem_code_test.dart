import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/bloc/refer_friend_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/bloc/refer_friend_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/bloc/refer_friend_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/repository/refer_friend_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/widgets/refer_friend_prepaid_redeem_tab.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Repository extends Mock implements ReferFriendPrepaidRepository {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _DeviceState extends Mock implements DeviceLimitsState {}

class _Device extends Mock implements DeviceLimitsModel {}

const _empty = 'enter a referral code';

void main() {
  late _Repository repository;
  late ReferFriendPrepaidBloc bloc;

  setUp(() {
    repository = _Repository();
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
  });

  tearDown(() async {
    await bloc.close();
    await instance.reset();
  });

  void stubRedeem(Future<void> Function() answer) {
    when(
      () => repository.redeemReferral(
        code: any(named: 'code'),
        referredNumber: any(named: 'referredNumber'),
      ),
    ).thenAnswer((_) => answer());
  }

  void verifyNoRedeem() {
    verifyNever(
      () => repository.redeemReferral(
        code: any(named: 'code'),
        referredNumber: any(named: 'referredNumber'),
      ),
    );
  }

  Future<void> pumpTab(WidgetTester tester) async {
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
              child: ReferFriendPrepaidRedeemTab(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder codeField() => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == 'code',
  );

  ElevatedButton redeemButton(WidgetTester tester) => tester.widget(
    find.ancestor(
      of: find.text('redeem'),
      matching: find.byType(ElevatedButton),
    ),
  );

  Future<void> tapRedeem(WidgetTester tester) async {
    await tester.tap(find.text('redeem'));
    await tester.pump();
  }

  testWidgets('no inline error before redeem is tapped', (tester) async {
    await pumpTab(tester);
    expect(find.text(_empty), findsNothing);
    expect(redeemButton(tester).onPressed, isNotNull);
  });

  testWidgets('empty code + redeem shows the exact inline error, no API', (
    tester,
  ) async {
    await pumpTab(tester);
    await tapRedeem(tester);

    expect(find.text(_empty), findsOneWidget);
    expect(bloc.state.redeemCodeFieldError, isTrue);
    expect(bloc.state.errorMessage, isNull);
    expect(bloc.state.redeemStatus, ReferFriendPrepaidSubmitStatus.idle);
    verifyNoRedeem();
  });

  testWidgets('whitespace-only code is treated as empty', (tester) async {
    await pumpTab(tester);
    await tester.enterText(codeField(), '   ');
    await tester.pump();
    await tapRedeem(tester);

    expect(find.text(_empty), findsOneWidget);
    verifyNoRedeem();
  });

  testWidgets('typing a code clears the empty error', (tester) async {
    await pumpTab(tester);
    await tapRedeem(tester);
    expect(find.text(_empty), findsOneWidget);

    await tester.enterText(codeField(), 'R');
    await tester.pump();

    expect(find.text(_empty), findsNothing);
    expect(bloc.state.redeemCodeFieldError, isFalse);
  });

  testWidgets('partial code keeps the existing disabled redeem button', (
    tester,
  ) async {
    await pumpTab(tester);
    await tester.enterText(codeField(), 'ABC');
    await tester.pump();

    expect(redeemButton(tester).onPressed, isNull);
    expect(find.text(_empty), findsNothing);
  });

  testWidgets('full code still reaches the existing redeem flow', (
    tester,
  ) async {
    stubRedeem(() async {});
    await pumpTab(tester);
    await tester.enterText(codeField(), ' REF12345 ');
    await tester.pump();
    await tapRedeem(tester);
    await tester.pumpAndSettle();

    verify(
      () => repository.redeemReferral(
        code: 'REF12345',
        referredNumber: '2425550000',
      ),
    ).called(1);
    expect(find.text(_empty), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('backend invalid-code message is unchanged', (tester) async {
    stubRedeem(
      () async => throw const ReferFriendPrepaidException('invalid code'),
    );
    await pumpTab(tester);
    await tester.enterText(codeField(), 'REF12345');
    await tester.pump();
    await tapRedeem(tester);
    await tester.pumpAndSettle();

    // No screen listener here, so the backend message stays in state.
    expect(bloc.state.errorMessage, 'invalid code');
    expect(bloc.state.redeemCodeFieldError, isFalse);
    expect(find.text(_empty), findsNothing);
  });

  blocTest<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
    'partial code keeps the existing full-code message',
    build: () => bloc = ReferFriendPrepaidBloc(repository: repository),
    seed: () => const ReferFriendPrepaidState(redeemCode: 'ABC'),
    act: (b) => b.add(const ReferFriendPrepaidRedeemPressed()),
    expect: () => [
      const ReferFriendPrepaidState(
        redeemCode: 'ABC',
        errorMessage: 'Please enter the full referral code.',
      ),
    ],
    verify: (_) => verifyNoRedeem(),
  );

  test('state equality and copyWith include the empty-code flag', () {
    bloc = ReferFriendPrepaidBloc(repository: repository);
    const base = ReferFriendPrepaidState();
    final flagged = base.copyWith(redeemCodeFieldError: true);
    expect(flagged.redeemCodeFieldError, isTrue);
    expect(flagged, isNot(base));
    expect(flagged.copyWith(redeemCode: 'X').redeemCodeFieldError, isTrue);
  });
}
