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

  // Seed AppUiConfigCubit from persisted AccountInfoCubit state so a cold
  // start with a valid JWT session renders the correct prepaid/postpaid
  // shell immediately, instead of flashing the default until a login/OTP/
  // welcome path re-populates it.
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

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  final HomeUiConfig? initialUiConfig;

  const MyApp({super.key, required this.appRouter, this.initialUiConfig});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppUiConfigCubit(initialConfig: initialUiConfig),
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
        routerConfig: appRouter.router,
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
