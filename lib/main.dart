import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:path_provider/path_provider.dart';

import 'main_injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must run before CoreInjection registers AnalyticsService.
  // No-ops gracefully until google-services.json / GoogleService-Info.plist
  // are added to the project (provided by Ethan / Polaris Group).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('⚠️ Firebase not configured yet — analytics disabled: $e');
  }

  // Initialize HydratedBloc storage for account info persistence
  final storageDir = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(storageDir.path),
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: ColorManager.primaryPurple,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  final appRouter = AppRouter();

  await AppMainInjection().initInjection();

  // Load biometric status so the GoRouter redirect can read it synchronously
  await instance<FingerFaceSecurityCubit>().loadBiometricStatus();

  final accountState = instance<AccountInfoCubit>().state;
  final initialUiConfig = !accountState.hasAccount
      ? null
      : HomeUiConfig(
          userType: accountState.isPostpaid
              ? UserType.postpaid
              : UserType.prepaid,
          hasActivePlan: false,
          isFuturePlan: false,
          isCurrentPlan: false,
        );

  runApp(MyApp(appRouter: appRouter, initialUiConfig: initialUiConfig));
}

class MyApp extends StatefulWidget {
  final AppRouter appRouter;
  final HomeUiConfig? initialUiConfig;

  const MyApp({super.key, required this.appRouter, this.initialUiConfig});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _sessionTimeoutService = SessionTimeoutService();
  Timer? _activityHeartbeat;

  // Refresh the "last active" timestamp this often while the app is in
  // foreground. Keeps hot restarts (dev) and in-app periods of use from
  // appearing as "20 min idle" because paused never fired.
  static const _heartbeatInterval = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startHeartbeat();
  }

  @override
  void dispose() {
    _activityHeartbeat?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startHeartbeat() {
    _activityHeartbeat?.cancel();
    _activityHeartbeat = Timer.periodic(_heartbeatInterval, (_) {
      _sessionTimeoutService.markActive();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _activityHeartbeat?.cancel();
      _sessionTimeoutService.markActive();
    } else if (state == AppLifecycleState.resumed) {
      // Only enforce timeout for already-logged-in users. Skip during
      // ongoing login/OTP flows where no session exists yet — otherwise
      // switching to Messages for an SMS code bounces user to Welcome.
      final session = instance<AuthManager>().currentSession;
      if (session == null || session.refreshExpired) {
        _startHeartbeat();
        return;
      }

      _sessionTimeoutService.hasTimedOut().then((timedOut) {
        if (!mounted) return;
        if (timedOut) {
          final biometricEnabled =
              instance<FingerFaceSecurityCubit>().state.isAnyEnabled;
          widget.appRouter.router.go(
            biometricEnabled ? AppRoutes.biometricLock : AppRoutes.welcome,
          );
        }
        _startHeartbeat();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AppUiConfigCubit(initialConfig: widget.initialUiConfig),
        ),
        BlocProvider.value(value: instance<AccountInfoCubit>()),
        BlocProvider.value(value: instance<PlansCubit>()),
        BlocProvider.value(value: instance<LimitedOfferCubit>()),
        BlocProvider.value(value: instance<BestPlanCubit>()),
        BlocProvider.value(value: instance<BalanceCubit>()),
        BlocProvider.value(value: instance<BucketUsageSummaryCubit>()),
        BlocProvider.value(value: instance<SavedCardsCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'My Aliv',
        routerConfig: widget.appRouter.router,
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
        ),
      ),
    );
  }
}
