import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';

/// Shared handler for the prepaid auto-renew toggle.
///
/// `currentValue` is the toggle state the user is acting against. The function
/// branches the same way Home's `_AutoRenewToggle._handleTap` does:
///   - currentValue == true  (ON  → OFF): hits `disableAutoRenew` directly.
///   - currentValue == false (OFF → ON):  opens [AutoRenewBottomSheet] which
///     funnels into the credit-card / wallet auth flow.
///
/// Returns `true` when the action settled successfully (disabled, or sheet
/// surfaced), `false` when it bailed early (e.g. missing account info).
Future<bool> handleAutoRenewToggle(
  BuildContext context, {
  required bool currentValue,
}) async {
  if (!currentValue) {
    // OFF → ON: defer to the bottom sheet which routes to auth.
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const AutoRenewBottomSheet(),
    );
    return true;
  }

  // ON → OFF: hit the disable API directly.
  final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
  if (accountInfo == null || accountInfo.idAcc <= 0) {
    Fluttertoast.showToast(msg: 'Account info not available');
    return false;
  }

  final success =
      await instance<DeviceLimitsCubit>().disableAutoRenew(accountInfo.idAcc);

  if (success) {
    Fluttertoast.showToast(msg: 'Auto-renew disabled');
  } else {
    Fluttertoast.showToast(msg: 'Failed to disable auto-renew');
  }

  return success;
}
