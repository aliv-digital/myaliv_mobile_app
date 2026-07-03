import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Calls the AltNumber validation endpoint.
///
/// `GET v1/MyAliv/AltNumber/validate/{altNumber}` → `{ "IsValid": true|false }`.
class AltNumberValidationApiClient {
  AltNumberValidationApiClient({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Returns the raw `IsValid` boolean from the server.
  ///
  /// Throws on transport / non-2xx errors so the repository can translate.
  Future<bool> validate(String altNumber) async {
    if (kDebugMode) {
      debugPrint('AltNumberValidationApiClient: validating $altNumber');
    }

    final response = await _networkService.request<dynamic>(
      Api.altNumberValidate(altNumber),
      method: HttpMethod.get,
    );

    final responseMap = _decodeMap(response.data);
    final raw = responseMap['IsValid'] ?? responseMap['isValid'];

    if (raw is bool) return raw;
    if (raw is String) return raw.toLowerCase() == 'true';

    throw Exception('IsValid missing in response.');
  }

  /// Persists the alt number on the account.
  ///
  /// `POST v1/MyAliv/AltNumber` → `{ "Success": true }`.
  /// Throws on transport / non-2xx errors so the repository can translate.
  Future<bool> updateAltNumber(String altNumber) async {
    if (kDebugMode) {
      debugPrint('AltNumberValidationApiClient: updating to $altNumber');
    }

    final response = await _networkService.request<dynamic>(
      Api.altNumberUpdate,
      method: HttpMethod.post,
      data: <String, dynamic>{'NewAltNumber': altNumber},
    );

    final responseMap = _decodeMap(response.data);
    final raw = responseMap['Success'] ?? responseMap['success'];

    if (raw is bool) return raw;
    if (raw is String) return raw.toLowerCase() == 'true';

    throw Exception('Success missing in response.');
  }

  /// Stores the user's offers preference for the alternate number and account.
  ///
  /// `POST v1/MyAliv/AltNumber/opt-in/{altNumber}`
  /// Body: `{ "DeviceAccountId": <int>, "IsOptedIn": <bool> }`.
  Future<bool> setMarketingOptIn({
    required String altNumber,
    required int deviceAccountId,
    required bool isOptedIn,
  }) async {
    final url = Api.mifiAltNumber(altNumber);
    final body = <String, dynamic>{
      'DeviceAccountId': deviceAccountId,
      'IsOptedIn': isOptedIn,
    };

    if (kDebugMode) {
      debugPrint(
        'AltNumberValidationApiClient: setting opt-in '
        'for deviceAccountId=$deviceAccountId, isOptedIn=$isOptedIn',
      );
      debugPrint('AltNumberValidationApiClient: opt-in url=$url');
      debugPrint('AltNumberValidationApiClient: opt-in request=$body');
    }

    final response = await _networkService.request<dynamic>(
      url,
      method: HttpMethod.post,
      data: body,
    );

    if (kDebugMode) {
      debugPrint(
        'AltNumberValidationApiClient: opt-in status=${response.statusCode}',
      );
      debugPrint(
        'AltNumberValidationApiClient: opt-in response=${response.data}',
      );
    }

    final responseMap = _decodeMap(response.data);
    final rawSuccess = responseMap['Success'] ?? responseMap['success'];

    if (rawSuccess is bool) return rawSuccess;
    if (rawSuccess is String) return rawSuccess.toLowerCase() == 'true';

    // The Postman contract does not show a response body. Treat an empty 2xx
    // response as success while still honoring an explicit Success value above.
    final statusCode = response.statusCode ?? 0;
    return statusCode >= 200 && statusCode < 300;
  }

  Map<String, dynamic> _decodeMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    }
    return <String, dynamic>{};
  }
}
