import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
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
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  final appRouter = AppRouter();

  await AppMainInjection().initInjection();

  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppUiConfigCubit()),
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
/*
{"Ticket":"db09c1ce-9969-43d3-a346-a5cb18f1d366m4hufc3hGeOp5SmURGfwMWFf8jyyfMH6jU3BKTcYlnUbxtfe3455xR0m3TT9dokmhhu01ZiiU35wXfwh0o8lBQ==","AccountId":1018469885}
I/flutter ( 8948): Ticket : db09c1ce-9969-43d3-a346-a5cb18f1d366m4hufc3hGeOp5SmURGfwMWFf8jyyfMH6jU3BKTcYlnUbxtfe3455xR0m3TT9dokmhhu01ZiiU35wXfwh0o8lBQ==
I/flutter ( 8948): Account id : 1018469885
I/flutter ( 8948): Account info request initiated for user: 027BA54E-973F-45DD-897B-F635E6C3EEBC


  {"Ticket":"db09c1ce-9969-43d3-a346-a5cb18f1d366namVns9SFsRE493Vvnh9kO5wY/RT7ViqsBIyByqVBbvnBPBiwDyiEKKwH9iPfZOCkY56sJN/lZwiJJkf8bPqaA==","AccountId":924171314}
{"Ticket":"db09c1ce-9969-43d3-a346-a5cb18f1d3666oKfZSAGmk2S+hWnjfd0MIFwBJQP1QX8ATjFfA5OqX0esnu37j1TE2YXZMyXaoEr5nZSef48rsgzAnwo3upY6Q==","AccountId":1259947673}
 
 
 */
