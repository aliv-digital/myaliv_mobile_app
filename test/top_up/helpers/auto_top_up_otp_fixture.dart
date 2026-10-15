import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_screen.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Auth extends Mock implements AuthManager {}

class _Network extends Mock implements NetworkService {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

TokenSession autoTopUpTestSession(String label) => TokenSession(
  accessToken: 'synthetic-$label',
  refreshToken: 'synthetic-refresh-$label',
  accessExpiresAt: DateTime(2030),
  refreshExpiresAt: DateTime(2031),
);

Future<void> autoTopUpOnline(Future<void> Function() body) => http
    .runWithClient(body, () => MockClient((_) async => http.Response('', 200)));

/// Real action coordinator/OTP Bloc/route with synthetic transport and storage.
class AutoTopUpOtpFixture {
  AutoTopUpOtpFixture() {
    registerFallbackValue(autoTopUpTestSession('fallback'));
    when(() => auth.currentSession).thenAnswer((_) => current);
    when(() => challenge.requestChallenge()).thenAnswer((_) async {
      challenges++;
      trace.add('challenge');
      if (challengeFailure != null) {
        throw challengeFailure!;
      }
      return challengeGate?.future ??
          Future.value(
            CallLogsChallenge(
              mfaToken: 'synthetic-mfa-$challenges',
              apiPhoneNumber: '2425550100',
            ),
          );
    });
    when(() => auth.saveSession(any())).thenAnswer((invocation) async {
      saves++;
      current = invocation.positionalArguments.first as TokenSession;
      trace.add('save-start');
      if (saveFailure != null) {
        throw saveFailure!;
      }
      await saveGate?.future;
      trace.add('saved');
    });
    when(
      () => network.request<dynamic>(
        Api.verifyOtpUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async {
      verifies++;
      trace.add('verify');
      if (verifyFailure != null) {
        throw verifyFailure!;
      }
      if (verifyGate != null) {
        await verifyGate!.future;
      }
      return Response<dynamic>(
        requestOptions: RequestOptions(path: Api.verifyOtpUrl),
        data: {
          'access_token': 'synthetic-updated',
          'refresh_token': 'synthetic-refresh-updated',
          'expires_in': 3600,
          'refresh_expires_in': 86400,
        },
      );
    });
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<CallLogsVerificationRepository>(challenge);
  }

  final auth = _Auth();
  final network = _Network();
  final challenge = _Challenge();
  final config = AppUiConfigCubit();
  TokenSession? current = autoTopUpTestSession('initial');
  Object? challengeFailure, verifyFailure, saveFailure;
  Completer<CallLogsChallenge>? challengeGate;
  Completer<void>? saveGate, verifyGate;
  int challenges = 0, verifies = 0, saves = 0;
  final trace = <String>[];
  ActionOtpRouteArgs<ProtectedAccountAction>? args;

  GoRoute get otpRoute => GoRoute(
    path: AppRoutes.accountActionOtp,
    builder: (_, state) {
      args = state.extra! as ActionOtpRouteArgs<ProtectedAccountAction>;
      return ActionOtpScreen(args: args!);
    },
  );

  Widget wrap(Widget child) => BlocProvider.value(value: config, child: child);

  Future<void> verify(WidgetTester tester, {int taps = 1}) async {
    final bloc = tester
        .element(find.byType(OtpCodeFields))
        .read<LoginOtpBloc>();
    bloc.add(const LoginOtpCodeChanged('123456'));
    await tester.pump();
    for (var i = 0; i < taps; i++) {
      bloc.add(const LoginOtpSubmitted());
    }
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  Future<void> dispose() => config.close();
}
