import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class RoleApiClient {
  final NetworkService _networkService;

  RoleApiClient(this._networkService);

  /// Returns the RoleId on success, null on 403 or any error.
  /// null is treated as read-only (fail-safe).
  Future<int?> fetchRoleId(int deviceAccountId) async {
    try {
      final response = await _networkService.request<Map<String, dynamic>>(
        Api.deviceRole(deviceAccountId),
        method: HttpMethod.get,
      );
      return response.data?['RoleId'] as int?;
    } catch (_) {
      return null;
    }
  }
}
