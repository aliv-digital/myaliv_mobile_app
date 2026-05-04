import 'dart:convert';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/balance_threshold_settings_request.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/update_limits_request.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/repository/device_limits_api_service.dart';

/// Repository for managing device limits data
///
/// Orchestrates API calls and parsing to provide DeviceLimitsModel.
class DeviceLimitsRepository {
  final DeviceLimitsApiService _apiService;

  DeviceLimitsRepository({required DeviceLimitsApiService apiService})
      : _apiService = apiService;

  /// Fetch and parse all device limits
  ///
  /// Returns list of [DeviceLimitsModel] from the response.
  /// Throws [DeviceLimitsException] on errors.
  Future<List<DeviceLimitsModel>> getDeviceLimits() async {
    final jsonString = await _apiService.fetchDeviceLimits();
    return _parseDeviceLimits(jsonString);
  }

  /// Parse JSON response to list of DeviceLimitsModel
  ///
  /// Expects either a single device object or an array of devices.
  List<DeviceLimitsModel> _parseDeviceLimits(String jsonString) {
    try {
      final dynamic jsonData = jsonDecode(jsonString);

      if (jsonData is List && jsonData.isNotEmpty) {
        // Array response - parse all devices
        return jsonData
            .map((item) =>
                DeviceLimitsModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (jsonData is Map<String, dynamic>) {
        // Single object response - wrap in list
        return [DeviceLimitsModel.fromJson(jsonData)];
      } else {
        throw DeviceLimitsException(
          'Invalid response format',
          type: DeviceLimitsErrorType.unknown,
        );
      }
    } on FormatException catch (e) {
      throw DeviceLimitsException(
        'Failed to parse device limits: ${e.message}',
        type: DeviceLimitsErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Update device credit limits
  ///
  /// [deviceAccountId] - The device account ID
  /// [request] - The update limits request with new values
  /// Returns true if update was successful
  Future<bool> updateLimits({
    required int deviceAccountId,
    required UpdateLimitsRequest request,
  }) async {
    return _apiService.updateLimits(
      deviceAccountId: deviceAccountId,
      body: request.toJson(),
    );
  }

  // ============ Auto-Renew Methods ============

  /// Enable auto-renew from wallet balance
  ///
  /// [deviceAccountId] - The device account ID
  /// Returns true if auto-renew was enabled successfully
  Future<bool> enableAutoRenewWallet(int deviceAccountId) async {
    return _apiService.enableAutoRenewWallet(deviceAccountId);
  }

  /// Disable auto-renew
  ///
  /// [deviceAccountId] - The device account ID
  /// Returns true if auto-renew was disabled successfully
  Future<bool> disableAutoRenew(int deviceAccountId) async {
    return _apiService.disableAutoRenew(deviceAccountId);
  }

  /// Enable auto-renew from credit card
  ///
  /// [token] - Saved card token to charge on renewal
  /// Returns true if auto-renew was enabled successfully
  Future<bool> enableAutoRenewCard({required String token}) async {
    return _apiService.enableAutoRenewCard(token: token);
  }

  /// Update balance threshold settings for auto top-up
  ///
  /// [deviceAccountId] - The device account ID
  /// [request] - The balance threshold settings request
  /// Returns true if update was successful
  Future<bool> updateBalanceThresholdSettings({
    required int deviceAccountId,
    required BalanceThresholdSettingsRequest request,
  }) async {
    return _apiService.updateBalanceThresholdSettings(
      deviceAccountId: deviceAccountId,
      body: request.toJson(),
    );
  }
}
