import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class CreatePasswordRepository {
  final NetworkService _network = instance<NetworkService>();

  /// POST /Auth/update-password
  /// Body: { "CurrentPassword": null, "NewPassword": "<password>" }
  /// Auth handled automatically by NetworkService (session set after OTP verify).
  Future<void> createPassword({required String password}) async {
    try {
      final response = await _network.request<dynamic>(
        Api.updatePasswordUrl,
        method: HttpMethod.post,
        data: {'CurrentPassword': null, 'NewPassword': password},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['Success'] == false) {
        final message = data['Message']?.toString();
        throw Exception(message ?? 'Failed to update password. Please try again.');
      }
    } on DioException catch (e) {
      final body = _asMapOrNull(e.response?.data);
      final message = _extractMessage(body);
      throw Exception(message ?? 'Failed to update password. Please try again.');
    }
  }

  Map<String, dynamic>? _asMapOrNull(dynamic data) {
    try {
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
    return null;
  }

  String? _extractMessage(Map<String, dynamic>? body) {
    if (body == null) return null;
    final raw = body['Message'] ?? body['message'] ?? body['error'];
    return raw?.toString();
  }
}
