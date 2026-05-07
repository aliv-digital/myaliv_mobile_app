import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

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

  // ON → OFF: confirm via bottom sheet before hitting the disable API.
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => const DisableAutoRenewBottomSheet(),
  );
  if (confirmed != true) return false;

  final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
  if (accountInfo == null || accountInfo.idAcc <= 0) {
    AppToast.show(
      message: 'Account info not available',
      type: ToastType.error,
    );
    return false;
  }

  final success =
      await instance<DeviceLimitsCubit>().disableAutoRenew(accountInfo.idAcc);

  if (success) {
    AppToast.show(
      message:
          "We're working on it! Auto-renew takes a few minutes to update. Thank you for your patience.",
      type: ToastType.success,
    );
  } else {
    AppToast.show(
      message: 'Failed to disable auto-renew',
      type: ToastType.error,
    );
  }

  return success;
}
