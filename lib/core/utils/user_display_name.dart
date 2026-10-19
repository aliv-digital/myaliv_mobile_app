import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';

/// Canonical 3-tier fallback for the logged-in customer's display name:
///   1. `AccountInfoState.fullName` — `fName + lName` from `/MyAliv/Account`.
///   2. `DeviceLimitsState.fullName` — first non-empty `fName`/`lName` on devices.
///   3. Email local-part; literal `'User'` if email is missing/malformed.
///
/// Pass explicit states when the caller already reads them (e.g. inside a
/// `BlocBuilder`) so this stays reactive; omit them to read live singletons
/// from GetIt (fine for one-shot reads in repos/blocs).
String resolveUserDisplayName({
  AccountInfoState? account,
  DeviceLimitsState? devices,
}) {
  final accountState = account ?? instance<AccountInfoCubit>().state;
  final deviceState = devices ?? instance<DeviceLimitsCubit>().state;
  return accountState.fullName ??
      deviceState.fullName ??
      _nameFromEmail(accountState.email);
}

String _nameFromEmail(String? email) {
  final normalized = email?.trim() ?? '';
  if (normalized.isEmpty || !normalized.contains('@')) return 'User';
  return normalized.split('@').first;
}
