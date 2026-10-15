import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/view/change_password_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/update_limits_request.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/view/upgrade_credit_limit_screen.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_screen.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Auth extends Mock implements AuthManager {}

class _Network extends Mock implements NetworkService {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

class _Devices extends Mock implements DeviceLimitsCubit {}

class _Account extends Mock implements AccountInfoCubit {}

class _Balance extends Mock implements BalanceCubit {}

class _Consumption extends Mock implements ConsumptionLimitCubit {}

TokenSession _token() => TokenSession(
  accessToken: 'synthetic-access',
  refreshToken: 'synthetic-refresh',
  accessExpiresAt: DateTime.utc(2030),
  refreshExpiresAt: DateTime.utc(2031),
);

void main() {
  setUpAll(() {
    registerFallbackValue(_token());
    registerFallbackValue(
      const UpdateLimitsRequest(
        maxAllowedInternational: 0,
        maxAllowedRoaming: 0,
        maxAllowedLocalVoice: 0,
        maxAllowedLocalData: 0,
        maxAllowedLocalText: 0,
      ),
    );
  });
  for (final action in ProtectedAccountAction.values) {
    for (final outcome in [
      'success',
      if (action == ProtectedAccountAction.changePassword) ...[
        'backend failure',
        'network failure',
      ],
      'invalid OTP',
      'save failure',
      'cancel',
      'challenge failure',
    ]) {
      testWidgets(
        '$action $outcome preserves verification before mutation',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(800, 1400));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await http.runWithClient(() async {
            final auth = _Auth();
            final network = _Network();
            final challenge = _Challenge();
            final devices = _Devices();
            final account = _Account();
            final balance = _Balance();
            final consumption = _Consumption();
            final config = AppUiConfigCubit();
            final access = ProtectedAccountAccessVerificationSession(
              accountContext: () => (1, 'subscriber'),
            )..markVerified();
            final expiry = access.expiresAt;
            TokenSession? current = _token();
            int challenges = 0;
            int saves = 0;
            int mutations = 0;
            final order = <String>[];
            final passwordSuccess = Completer<Response<dynamic>>();
            when(() => auth.currentSession).thenAnswer((_) => current);
            when(() => auth.saveSession(any())).thenAnswer((invocation) async {
              saves++;
              if (outcome == 'save failure') {
                throw StateError('synthetic storage failure');
              }
              current = invocation.positionalArguments.first as TokenSession;
              order.add('save');
            });
            when(() => account.state).thenReturn(
              const AccountInfoState(
                accountInfo: AccountInfoModel(idAcc: 1, username: 'subscriber'),
              ),
            );
            when(() => account.stream).thenAnswer((_) => const Stream.empty());
            when(() => devices.state).thenReturn(
              DeviceLimitsState(
                status: DeviceLimitsStatus.loaded,
                allDeviceLimits: [
                  DeviceLimitsModel.fromJson({'DeviceID': 123}),
                ],
              ),
            );
            when(() => devices.stream).thenAnswer((_) => const Stream.empty());
            when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
            when(
              () => devices.updateLimits(
                deviceAccountId: any(named: 'deviceAccountId'),
                request: any(named: 'request'),
              ),
            ).thenAnswer((_) async {
              mutations++;
              order.add('mutation');
              return true;
            });
            when(() => balance.state).thenReturn(BalanceState.initial());
            when(() => balance.stream).thenAnswer((_) => const Stream.empty());
            when(
              () => consumption.loadLimits(
                deviceAccountId: 123,
                forceRefresh: true,
              ),
            ).thenAnswer((_) async {});
            when(() => challenge.requestChallenge()).thenAnswer((_) async {
              challenges++;
              if (outcome == 'challenge failure') {
                throw const CallLogsVerificationException(
                  'synthetic challenge failure',
                );
              }
              return const CallLogsChallenge(
                mfaToken: 'synthetic-mfa',
                apiPhoneNumber: '2425550100',
              );
            });
            when(
              () => network.request<dynamic>(
                Api.verifyOtpUrl,
                method: HttpMethod.post,
                data: any(named: 'data'),
                options: any(named: 'options'),
              ),
            ).thenAnswer((_) async {
              if (outcome == 'invalid OTP') {
                throw StateError('synthetic invalid OTP');
              }
              return Response<dynamic>(
                requestOptions: RequestOptions(path: Api.verifyOtpUrl),
                data: {
                  'access_token': 'synthetic-updated',
                  'refresh_token': 'synthetic-updated-refresh',
                  'expires_in': 3600,
                  'refresh_expires_in': 86400,
                },
              );
            });
            when(
              () => network.request<dynamic>(
                Api.updatePasswordUrl,
                method: HttpMethod.post,
                data: any(named: 'data'),
              ),
            ).thenAnswer((invocation) async {
              expect(
                (invocation.namedArguments[#data] as Map)['NewPassword'],
                'Synthetic123!',
              );
              mutations++;
              order.add('mutation');
              if (outcome == 'network failure') {
                throw StateError('synthetic network failure');
              }
              if (outcome == 'success') {
                return passwordSuccess.future;
              }
              return Response<dynamic>(
                requestOptions: RequestOptions(path: Api.updatePasswordUrl),
                data: {'Success': false},
              );
            });
            instance.registerSingleton<AuthManager>(auth);
            instance.registerSingleton<NetworkService>(network);
            instance.registerSingleton<CallLogsVerificationRepository>(
              challenge,
            );
            instance.registerSingleton<DeviceLimitsCubit>(devices);
            instance.registerSingleton<AccountInfoCubit>(account);
            instance.registerSingleton<ConsumptionLimitCubit>(consumption);
            instance
                .registerSingleton<ProtectedAccountAccessVerificationSession>(
              access,
            );
            final route = action == ProtectedAccountAction.changePassword
                ? AppRoutes.changePasswordPrepaidScreen
                : AppRoutes.upgradeCreditLimit;
            final router = GoRouter(
              navigatorKey: rootNavigatorKey,
              initialLocation: route,
              routes: [
                GoRoute(
                  path: route,
                  builder: (_, _) =>
                      action == ProtectedAccountAction.changePassword
                          ? const ChangePasswordPrepaidScreen()
                          : const UpgradeCreditLimitScreen(),
                ),
                GoRoute(
                  path: AppRoutes.accountActionOtp,
                  builder: (_, state) {
                    final args = state.extra!
                        as ActionOtpRouteArgs<ProtectedAccountAction>;
                    expect(args.attempt.paymentMethod, action);
                    return ActionOtpScreen(args: args);
                  },
                ),
                GoRoute(
                  path: AppRoutes.home,
                  builder: (_, _) =>
                      const Scaffold(body: Text('home destination')),
                ),
              ],
            );
            addTearDown(() async {
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pump(const Duration(seconds: 4));
              router.dispose();
              await config.close();
              access.dispose();
              await instance.reset();
            });
            await tester.pumpWidget(
              MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: config),
                  BlocProvider<BalanceCubit>.value(value: balance),
                ],
                child: MaterialApp.router(routerConfig: router),
              ),
            );
            await tester.pumpAndSettle();
            if (action != ProtectedAccountAction.changePassword) {
              await tester.enterText(find.byType(TextField).first, '10');
              await tester.pumpAndSettle();
              tester.testTextInput.hide();
              FocusManager.instance.primaryFocus?.unfocus();
              await tester.pumpAndSettle();
              final button = find
                  .text(
                    action == ProtectedAccountAction.changePassword
                        ? 'change password'
                        : 'proceed',
                  )
                  .last;
              await tester.ensureVisible(button);
              await tester.tap(button);
              await tester.pumpAndSettle();
            }
            expect(challenges, 1);
            expect(mutations, 0);
            expect(
              find.text('Your password has been changed successfully.'),
              findsNothing,
            );
            if (outcome == 'challenge failure') {
              expect(find.byType(ActionOtpScreen), findsNothing);
            } else {
              expect(find.byType(ActionOtpScreen), findsOneWidget);
              if (outcome == 'cancel') {
                router.pop();
              } else {
                tester
                    .element(find.byType(OtpCodeFields))
                    .read<LoginOtpBloc>()
                    .add(const LoginOtpCodeChanged('123456'));
                await tester.pump();
                tester.testTextInput.hide();
                FocusManager.instance.primaryFocus?.unfocus();
                await tester.pumpAndSettle();
                await tester.tap(find.text('verify'));
                for (var i = 0; i < 4; i++) {
                  await tester.pump(const Duration(milliseconds: 10));
                }
                await tester.pump(const Duration(seconds: 2));
              }
              if (action == ProtectedAccountAction.changePassword &&
                  (outcome == 'success' ||
                      outcome == 'backend failure' ||
                      outcome == 'network failure')) {
                await tester.pumpAndSettle();
                await tester.enterText(
                    find.byType(TextField).first, 'Synthetic123!');
                await tester.enterText(
                    find.byType(TextField).last, 'Synthetic123!');
                tester.testTextInput.hide();
                FocusManager.instance.primaryFocus?.unfocus();
                await tester.pumpAndSettle();
                await tester.tap(find.text('change password').last);
                await tester.pump();
              }
              if (action == ProtectedAccountAction.changePassword &&
                  outcome == 'success') {
                expect(mutations, 1);
                expect(
                  router.routeInformationProvider.value.uri.path,
                  AppRoutes.changePasswordPrepaidScreen,
                );
                expect(
                  find.text('Your password has been changed successfully.'),
                  findsNothing,
                );
                passwordSuccess.complete(
                  Response<dynamic>(
                    requestOptions: RequestOptions(path: Api.updatePasswordUrl),
                    data: {'Success': true},
                  ),
                );
              }
              await tester.pumpAndSettle();
            }
            final mutationAttempted = outcome == 'success' ||
                outcome == 'backend failure' ||
                outcome == 'network failure';
            expect(mutations, mutationAttempted ? 1 : 0);
            expect(
              saves,
              mutationAttempted || outcome == 'save failure' ? 1 : 0,
            );
            expect(access.expiresAt, expiry);
            if (outcome == 'success') {
              expect(order, ['save', 'mutation']);
              expect(find.text('home destination'), findsOneWidget);
              if (action == ProtectedAccountAction.changePassword) {
                expect(
                  find.text('Your password has been changed successfully.'),
                  findsOneWidget,
                );
                expect(
                  find.text('password updated successfully'),
                  findsNothing,
                );
              }
              if (action == ProtectedAccountAction.upgradeCreditLimit) {
                expect(
                  find.text('Your request has been submitted successfully.'),
                  findsOneWidget,
                );
              }
            } else if (action == ProtectedAccountAction.changePassword) {
              expect(
                find.text('Your password has been changed successfully.'),
                findsNothing,
              );
              expect(
                  find.text('home destination'),
                  outcome == 'cancel' || outcome == 'challenge failure'
                      ? findsOneWidget
                      : findsNothing);
              if (outcome == 'backend failure' ||
                  outcome == 'network failure') {
                expect(
                  find.text('failed to update password. please try again.'),
                  findsOneWidget,
                );
              }
            }
            await tester.pump(const Duration(seconds: 4));
            await tester.pumpAndSettle();
          }, () => MockClient((_) async => http.Response('', 200)));
        },
      );
    }
  }
}
