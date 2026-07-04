import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';

/// Runs the post-ticket sequence shared between the direct-login (no 2FA)
/// path in [LoginBloc] and the OTP-verified path in [LoginOtpBloc].
///
/// Steps:
///   1. Persist ticket + accountID via [AuthManager] (SharedPreferences +
///      GlobalState).
///   2. Refresh Dio's Basic-auth header via [NetworkService].
///   3. Fetch account info via [AccountInfoCubit] (HydratedBloc).
///   4. Push a [HomeUiConfig] into [AppUiConfigCubit] based on paymentOption.
///
/// Throws if account info fetch fails so callers can surface the error and
/// keep the user on the login/OTP screen instead of half-completing login.
class AuthCompletionService {
  const AuthCompletionService();

  Future<void> complete({
    required String ticket,
    required String accountId,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {
    final authManager = instance<AuthManager>();
    await authManager.saveAuth(
      username: userName,
      ticket: ticket,
      deviceAccountID: accountId,
      storeTicket: (t) => LocalStorage.storeTicket(ticket: t),
      storeAccountID: (id) => LocalStorage.storeAccountID(accountID: id),
    );

    final networkService = instance<NetworkService>();
    networkService.updateAuthHeaders();

    final accountInfoCubit = instance<AccountInfoCubit>();
    await accountInfoCubit.fetchAccountInfo();

    if (accountInfoCubit.state.status != AccountInfoStatus.success) {
      final errorMsg = accountInfoCubit.state.errorMessage ??
          'Failed to fetch account information';
      throw Exception(errorMsg);
    }

    final accountInfo = accountInfoCubit.state.accountInfo;
    if (accountInfo == null) {
      throw Exception('Account information is missing');
    }

    appUiConfigCubit.setConfig(
      HomeUiConfig(
        userType: accountInfo.paymentOption == 'PrePay'
            ? UserType.prepaid
            : UserType.postpaid,
        hasActivePlan: false,
        isFuturePlan: false,
        openMyLimits: false,
      ),
    );

    if (kDebugMode) {
      debugPrint('✅ AuthCompletionService: login completed for $accountId');
    }
  }
}
