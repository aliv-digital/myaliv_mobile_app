import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/widgets/change_password_prepaid_password_field.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Auth extends Mock implements AuthManager {}

class _Network extends Mock implements NetworkService {}

class _Account extends Mock implements AccountInfoCubit {}

class _Devices extends Mock implements DeviceLimitsCubit {}

class _Internet extends Mock implements InternetConnection {}

TokenSession testSession() => TokenSession(
  accessToken: 'synthetic-access',
  refreshToken: 'synthetic-refresh',
  accessExpiresAt: DateTime.utc(2030),
  refreshExpiresAt: DateTime.utc(2031),
);

Future<void> loadChangePasswordTestFonts() async {
  registerFallbackValue(testSession());
  await (FontLoader('CircularPro')
        ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
        ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
      .load();
}

class ChangePasswordFlowHarness {
  final auth = _Auth();
  final network = _Network();
  final account = _Account();
  final devices = _Devices();
  final internet = _Internet();
  final config = AppUiConfigCubit();
  final accountChanges = StreamController<AccountInfoState>.broadcast(
    sync: true,
  );
  final deviceChanges = StreamController<DeviceLimitsState>.broadcast(
    sync: true,
  );
  final access = ProtectedAccountAccessVerificationSession(
    accountContext: () => (1, 'subscriber'),
  )..markVerified();
  TokenSession? current = testSession();
  AccountInfoState accountState = const AccountInfoState(
    accountInfo: AccountInfoModel(idAcc: 1, username: 'subscriber'),
  );
  DeviceLimitsState deviceState = DeviceLimitsState(
    status: DeviceLimitsStatus.loaded,
    allDeviceLimits: [
      DeviceLimitsModel.fromJson({'DeviceID': 123}),
    ],
  );
  GoRouter? _productionRouter;
  late GoRouter router;
  int challenges = 0;
  int verifications = 0;
  int saves = 0;
  int updates = 0;
  bool offline = false;
  bool failSave = false;
  bool updateSuccess = true;
  Object? verificationError;
  Object? challengeError;
  Object? updateError;
  Completer<Response<dynamic>>? pendingChallenge;
  Completer<Response<dynamic>>? pendingVerification;
  Completer<Response<dynamic>>? pendingUpdate;
  final verifyPayloads = <Map<String, dynamic>>[];
  final updatePayloads = <Map<String, dynamic>>[];

  Response<dynamic> response(String path, dynamic data) => Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    data: data,
  );
  Response<dynamic> challengeResponse() =>
      response(Api.challengeOtpUrl, {'mfa_token': 'synthetic-mfa-$challenges'});
  Response<dynamic> verificationResponse() => response(Api.verifyOtpUrl, {
    'access_token': 'synthetic-verified-$verifications',
    'refresh_token': 'synthetic-refreshed-$verifications',
    'expires_in': 3600,
    'refresh_expires_in': 86400,
  });

  Future<void> start(
    WidgetTester tester, {
    String location = AppRoutes.myProfilePrepaidScreen,
    double width = 390,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 1000));
    when(() => auth.currentSession).thenAnswer((_) => current);
    when(() => auth.saveSession(any())).thenAnswer((invocation) async {
      saves++;
      if (failSave) {
        throw StateError('synthetic storage failure');
      }
      current = invocation.positionalArguments.first as TokenSession;
    });
    when(() => account.state).thenAnswer((_) => accountState);
    when(() => account.stream).thenAnswer((_) => accountChanges.stream);
    when(() => devices.state).thenAnswer((_) => deviceState);
    when(() => devices.stream).thenAnswer((_) => deviceChanges.stream);
    when(() => internet.hasInternetAccess).thenAnswer((_) async => !offline);
    when(
      () => network.request<dynamic>(
        Api.challengeOtpUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      challenges++;
      expect(invocation.namedArguments[#data], {
        'access_token': current!.accessToken,
      });
      if (challengeError != null) {
        throw challengeError!;
      }
      return pendingChallenge?.future ?? Future.value(challengeResponse());
    });
    when(
      () => network.request<dynamic>(
        Api.verifyOtpUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((invocation) async {
      verifications++;
      verifyPayloads.add(
        Map<String, dynamic>.from(invocation.namedArguments[#data] as Map),
      );
      if (verificationError != null) {
        throw verificationError!;
      }
      return pendingVerification?.future ??
          Future.value(verificationResponse());
    });
    when(
      () => network.request<dynamic>(
        Api.updatePasswordUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      updates++;
      updatePayloads.add(
        Map<String, dynamic>.from(invocation.namedArguments[#data] as Map),
      );
      if (updateError != null) {
        throw updateError!;
      }
      return pendingUpdate?.future ??
          Future.value(
            response(Api.updatePasswordUrl, {'Success': updateSuccess}),
          );
    });
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<ProtectedAccountAccessVerificationSession>(
      access,
    );
    instance.registerSingleton<CallLogsVerificationRepository>(
      CallLogsVerificationRepository(
        networkService: network,
        authManager: auth,
        internetConnection: internet,
        phoneNumberProvider: () async => '2425550100',
      ),
    );
    // Exercise production route builders; stub only the unrelated Home services.
    _productionRouter = AppRouter().router;
    const paths = {
      AppRoutes.myProfilePrepaidScreen,
      AppRoutes.changePasswordPrepaidScreen,
      AppRoutes.otpProfilePrepaidScreen,
      AppRoutes.accountActionOtp,
    };
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: location,
      routes: [
        ..._productionRouter!.configuration.routes.whereType<GoRoute>().where(
          (r) => paths.contains(r.path),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('home destination')),
        ),
      ],
    );
    await tester.pumpWidget(
      BlocProvider.value(
        value: config,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    if (pendingChallenge == null) {
      await tester.pumpAndSettle();
    }
  }

  Future<void> select(WidgetTester tester) async {
    await tester.ensureVisible(find.text('change password'));
    await tester.tap(find.text('change password'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    if (pendingChallenge == null) {
      await tester.pumpAndSettle();
    }
  }

  LoginOtpBloc otp(WidgetTester tester) =>
      tester.element(find.byType(OtpCodeFields)).read<LoginOtpBloc>();
  ChangePasswordPrepaidBloc formBloc(WidgetTester tester) => tester
      .element(find.byType(ChangePasswordPrepaidPasswordField).first)
      .read<ChangePasswordPrepaidBloc>();

  Future<void> verify(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, '123456');
    tester.testTextInput.hide();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('verify'));
    await tester.tap(find.text('verify'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(seconds: 2));
    if (pendingVerification == null || pendingVerification!.isCompleted) {
      await tester.pumpAndSettle();
    }
  }

  Future<void> enterPasswords(
    WidgetTester tester, {
    String password = 'Synthetic123!',
    String confirm = 'Synthetic123!',
  }) async {
    await tester.enterText(find.byType(TextField).first, password);
    await tester.enterText(find.byType(TextField).last, confirm);
    tester.testTextInput.hide();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.text('change password').last);
    await tester.tap(find.text('change password').last);
    await tester.pump();
    if (pendingUpdate == null || pendingUpdate!.isCompleted) {
      await tester.pumpAndSettle();
    }
  }

  void changeAccount(int id) {
    accountState = AccountInfoState(
      accountInfo: AccountInfoModel(idAcc: id, username: 'subscriber-$id'),
    );
    accountChanges.add(accountState);
  }

  void changeDevice(int id) {
    deviceState = DeviceLimitsState(
      status: DeviceLimitsStatus.loaded,
      allDeviceLimits: [
        DeviceLimitsModel.fromJson({'DeviceID': id}),
      ],
    );
    deviceChanges.add(deviceState);
  }

  void expectLocked() {
    expect(find.byType(ChangePasswordPrepaidPasswordField), findsNothing);
    expect(find.text('new password'), findsNothing);
    expect(updates, 0);
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
    if (_productionRouter != null) {
      router.dispose();
      _productionRouter!.dispose();
    }
    await config.close();
    await accountChanges.close();
    await deviceChanges.close();
    access.dispose();
    await instance.reset();
    await tester.binding.setSurfaceSize(null);
  }
}

Future<void> withChangePasswordFlow(
  WidgetTester tester,
  Future<void> Function(ChangePasswordFlowHarness) body,
) async {
  final h = ChangePasswordFlowHarness();
  await http.runWithClient(() async {
    try {
      await body(h);
    } finally {
      await h.dispose(tester);
    }
  }, () => MockClient((_) async => http.Response('', h.offline ? 503 : 200)));
}
