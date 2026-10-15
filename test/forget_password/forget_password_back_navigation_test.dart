import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/role_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/view/create_password_page.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/widgets/create_password_header.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/bloc/forget_password_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/model/password_recovery_otp_challenge.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/view/forget_password_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/view/forget_password_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/widgets/forgetpass_phone_row.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/view/login_page.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

class _Account extends Mock implements AccountInfoCubit {}

class _Devices extends Mock implements DeviceLimitsCubit {}

class _Role extends Mock implements RoleApiClient {}

class _Analytics extends Mock implements AnalyticsService {}

class _Plans extends Mock implements PlansCubit {}

class _PlanRepository extends Mock implements PlansRepository {}

class _Balance extends Mock implements BalanceCubit {}

class _Buckets extends Mock implements BucketUsageSummaryCubit {}

class _Offers extends Mock implements LimitedOfferCubit {}

class _BestPlans extends Mock implements BestPlanCubit {}

class _Limits extends Mock implements ConsumptionLimitCubit {}

class _Biometrics extends MockCubit<FingerFaceSecurityState>
    implements FingerFaceSecurityCubit {}

void main() {
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  late _Network network;
  late _Auth auth;
  late _Account account;
  late _Devices devices;
  late _Plans plans;
  late _PlanRepository planRepository;
  late _Balance balance;
  late _Buckets buckets;
  late _Offers offers;
  late _BestPlans bestPlans;
  late _Limits limits;
  late _Biometrics biometrics;
  late AppUiConfigCubit config;
  late GoRouter router;
  TokenSession? session;
  Completer<void>? cleanupGate;
  int cleanupCalls = 0;
  int sends = 0;
  int verifications = 0;
  final updates = <Object?>[];
  final verificationTokens = <String>[];

  setUpAll(() async {
    registerFallbackValue(Options());
    registerFallbackValue(
      TokenSession(
        accessToken: 'test-access',
        refreshToken: 'test-refresh',
        accessExpiresAt: DateTime(2030),
        refreshExpiresAt: DateTime(2031),
      ),
    );
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() async {
    await instance.reset();
    SharedPreferences.setMockInitialValues({
      'accountID': 'old-device',
      'subscriber-cache': 'old-cache',
      'biometric_enabled': true,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (_) async => null);
    network = _Network();
    auth = _Auth();
    account = _Account();
    devices = _Devices();
    plans = _Plans();
    planRepository = _PlanRepository();
    balance = _Balance();
    buckets = _Buckets();
    offers = _Offers();
    bestPlans = _BestPlans();
    limits = _Limits();
    biometrics = _Biometrics();
    final role = _Role();
    final analytics = _Analytics();
    config = AppUiConfigCubit();
    session = null;
    cleanupGate = null;
    cleanupCalls = 0;
    sends = 0;
    verifications = 0;
    updates.clear();
    verificationTokens.clear();
    when(() => auth.currentSession).thenAnswer((_) => session);
    when(() => auth.saveSession(any())).thenAnswer((call) async {
      session = call.positionalArguments.single as TokenSession;
    });
    when(() => auth.clearSession()).thenAnswer((_) async {
      cleanupCalls++;
      session = null;
      await cleanupGate?.future;
    });
    when(() => network.clearCookies()).thenAnswer((_) async {});
    when(
      () => account.fetchAccountInfo(forceRefresh: true),
    ).thenAnswer((_) async {});
    when(() => account.clearAccountInfo()).thenAnswer((_) async {});
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
    when(() => analytics.logLogin()).thenAnswer((_) async {});
    when(() => balance.clearForLogout()).thenAnswer((_) async {});
    when(() => biometrics.state).thenReturn(const FingerFaceSecurityState());
    when(
      () => network.request<dynamic>(
        Api.forgotPasswordUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async {
      sends++;
      return Response<dynamic>(
        requestOptions: RequestOptions(path: Api.forgotPasswordUrl),
        data: {'mfa_token': 'recovery-challenge-$sends'},
      );
    });
    when(
      () => network.request<dynamic>(
        Api.verifyOtpUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((call) async {
      verifications++;
      verificationTokens.add(
        (call.namedArguments[#data] as Map)['mfa_token'] as String,
      );
      return Response<dynamic>(
        requestOptions: RequestOptions(path: Api.verifyOtpUrl),
        data: {
          'access_token': 'test-access',
          'refresh_token': 'test-refresh',
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
    ).thenAnswer((call) async {
      updates.add(call.namedArguments[#data]);
      return Response<dynamic>(
        requestOptions: RequestOptions(path: Api.updatePasswordUrl),
        data: {'Success': true},
      );
    });
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<RoleApiClient>(role);
    instance.registerSingleton<AnalyticsService>(analytics);
    instance.registerSingleton<FingerFaceSecurityCubit>(biometrics);
    instance.registerSingleton<PlansCubit>(plans);
    instance.registerSingleton<PlansRepository>(planRepository);
    instance.registerSingleton<BalanceCubit>(balance);
    instance.registerSingleton<BucketUsageSummaryCubit>(buckets);
    instance.registerSingleton<LimitedOfferCubit>(offers);
    instance.registerSingleton<BestPlanCubit>(bestPlans);
    instance.registerSingleton<ConsumptionLimitCubit>(limits);
  });

  tearDown(() async {
    if (cleanupGate?.isCompleted == false) cleanupGate!.complete();
    router.dispose();
    await config.close();
    await biometrics.close();
    await instance.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  List<String> stack() => router.routerDelegate.currentConfiguration.matches
      .map((match) => (match.route as GoRoute).path)
      .toList();
  Future<void> open(
    WidgetTester tester, {
    String initial = AppRoutes.logIn,
    Object? extra,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1000);
    addTearDown(tester.view.reset);
    final source = AppRouter().router;
    // Keep all four actual recovery builders, including the real Create Password Back handler.
    final production = source.configuration.routes
        .whereType<GoRoute>()
        .where(
          (route) => [
            AppRoutes.logIn,
            AppRoutes.forgetPassword,
            AppRoutes.forgetPasswordOtp,
            AppRoutes.createPassword,
            AppRoutes.loginOtp,
          ].contains(route.path),
        )
        .toList();
    source.dispose();
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initial,
      initialExtra: extra,
      routes: [
        ...production,
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
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    tester.testTextInput.hide();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> send(WidgetTester tester) async {
    await tap(tester, 'send');
    expect(find.byType(ForgetPasswordOtpScreen), findsOneWidget);
    expect(
      find.text('a verification code has been sent to your number and email'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
  }

  Future<ForgetPasswordBloc> recover(WidgetTester tester) async {
    await open(tester);
    await tap(tester, 'forgot password?');
    final phoneBloc = tester
        .element(find.byType(ForgetPasswordPhoneRow))
        .read<ForgetPasswordBloc>();
    await tester.enterText(find.byType(TextField).first, '7654321');
    await tester.pumpAndSettle();
    await send(tester);
    expect(stack(), [
      AppRoutes.logIn,
      AppRoutes.forgetPassword,
      AppRoutes.forgetPasswordOtp,
    ]);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tap(tester, 'verify');
    expect(find.byType(CreatePasswordScreen), findsOneWidget);
    expect(find.text('Code verified.'), findsOneWidget);
    expect(session, isNotNull);
    await tester.pump(const Duration(seconds: 3));
    return phoneBloc;
  }

  Future<void> headerBack(WidgetTester tester) async {
    final arrow = find.descendant(
      of: find.byType(CreatePasswordHeader),
      matching: find.byType(IconButton),
    );
    await tester.ensureVisible(arrow);
    await tester.tap(arrow);
    await tester.pumpAndSettle();
  }

  Future<void> gesture(
    WidgetTester tester,
    String method, [
    Object? arguments,
  ]) async {
    final response = tester.binding.defaultBinaryMessenger
        .handlePlatformMessage(
          SystemChannels.backGesture.name,
          SystemChannels.backGesture.codec.encodeMethodCall(
            MethodCall(method, arguments),
          ),
          (_) {},
        );
    await tester.pump();
    await response;
    await tester.pumpAndSettle();
  }

  Future<void> checkReturned(
    WidgetTester tester,
    ForgetPasswordBloc original,
  ) async {
    expect(stack(), [AppRoutes.logIn, AppRoutes.forgetPassword]);
    expect(find.byType(ForgetPasswordScreen), findsOneWidget);
    expect(
      tester
          .element(find.byType(ForgetPasswordPhoneRow))
          .read<ForgetPasswordBloc>(),
      same(original),
    );
    expect(
      find.byType(ForgetPasswordOtpScreen, skipOffstage: false),
      findsNothing,
    );
    expect(
      find.byType(CreatePasswordScreen, skipOffstage: false),
      findsNothing,
    );
    expect(cleanupCalls, 1);
    expect(session, isNull);
    expect(sends, 1);
    expect(verifications, 1);
    expect(updates, isEmpty);
    verify(() => network.cancelAllRequests('logout')).called(1);
    verify(() => network.clearCookies()).called(1);
    verify(() => account.clearAccountInfo()).called(1);
    verify(() => plans.reset()).called(1);
    verify(() => planRepository.clearCache()).called(1);
    verify(() => devices.reset()).called(1);
    verify(() => balance.clearForLogout()).called(1);
    verify(() => buckets.reset()).called(1);
    verify(() => offers.reset()).called(1);
    verify(() => bestPlans.reset()).called(1);
    verify(() => limits.reset()).called(1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('accountID'), isNull);
    expect(prefs.getString('subscriber-cache'), isNull);
    expect(prefs.getBool('biometric_enabled'), isTrue);
    expect(tester.takeException(), isNull);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  void scenario(String description, WidgetTesterCallback callback) {
    testWidgets(description, (tester) async {
      await http.runWithClient(
        () => callback(tester),
        () => MockClient((_) async => http.Response('', 200)),
      );
    });
  }

  scenario(
    'successful recovery OTP replaces the completed route and header Back returns to original phone entry',
    (tester) async {
      final phoneBloc = await recover(tester);
      expect(stack(), [
        AppRoutes.logIn,
        AppRoutes.forgetPassword,
        AppRoutes.createPassword,
      ]);
      expect(
        find.byType(ForgetPasswordOtpScreen, skipOffstage: false),
        findsNothing,
      );
      final oldBack = tester
          .widget<CreatePasswordScreen>(find.byType(CreatePasswordScreen))
          .onBack!;
      await headerBack(tester);
      await checkReturned(tester, phoneBloc);
      oldBack();
      await tester.pumpAndSettle();
      expect(cleanupCalls, 1);
      expect(stack(), [AppRoutes.logIn, AppRoutes.forgetPassword]);
      await finish(tester);
    },
  );

  scenario(
    'Android system Back returns to original phone entry after a normal rebuild',
    (tester) async {
      final phoneBloc = await recover(tester);
      tester.view.physicalSize = const Size(390, 844);
      router.refresh();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await checkReturned(tester, phoneBloc);
      await finish(tester);
    },
  );

  scenario(
    'Android back gesture cancel preserves the form and commit returns to phone entry',
    (tester) async {
      final phoneBloc = await recover(tester);
      const start = {
        'touchOffset': [0.0, 300.0],
        'progress': 0.0,
        'swipeEdge': 0,
      };
      await gesture(tester, 'startBackGesture', start);
      await gesture(tester, 'cancelBackGesture');
      expect(find.byType(CreatePasswordScreen), findsOneWidget);
      expect(cleanupCalls, 0);
      await gesture(tester, 'startBackGesture', start);
      await gesture(tester, 'commitBackGesture');
      await checkReturned(tester, phoneBloc);
      await finish(tester);
    },
  );

  scenario(
    'rapid header and system Back across rebuilds execute cleanup and navigation once',
    (tester) async {
      final phoneBloc = await recover(tester);
      cleanupGate = Completer<void>();
      for (var i = 0; i < 3; i++) {
        await headerBack(tester);
        await tester.binding.handlePopRoute();
      }
      router.refresh();
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      await headerBack(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(cleanupCalls, 1);
      expect(find.byType(CreatePasswordScreen), findsOneWidget);
      cleanupGate!.complete();
      await tester.pumpAndSettle();
      await checkReturned(tester, phoneBloc);
      await finish(tester);
    },
  );

  scenario(
    'cleanup completion cannot navigate after its recovery route has been removed',
    (tester) async {
      await recover(tester);
      cleanupGate = Completer<void>();
      final oldBack = tester
          .widget<CreatePasswordScreen>(find.byType(CreatePasswordScreen))
          .onBack!;
      await headerBack(tester);
      expect(cleanupCalls, 1);
      router.go(AppRoutes.logIn);
      await tester.pumpAndSettle();
      cleanupGate!.complete();
      await tester.pumpAndSettle();
      oldBack();
      await tester.pumpAndSettle();
      expect(stack(), [AppRoutes.logIn]);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(cleanupCalls, 1);
      expect(sends, 1);
      expect(verifications, 1);
      expect(updates, isEmpty);
      expect(tester.takeException(), isNull);
      await finish(tester);
    },
  );

  for (final initial in [
    AppRoutes.createPassword,
    AppRoutes.logIn,
    AppRoutes.home,
  ]) {
    scenario('missing phone-entry parent falls back safely from $initial', (
      tester,
    ) async {
      await open(
        tester,
        initial: initial,
        extra: initial == AppRoutes.createPassword ? true : null,
      );
      if (initial != AppRoutes.createPassword) {
        router.push(AppRoutes.createPassword, extra: true);
        await tester.pumpAndSettle();
      }
      await headerBack(tester);
      expect(stack(), [AppRoutes.forgetPassword]);
      expect(find.byType(ForgetPasswordScreen), findsOneWidget);
      expect(
        find.byType(CreatePasswordScreen, skipOffstage: false),
        findsNothing,
      );
      expect(cleanupCalls, 1);
      expect(sends, 0);
      expect(verifications, 0);
      expect(updates, isEmpty);
      expect(tester.takeException(), isNull);
      await finish(tester);
    });
  }

  scenario(
    'direct recovery OTP success without a phone parent returns safely to phone entry',
    (tester) async {
      await open(
        tester,
        initial: AppRoutes.forgetPasswordOtp,
        extra: PasswordRecoveryOtpChallenge(
          mfaToken: 'direct-recovery-challenge',
          phoneNumber: '242-765-4321',
          apiPhoneNumber: '2427654321',
        ),
      );
      await tester.enterText(find.byType(TextField).first, '123456');
      await tap(tester, 'verify');
      expect(stack(), [AppRoutes.createPassword]);
      expect(
        find.byType(ForgetPasswordOtpScreen, skipOffstage: false),
        findsNothing,
      );
      await tester.pump(const Duration(seconds: 3));
      await headerBack(tester);
      expect(stack(), [AppRoutes.forgetPassword]);
      expect(find.byType(ForgetPasswordScreen), findsOneWidget);
      expect(cleanupCalls, 1);
      expect(sends, 0);
      expect(verifications, 1);
      expect(updates, isEmpty);
      expect(tester.takeException(), isNull);
      await finish(tester);
    },
  );

  scenario(
    'returning sends no OTP automatically and a fresh Send creates the normal new challenge',
    (tester) async {
      final phoneBloc = await recover(tester);
      await headerBack(tester);
      await checkReturned(tester, phoneBloc);
      await tester.pump(const Duration(seconds: 2));
      expect(sends, 1);
      await send(tester);
      expect(sends, 2);
      expect(verifications, 1);
      expect(updates, isEmpty);
      final screen = tester.widget<ForgetPasswordOtpScreen>(
        find.byType(ForgetPasswordOtpScreen),
      );
      expect(screen.challenge.attempts.mfaToken, 'recovery-challenge-2');
      expect(stack(), [
        AppRoutes.logIn,
        AppRoutes.forgetPassword,
        AppRoutes.forgetPasswordOtp,
      ]);
      await tester.enterText(find.byType(TextField).first, '123456');
      await tap(tester, 'verify');
      expect(verificationTokens, [
        'recovery-challenge-1',
        'recovery-challenge-2',
      ]);
      await tester.pump(const Duration(seconds: 3));
      await headerBack(tester);
      expect(cleanupCalls, 2);
      expect(stack(), [AppRoutes.logIn, AppRoutes.forgetPassword]);
      expect(sends, 2);
      expect(updates, isEmpty);
      await finish(tester);
    },
  );

  scenario(
    'successful Create Password submission keeps its API payload and home navigation',
    (tester) async {
      await recover(tester);
      await tester.enterText(find.byType(TextField).at(0), 'Abc12345');
      await tester.enterText(find.byType(TextField).at(1), 'Abc12345');
      await tap(tester, 'continue');
      expect(updates, [
        {'CurrentPassword': null, 'NewPassword': 'Abc12345'},
      ]);
      expect(find.text('Password reset successful!'), findsOneWidget);
      expect(find.text('home destination'), findsOneWidget);
      expect(cleanupCalls, 0);
      expect(session, isNotNull);
      expect(sends, 1);
      expect(verifications, 1);
      await finish(tester);
    },
  );

  scenario(
    'normal Login OTP success still navigates to home without recovery cleanup',
    (tester) async {
      await open(
        tester,
        initial: AppRoutes.loginOtp,
        extra: const LoginOtpRouteArgs(
          mfaToken: 'login-challenge',
          phoneNumber: '242-765-4321',
          apiPhoneNumber: '2427654321',
        ),
      );
      expect(find.byType(LoginOtpScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '123456');
      await tap(tester, 'verify');
      expect(find.text('OTP verified successfully.'), findsOneWidget);
      expect(find.text('home destination'), findsOneWidget);
      expect(cleanupCalls, 0);
      expect(sends, 0);
      expect(verifications, 1);
      expect(updates, isEmpty);
      await finish(tester);
    },
  );

  for (final system in [false, true]) {
    scenario(
      'non-recovery Create Password keeps ordinary Back, system=$system',
      (tester) async {
        await open(tester);
        router.push(AppRoutes.createPassword);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<CreatePasswordScreen>(find.byType(CreatePasswordScreen))
              .onBack,
          isNull,
        );
        if (system) {
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        } else {
          await headerBack(tester);
        }
        expect(stack(), [AppRoutes.logIn]);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(cleanupCalls, 0);
        expect(sends, 0);
        expect(verifications, 0);
        expect(updates, isEmpty);
        await finish(tester);
      },
    );
  }
}
