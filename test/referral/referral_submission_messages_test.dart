import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/view/refer_friend_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/widgets/refer_friend_prepaid_phone_row.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _DeviceState extends Mock implements DeviceLimitsState {}

class _Device extends Mock implements DeviceLimitsModel {}

const _success = 'Thank you for your referral!';

void main() {
  late _Network network;
  late _Account account;
  late _Devices devices;
  late Completer<Response<dynamic>> referralResult;
  late int successNavigations;

  setUpAll(() async {
    registerFallbackValue(HttpMethod.get);
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    network = _Network();
    account = _Account();
    devices = _Devices();
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(
          primaryPhoneNumber: '2425550000',
          email: ' customer@example.com ',
        ),
      ),
    );
    final device = _Device();
    when(() => device.deviceId).thenReturn(4242);
    final deviceState = _DeviceState();
    when(() => deviceState.deviceLimits).thenReturn(device);
    when(() => devices.state).thenReturn(deviceState);
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    successNavigations = 0;
    when(
      () => network.request<dynamic>(any(), method: HttpMethod.get),
    ).thenAnswer((invocation) async {
      final path = invocation.positionalArguments.first as String;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        data: path.endsWith('/valid') ? {'IsValid': true} : {},
      );
    });
    when(
      () => network.request<dynamic>(
        Api.referAFriend,
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) => referralResult.future);
  });

  tearDown(() async {
    await account.close();
    await devices.close();
    await instance.reset();
  });

  Future<void> openAndShare(
    WidgetTester tester, {
    String email = ' friend@example.com ',
    String phone = '2428011616',
  }) async {
    referralResult = Completer<Response<dynamic>>();
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.referFriendPrepaidScreen,
      routes: [
        GoRoute(
          path: AppRoutes.referFriendPrepaidScreen,
          builder: (_, _) => const ReferFriendPrepaidScreen(),
        ),
        GoRoute(
          path: AppRoutes.invitingSuccess,
          builder: (_, state) {
            successNavigations++;
            return Scaffold(
              body: Text('referral code: ${state.uri.queryParameters['code']}'),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text(_success), findsNothing);
    await tester.enterText(
      find.descendant(
        of: find.byType(ReferFriendPrepaidPhoneRow),
        matching: find.byType(TextField),
      ),
      phone,
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField && w.decoration?.hintText == 'enter email address',
      ),
      email,
    );
    await tester.pumpAndSettle();
    expect(find.text(_success), findsNothing);
    await tester.ensureVisible(find.text('share'));
    await tester.tap(find.text('share'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> settleToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  void verifyNoReferralRequests() {
    verifyNever(
      () => network.request<dynamic>(
        '${Api.isReferralValid}/2428011616/valid',
        method: HttpMethod.get,
      ),
    );
    verifyNever(
      () => network.request<dynamic>(
        Api.referAFriend,
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    );
  }

  for (final email in ['', '   ']) {
    testWidgets('missing email "$email" shows the required inline copy', (
      tester,
    ) async {
      await openAndShare(tester, email: email);
      expect(
        find.text("Please enter your referral's email address."),
        findsOneWidget,
      );
      expect(find.text('invalid email address'), findsNothing);
      expect(successNavigations, 0);
      verifyNoReferralRequests();
    });
  }

  testWidgets('malformed email keeps its existing inline error', (
    tester,
  ) async {
    await openAndShare(tester, email: 'not-an-email');
    expect(find.text('invalid email address'), findsOneWidget);
    expect(
      find.text("Please enter your referral's email address."),
      findsNothing,
    );
    expect(
      find.text('You cannot reffer your own email address.'),
      findsNothing,
    );
    verifyNoReferralRequests();
  });

  for (final email in ['customer@example.com', ' CUSTOMER@EXAMPLE.COM ']) {
    testWidgets('own email "$email" is rejected before referral APIs', (
      tester,
    ) async {
      await openAndShare(tester, email: email);
      expect(
        find.text('You cannot reffer your own email address.'),
        findsOneWidget,
      );
      expect(find.text('invalid email address'), findsNothing);
      expect(find.text(_success), findsNothing);
      expect(successNavigations, 0);
      verifyNoReferralRequests();
      await settleToasts(tester);
    });
  }

  for (final phone in ['', '   ']) {
    testWidgets('missing phone "$phone" shows the required inline copy', (
      tester,
    ) async {
      await openAndShare(tester, phone: phone);
      expect(find.text("Please enter your referral's number."), findsOneWidget);
      expect(find.text('invalid Format'), findsNothing);
      expect(successNavigations, 0);
      verifyNoReferralRequests();
      await tester.enterText(
        find.descendant(
          of: find.byType(ReferFriendPrepaidPhoneRow),
          matching: find.byType(TextField),
        ),
        '2428011616',
      );
      await tester.pumpAndSettle();
      expect(find.text("Please enter your referral's number."), findsNothing);
    });
  }

  testWidgets('both missing fields show separate required errors', (
    tester,
  ) async {
    await openAndShare(tester, phone: '', email: '');
    expect(find.text("Please enter your referral's number."), findsOneWidget);
    expect(
      find.text("Please enter your referral's email address."),
      findsOneWidget,
    );
    verifyNoReferralRequests();
  });

  for (final phone in ['2425550000', '5550000', '(242)-555-0000']) {
    testWidgets('normalized own phone "$phone" blocks referral requests', (
      tester,
    ) async {
      await openAndShare(tester, phone: phone);
      expect(
        find.text('You cannot refer your own phone number.'),
        findsOneWidget,
      );
      expect(find.text('invalid Format'), findsNothing);
      expect(find.text(_success), findsNothing);
      expect(successNavigations, 0);
      verifyNoReferralRequests();
      verifyNever(
        () => network.request<dynamic>(
          '${Api.isReferralValid}/2425550000/valid',
          method: HttpMethod.get,
        ),
      );
      await settleToasts(tester);
    });
  }

  for (final message in [
    'This email is alreader registered to the ALIV network.',
    'This number is already registered to the ALIV network.',
  ]) {
    testWidgets('existing backend message is passed through: $message', (
      tester,
    ) async {
      await openAndShare(tester);
      referralResult.completeError(NetworkException(message));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      expect(find.text(_success), findsNothing);
      expect(successNavigations, 0);
      await settleToasts(tester);
    });
  }

  testWidgets('referral success waits for a code, shows once and navigates', (
    tester,
  ) async {
    await openAndShare(tester);
    expect(find.text(_success), findsNothing);
    expect(successNavigations, 0);
    verify(
      () => network.request<dynamic>(
        Api.referAFriend,
        method: HttpMethod.post,
        data: {
          'ReferringDeviceAccountId': 4242,
          'ReferredEmail': 'friend@example.com',
          'ReferredTN': '2428011616',
        },
      ),
    ).called(1);
    referralResult.complete(
      Response<dynamic>(
        requestOptions: RequestOptions(path: Api.referAFriend),
        data: {'ReferralCode': 'REF123'},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(_success), findsOneWidget);
    expect(find.text('Referral sent!'), findsNothing);
    expect(find.text('referral code: REF123'), findsOneWidget);
    expect(successNavigations, 1);
    await settleToasts(tester);
    expect(successNavigations, 1);
  });

  testWidgets('missing referral code keeps failure and does not navigate', (
    tester,
  ) async {
    await openAndShare(tester);
    referralResult.complete(
      Response<dynamic>(
        requestOptions: RequestOptions(path: Api.referAFriend),
        data: {},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Referral code missing in response.'), findsOneWidget);
    expect(find.text(_success), findsNothing);
    expect(successNavigations, 0);
    await settleToasts(tester);
  });

  testWidgets('referral request failure keeps its error and no success', (
    tester,
  ) async {
    await openAndShare(tester);
    referralResult.completeError(Exception('network unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('network unavailable'), findsOneWidget);
    expect(find.text(_success), findsNothing);
    expect(successNavigations, 0);
    await settleToasts(tester);
  });

  testWidgets('ineligible referral never submits or shows success', (
    tester,
  ) async {
    when(
      () => network.request<dynamic>(
        '${Api.isReferralValid}/2428011616/valid',
        method: HttpMethod.get,
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.isReferralValid),
        data: {'IsValid': false},
      ),
    );
    await openAndShare(tester);
    expect(find.text('You are not valid to refer a friend.'), findsOneWidget);
    expect(find.text(_success), findsNothing);
    expect(successNavigations, 0);
    verifyNever(
      () => network.request<dynamic>(
        Api.referAFriend,
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    );
    await settleToasts(tester);
  });
}
