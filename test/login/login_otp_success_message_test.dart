import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/role_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

class _Account extends Mock implements AccountInfoCubit {}

class _Devices extends Mock implements DeviceLimitsCubit {}

class _Role extends Mock implements RoleApiClient {}

class _Biometrics extends Mock implements FingerFaceSecurityCubit {}

class _Analytics extends Mock implements AnalyticsService {}

void main() {
  setUpAll(() async {
    registerFallbackValue(
      TokenSession(
        accessToken: 'test-access',
        refreshToken: 'test-refresh',
        accessExpiresAt: DateTime.utc(2030),
        refreshExpiresAt: DateTime.utc(2031),
      ),
    );
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  for (final outcome in [
    'success',
    'recovery success',
    'invalid OTP',
    'API failure',
    'session failure',
    'resend',
  ]) {
    testWidgets('OTP $outcome preserves success timing and continuation', (
      tester,
    ) async {
      await http.runWithClient(() async {
        SharedPreferences.setMockInitialValues({});
        await tester.binding.setSurfaceSize(const Size(430, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final network = _Network();
        final auth = _Auth();
        final account = _Account();
        final devices = _Devices();
        final role = _Role();
        final biometrics = _Biometrics();
        final analytics = _Analytics();
        final config = AppUiConfigCubit();
        final response = Completer<Response<dynamic>>();
        final sessionSaved = Completer<void>();
        when(
          () => network.request<dynamic>(
            Api.verifyOtpUrl,
            method: HttpMethod.post,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) => response.future);
        when(
          () => network.request<dynamic>(
            Api.resendOtpUrl,
            method: HttpMethod.post,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            requestOptions: RequestOptions(path: Api.resendOtpUrl),
            data: {'mfa_token': 'replacement-token'},
          ),
        );
        when(
          () => auth.saveSession(any()),
        ).thenAnswer((_) => sessionSaved.future);
        when(
          () => account.fetchAccountInfo(forceRefresh: true),
        ).thenAnswer((_) async {});
        when(() => account.state).thenReturn(
          const AccountInfoState(
            status: AccountInfoStatus.success,
            accountInfo: AccountInfoModel(idAcc: 1, paymentOption: 'PrePay'),
          ),
        );
        when(
          () => devices.loadDeviceLimits(forceRefresh: true),
        ).thenAnswer((_) async {});
        when(() => devices.state).thenReturn(
          DeviceLimitsState(
            status: DeviceLimitsStatus.loaded,
            allDeviceLimits: [
              DeviceLimitsModel.fromJson({'DeviceID': 123}),
            ],
          ),
        );
        when(() => role.fetchRoleId(123)).thenAnswer((_) async => 1);
        when(
          () => analytics.logLogin(
            userId: any(named: 'userId'),
            method: any(named: 'method'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => analytics.logLoginFailure(
            method: any(named: 'method'),
            failureReason: any(named: 'failureReason'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => analytics.logOtpRequested(otpChannel: any(named: 'otpChannel')),
        ).thenAnswer((_) async {});
        when(
          () => analytics.logOtpVerified(otpChannel: any(named: 'otpChannel')),
        ).thenAnswer((_) async {});
        when(
          () => analytics.logOtpFailed(
            otpChannel: any(named: 'otpChannel'),
            failureReason: any(named: 'failureReason'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => analytics.logPasswordResetStarted(),
        ).thenAnswer((_) async {});
        when(
          () => analytics.logPasswordResetCompleted(),
        ).thenAnswer((_) async {});
        when(
          () => analytics.logPasswordResetFailed(
            failureReason: any(named: 'failureReason'),
          ),
        ).thenAnswer((_) async {});
        when(() => analytics.setLoggedIn()).thenAnswer((_) async {});
        instance.registerSingleton<NetworkService>(network);
        instance.registerSingleton<AuthManager>(auth);
        instance.registerSingleton<AccountInfoCubit>(account);
        instance.registerSingleton<DeviceLimitsCubit>(devices);
        instance.registerSingleton<RoleApiClient>(role);
        instance.registerSingleton<FingerFaceSecurityCubit>(biometrics);
        instance.registerSingleton<AnalyticsService>(analytics);
        final recovery = outcome == 'recovery success';
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: AppRoutes.loginOtp,
          routes: [
            GoRoute(
              path: AppRoutes.loginOtp,
              builder: (_, _) => LoginOtpScreen(
                initialMfaToken: 'test-mfa',
                initialPhoneNumber: '2425550100',
                initialApiPhoneNumber: '2425550100',
                successMessage: recovery ? 'Code verified.' : null,
                onSuccess: recovery
                    ? (context) =>
                          context.push(AppRoutes.createPassword, extra: true)
                    : null,
              ),
            ),
            GoRoute(
              path: AppRoutes.home,
              builder: (_, _) => const Scaffold(body: Text('home destination')),
            ),
            GoRoute(
              path: AppRoutes.createPassword,
              builder: (_, state) {
                expect(state.extra, isTrue);
                return const Scaffold(body: Text('reset destination'));
              },
            ),
          ],
        );
        addTearDown(() async {
          await tester.pump(const Duration(seconds: 4));
          await tester.pumpWidget(const SizedBox.shrink());
          router.dispose();
          await config.close();
          await instance.reset();
        });
        await tester.pumpWidget(
          BlocProvider.value(
            value: config,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        try {
          await tester.pumpAndSettle();
          expect(find.text('OTP verified successfully.'), findsNothing);
          if (outcome == 'resend') {
            await tester.tap(find.text('resend code'));
            await tester.pumpAndSettle();
            expect(
              find.text('Verification code resent successfully.'),
              findsOneWidget,
            );
            expect(find.text('OTP verified successfully.'), findsNothing);
            verifyNever(() => auth.saveSession(any()));
            expect(find.byType(LoginOtpScreen), findsOneWidget);
            return;
          }
          await tester.enterText(find.byType(TextField).first, '123456');
          await tester.pumpAndSettle();
          await tester.tap(find.text('verify'));
          await tester.pump();
          expect(find.text('OTP verified successfully.'), findsNothing);
          expect(find.text('home destination'), findsNothing);
          verify(
            () => network.request<dynamic>(
              Api.verifyOtpUrl,
              method: HttpMethod.post,
              data: {
                'PhoneNumber': '2425550100',
                'mfa_token': 'test-mfa',
                'otp_code': '123456',
                'Channel': kAuthChannel,
              },
              options: any(named: 'options'),
            ),
          ).called(1);
          if (outcome == 'invalid OTP' || outcome == 'API failure') {
            response.completeError(
              Exception(
                outcome == 'invalid OTP'
                    ? 'Invalid OTP'
                    : 'network unavailable',
              ),
            );
            await tester.pumpAndSettle();
            expect(find.text('OTP verified successfully.'), findsNothing);
            expect(find.byType(LoginOtpScreen), findsOneWidget);
            verifyNever(() => auth.saveSession(any()));
            verifyNever(() => biometrics.markSessionAuthenticated());
            return;
          }
          response.complete(
            Response<dynamic>(
              requestOptions: RequestOptions(path: Api.verifyOtpUrl),
              data: {
                'access_token': 'test-access',
                'refresh_token': 'test-refresh',
                'expires_in': 3600,
                'refresh_expires_in': 86400,
              },
            ),
          );
          await tester.pump();
          expect(find.text('OTP verified successfully.'), findsNothing);
          expect(find.text('Code verified.'), findsNothing);
          expect(find.text('home destination'), findsNothing);
          verify(() => auth.saveSession(any())).called(1);
          if (outcome == 'session failure') {
            sessionSaved.completeError(Exception('session storage failed'));
            await tester.pumpAndSettle();
            expect(find.text('OTP verified successfully.'), findsNothing);
            expect(find.byType(LoginOtpScreen), findsOneWidget);
            verifyNever(() => biometrics.markSessionAuthenticated());
            return;
          }
          sessionSaved.complete();
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpAndSettle();
          expect(
            find.text(
              recovery ? 'Code verified.' : 'OTP verified successfully.',
            ),
            findsOneWidget,
          );
          expect(
            find.text(recovery ? 'reset destination' : 'home destination'),
            findsOneWidget,
          );
          verify(() => biometrics.markSessionAuthenticated()).called(1);
          verify(
            () => analytics.logLogin(
              userId: any(named: 'userId'),
              method: any(named: 'method'),
            ),
          ).called(1);
          verify(() => analytics.setLoggedIn()).called(1);
          expect(find.text('Logged in successfully'), findsNothing);
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pump(const Duration(seconds: 4));
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }, () => MockClient((_) async => http.Response('', 200)));
    });
  }
}
