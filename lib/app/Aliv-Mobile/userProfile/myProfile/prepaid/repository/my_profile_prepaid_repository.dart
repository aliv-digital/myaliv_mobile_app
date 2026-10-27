import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/core/utils/bahamas_phone_formatter.dart';
import 'package:myaliv_mobile_app/core/utils/user_display_name.dart';
import '../model/my_profile_prepaid_model.dart';

class MyProfilePrepaidRepository {
  Future<MyProfilePrepaidModel> fetchProfile() async {
    final deviceState = instance<DeviceLimitsCubit>().state;
    final accountState = instance<AccountInfoCubit>().state;

    final fullName = resolveUserDisplayName(
      account: accountState,
      devices: deviceState,
    );
    final deviceLimits = deviceState.deviceLimits;

    return MyProfilePrepaidModel(
      avatarLetter: fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
      fullName: fullName,
      statusLabel: _mapStatus(deviceLimits?.deviceStatus),
      phone: BahamasPhoneFormatter.format(deviceLimits?.tn ?? ''),
      email: accountState.accountInfo?.email ?? '',
      deviceTitle: 'your device',
      deviceModel: deviceLimits?.model ?? '',
    );
  }

  /// Map device status code to display label
  String _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'AC':
        return 'active';
      case 'SU':
        return 'suspended';
      case 'IN':
        return 'inactive';
      case 'DC':
        return 'disconnected';
      default:
        return status?.toLowerCase() ?? 'unknown';
    }
  }
}
