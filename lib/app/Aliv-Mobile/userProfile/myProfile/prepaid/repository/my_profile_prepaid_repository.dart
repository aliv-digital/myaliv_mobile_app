import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
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
    final contract = deviceState.subscriberContract;

    return MyProfilePrepaidModel(
      avatarLetter: fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
      fullName: fullName,
      statusLabel: _mapStatus(deviceLimits?.deviceStatus),
      phone: _formatPhone(deviceLimits?.tn ?? ''),
      activeOn: _formatDate(contract?.contractStartDate ?? ''),
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

  /// Format phone number as XXX-XXX-XXXX
  String _formatPhone(String phone) {
    if (phone.isEmpty) return '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return '${digits.substring(1, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    return phone;
  }

  /// Format date string to MM/DD/YYYY
  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
