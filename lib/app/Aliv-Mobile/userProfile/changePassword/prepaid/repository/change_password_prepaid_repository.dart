import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class ChangePasswordPrepaidRepository {
  final NetworkService _networkService = instance<NetworkService>();

  /// POST /Auth/update-password
  /// Body: { "NewPassword": "<new>" }
  Future<bool> changePassword({required String newPassword}) async {
    try {
      final response = await _networkService.request<dynamic>(
        Api.updatePasswordUrl,
        method: HttpMethod.post,
        data: {'NewPassword': newPassword},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['Success'] == false) {
          final message = data['Message']?.toString();
          throw Exception(message ?? 'Failed to update password.');
        }
        return data['Success'] == true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
