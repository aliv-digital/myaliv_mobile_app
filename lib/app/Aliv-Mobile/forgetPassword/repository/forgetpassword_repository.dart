import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class ForgetPasswordRepository {
  final NetworkService _network = instance<NetworkService>();

  /// POST /Auth/forgot
  /// Body: { "Username": "<10-digit phone>", "Channel": "SelfCare" }
  /// Returns the mfa_token on success.
  Future<String> sendRequest({required String apiPhone}) async {
    try {
      final response = await _network.request<dynamic>(
        Api.forgotPasswordUrl,
        method: HttpMethod.post,
        data: {'Username': apiPhone, 'Channel': kAuthChannel},
        options: Options(extra: {'skipAuth': true}),
      );

      final body = _asMap(response.data);
      final token = body['mfa_token'];
      if (token == null || token.toString().isEmpty) {
        throw Exception('No MFA token in response.');
      }
      return token.toString();
    } on DioException catch (e) {
      final body = _asMapOrNull(e.response?.data);
      throw Exception(_extractMessage(body) ?? _fallbackFor(e));
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
    throw const FormatException('Unexpected response format.');
  }

  Map<String, dynamic>? _asMapOrNull(dynamic data) {
    try {
      return _asMap(data);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(Map<String, dynamic>? body) {
    if (body == null) return null;
    final raw = body['Message'] ?? body['message'] ?? body['error'] ?? body['detail'];
    return raw?.toString();
  }

  String _fallbackFor(DioException e) {
    return e.message?.trim().isNotEmpty == true
        ? e.message!
        : 'Something went wrong. Please try again.';
  }
}
