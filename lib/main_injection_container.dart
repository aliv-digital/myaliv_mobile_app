import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';

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
  /// 2. App-specific dependencies (if any)
  Future<void> initInjection() async {
    // Initialize core with auth loading functions
    await _coreInjection.initInjection(
      getTicket: LocalStorage.getTicket,
      getAccountInfoMap: LocalStorage.getAccountInfoMap,
      parseAccountInfo: (map) => AccountInfoModel.fromJson(map),
      username: userName,
    );

    // TODO: Initialize app-specific dependencies here if needed
  }
}
