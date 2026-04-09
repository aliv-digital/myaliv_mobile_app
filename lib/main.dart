import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:path_provider/path_provider.dart';

import 'main_injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
 */