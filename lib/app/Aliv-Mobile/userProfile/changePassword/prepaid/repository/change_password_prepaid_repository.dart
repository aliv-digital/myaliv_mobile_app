import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';

class ChangePasswordPrepaidRepository {
  final NetworkService _networkService = instance<NetworkService>();

  /// Update password via API
  /// POST /v1/MyAliv/Auth/update-password/{deviceAccountId}
  /// Body: { "NewPassword": "newPassword" }
  Future<bool> changePassword({required String newPassword}) async {
    try {
      final deviceAccountId = await LocalStorage.getAccountID();
      if (deviceAccountId == null || deviceAccountId.isEmpty) {
        throw Exception('Device account ID not found');
      }

      final response = await _networkService.request<dynamic>(
        '/v1/MyAliv/Auth/update-password/$deviceAccountId',
        method: HttpMethod.post,
        data: {'NewPassword': newPassword},
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
}
