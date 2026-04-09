import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/account_info_injection.dart';

/// Main app dependency injection
///
/// Orchestrates initialization of both core and app-specific dependencies.
class AppMainInjection {
  late CoreInjection _coreInjection;

  AppMainInjection() {
    _coreInjection = CoreInjection();
  }

  /// Initialize all dependencies
  ///
  /// Call order:
  /// 1. Core dependencies (with auth loading)
  /// 2. App-specific dependencies (account info, etc.)
  Future<void> initInjection() async {
    // Initialize core with auth loading functions
    await _coreInjection.initInjection(
      getTicket: LocalStorage.getTicket,
      getAccountInfoMap: LocalStorage.getAccountInfoMap,
      parseAccountInfo: (map) => AccountInfoModel.fromJson(map),
      username: userName,
    );

    // Initialize account information feature
    await setupAccountInfoInjection();
  }
}
