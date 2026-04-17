import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import '../bloc/edit_email_prepaid_state.dart';

class EditEmailPrepaidRepository {
  final NetworkService _networkService = instance<NetworkService>();

  Future<EditEmailPrepaidData> fetchEditEmailData() async {
    final deviceState = instance<DeviceLimitsCubit>().state;
    final accountState = instance<AccountInfoCubit>().state;
    final accountInfo = accountState.accountInfo;

    final email = accountInfo?.email ?? '';
    final fullName = deviceState.fullName ?? _nameFromEmail(email);

    return EditEmailPrepaidData(
      fullName: fullName,
      phoneNumber: _formatPhone(deviceState.deviceLimits?.tn ?? ''),
      gender: accountInfo?.gender ?? '',
      email: email,
    );
  }

  /// Update email address via API
  /// PUT MyAliv/Account/UpdateEmailAddress?Email={email}
  Future<bool> updateEmail(String email) async {
    try {
      final response = await _networkService.request<dynamic>(
        '/v1/MyAliv/Account/UpdateEmailAddress?Email=${Uri.encodeComponent(email)}',
        method: HttpMethod.put,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['Success'] == true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh account data after email update
  Future<void> refreshAccountData() async {
    await instance<AccountInfoCubit>().fetchAccountInfo(forceRefresh: true);
    await instance<DeviceLimitsCubit>().loadDeviceLimits(forceRefresh: true);
  }

  /// Extract name from email (substring before @)
  String _nameFromEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return 'User';
    return email.split('@').first;
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
}
