import 'dart:convert';
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

  /// Fetch and parse device limits
  ///
  /// Returns [DeviceLimitsModel] from the first device in the response.
  /// Throws [DeviceLimitsException] on errors.
  Future<DeviceLimitsModel> getDeviceLimits() async {
    final jsonString = await _apiService.fetchDeviceLimits();
    return _parseDeviceLimits(jsonString);
  }

  /// Parse JSON response to DeviceLimitsModel
  ///
  /// Expects either a single device object or an array of devices.
  /// Uses the first device if array is provided.
  DeviceLimitsModel _parseDeviceLimits(String jsonString) {
    try {
      final dynamic jsonData = jsonDecode(jsonString);

      Map<String, dynamic> deviceJson;

      if (jsonData is List && jsonData.isNotEmpty) {
        // Array response - use first device
        deviceJson = jsonData.first as Map<String, dynamic>;
      } else if (jsonData is Map<String, dynamic>) {
        // Single object response
        deviceJson = jsonData;
      } else {
        throw DeviceLimitsException(
          'Invalid response format',
          type: DeviceLimitsErrorType.unknown,
        );
      }

      return DeviceLimitsModel.fromJson(deviceJson);
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
}
