import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';

/// Runs the post-token sequence shared between the direct-login (no 2FA)
/// path in [LoginBloc] and the OTP-verified path in [LoginOtpBloc].
///
/// Steps:
///   1. Persist the JWT [TokenSession] via [AuthManager] (secure storage
///      + memory). The bearer interceptor picks up the new session
///      lazily on the very next request.
///   2. Fetch `/Account` via [AccountInfoCubit] — needed for
///      paymentOption (drives UI config) and general profile data.
///   3. Fetch `/Account/devices` via [DeviceLimitsCubit] and pin the
///      first device's `DeviceID` into the [LocalStorage] account-id
///      shim. **This is the value all `/device/{id}/...` URLs need.**
///      Note that `id_acc` from `/Account` is the ACCOUNT id — a
///      different number — and the server rejects it with
///      `InvalidDevice` (501).
///   4. Push a [HomeUiConfig] into [AppUiConfigCubit] based on
///      paymentOption.
///
/// Throws if account info fetch fails so callers can surface the error
/// and keep the user on the login/OTP screen instead of half-completing
/// login.
class AuthCompletionService {
  const AuthCompletionService();

  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {
    await instance<AuthManager>().saveSession(session);

    final accountInfoCubit = instance<AccountInfoCubit>();
    await accountInfoCubit.fetchAccountInfo(forceRefresh: true);

    if (accountInfoCubit.state.status != AccountInfoStatus.success) {
      final errorMsg = accountInfoCubit.state.errorMessage ??
          'Failed to fetch account information';
      throw Exception(errorMsg);
    }

    final accountInfo = accountInfoCubit.state.accountInfo;
    if (accountInfo == null) {
      throw Exception('Account information is missing');
    }

    // Load devices so we know the real DeviceID (not the account's id_acc)
    // for URL building. Force-refresh: if the previous user's devices are
    // cached, we don't want to build URLs against them.
    final deviceLimitsCubit = instance<DeviceLimitsCubit>();
    await deviceLimitsCubit.loadDeviceLimits(forceRefresh: true);

    final primaryDevice = deviceLimitsCubit.state.deviceLimits;
    if (primaryDevice == null) {
      throw Exception('No devices found on this account');
    }

    // Shim: legacy call sites (change_password_prepaid_repository etc.)
    // and the URL-building helpers in BasePlanApiClient read this key.
    // Populate it with the primary DEVICE id, not the account id_acc.
    await LocalStorage.storeAccountID(
      accountID: primaryDevice.deviceId.toString(),
    );

    appUiConfigCubit.setConfig(
      HomeUiConfig(
        userType: accountInfoCubit.state.isPostpaid
            ? UserType.postpaid
            : UserType.prepaid,
        hasActivePlan: false,
        isFuturePlan: false,
        openMyLimits: false,
      ),
    );

    if (kDebugMode) {
      debugPrint(
          '✅ AuthCompletionService: login completed for account ${accountInfo.idAcc} '
          '(primary device ${primaryDevice.deviceId})');
    }
  }
}
