import '../../app/Home/home/data/home_ui_config.dart';

class AppSession {
  final UserType userType;
  final bool hasActivePlan;

  AppSession({required this.userType, required this.hasActivePlan});

  bool get isPostpaid => userType == UserType.postpaid;

  static String appRoute = ''; // sendTopUp
  static bool isTopUp = false;

  static void resetAppRoute() {
    AppSession.appRoute = '';
  }
  static void resetFlagForTopUp() {
    AppSession.isTopUp = false;
  }
}
