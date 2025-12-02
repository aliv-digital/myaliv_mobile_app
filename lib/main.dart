
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';



void main() {
  final appRouter = AppRouter();
  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My Alive',
      routerConfig: appRouter.router,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
// ============= base url ===========   ImagePath
// https://uat.api.events.bealiv.com/1758818404240-pexels-olly-787961.jpg
// access token for demo user : eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NzcyNCwidXNlcm5hbWUiOiI4ODAxNzkyODEyNzMzIiwiaWF0IjoxNzU4ODEyNjgxfQ.oQnwQLDsWSib065jG-dV1yKcp5r95WGLbFKoNw5Ca-o