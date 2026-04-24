import 'dart:convert';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Error types for device limits API
enum DeviceLimitsErrorType {
  network,
  timeout,
  sessionExpired,
  server,
  notFound,
  unknown,
}

/// Exception for device limits API errors
class DeviceLimitsException implements Exception {
  final String message;
  final DeviceLimitsErrorType type;
  final Object? originalError;

  const DeviceLimitsException(
    this.message, {
    this.type = DeviceLimitsErrorType.unknown,
    this.originalError,
  });

  @override
  String toString() => 'DeviceLimitsException: $message';
}

/// Service for making HTTP requests to Device Limits API
///
/// Uses NetworkService for HTTP calls with automatic authentication.
class DeviceLimitsApiService {
  final NetworkService _networkService;

  DeviceLimitsApiService({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  /// Fetch device limits from API
  ///
  /// Returns raw JSON string response.
  /// Throws [DeviceLimitsException] on network or HTTP errors.
  Future<String> fetchDeviceLimits() async {
    try {
      final response = await _networkService.request<String>(
        Api.devices,
        method: HttpMethod.get,
      );

      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException catch (e) {
      throw _mapNetworkException(e);
    } catch (e) {
      throw DeviceLimitsException(
        'Failed to fetch device limits: ${e.toString()}',
        type: DeviceLimitsErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Update device credit limits
  ///
  /// [deviceAccountId] - The device account ID
  /// [body] - Map containing the limit values to update
  /// Returns true if successful (200 or 201 status code)
  /// Throws [DeviceLimitsException] on errors
  Future<bool> updateLimits({
    required int deviceAccountId,
    required Map<String, dynamic> body,
  }) async {
    final url = '${Api.deviceLimits}/$deviceAccountId/limits';

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.put,
        data: body,
      );

      final statusCode = response.statusCode ?? 0;
      return statusCode == 200 || statusCode == 201;
    } on NetworkException catch (e) {
      throw _mapNetworkException(e);
    } catch (e) {
      throw DeviceLimitsException(
        'Failed to update limits: ${e.toString()}',
        type: DeviceLimitsErrorType.unknown,
        originalError: e,
      );
    }
  }

  // ============ Auto-Renew API Methods ============

  /// Enable auto-renew from wallet
  ///
  /// PUT /device/{deviceAccountId}/auto-renew?autoRenew=true
  /// Returns true if API response { "Success": true }
  Future<bool> enableAutoRenewWallet(int deviceAccountId) async {
    final url = '${Api.deviceAutoRenew(deviceAccountId)}?autoRenew=true';

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.put,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['Success'] == true;
      }
      return false;
    } on NetworkException catch (e) {
      throw _mapNetworkException(e);
    } catch (e) {
      throw DeviceLimitsException(
        'Failed to enable auto-renew: ${e.toString()}',
        type: DeviceLimitsErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Disable auto-renew
  ///
  /// PUT /device/{deviceAccountId}/auto-renew?autoRenew=false
  /// Returns true if API response { "Success": true }
  Future<bool> disableAutoRenew(int deviceAccountId) async {
    final url = '${Api.deviceAutoRenew(deviceAccountId)}?autoRenew=false';

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.put,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['Success'] == true;
      }
      return false;
    } on NetworkException catch (e) {
      throw _mapNetworkException(e);
    } catch (e) {
      throw DeviceLimitsException(
        'Failed to disable auto-renew: ${e.toString()}',
        type: DeviceLimitsErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Update balance threshold settings for auto top-up
  ///
  /// PUT /device/{deviceAccountId}/balance-threshold-settings
  /// Returns true if API response { "Success": true }
  Future<bool> updateBalanceThresholdSettings({
    required int deviceAccountId,
    required Map<String, dynamic> body,
  }) async {
    final url = Api.balanceThresholdSettings(deviceAccountId);

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.put,
        data: body,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['Success'] == true;
      }
      return false;
    } on NetworkException catch (e) {
      throw _mapNetworkException(e);
    } catch (e) {
      throw DeviceLimitsException(
        'Failed to update balance threshold settings: ${e.toString()}',
        type: DeviceLimitsErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Enable auto-renew from credit card
  ///
  /// PUT /CreditCard/auto-renew (empty body)
  /// Returns true if API response { "Success": true }
  Future<bool> enableAutoRenewCard() async {
    try {
      final response = await _networkService.request<dynamic>(
        Api.creditCardAutoRenew,
        method: HttpMethod.put,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['Success'] == true;
      }
      return false;
    } on NetworkException catch (e) {
      throw _mapNetworkException(e);
    } catch (e) {
      throw DeviceLimitsException(
        'Failed to enable auto-renew with card: ${e.toString()}',
        type: DeviceLimitsErrorType.unknown,
        originalError: e,
      );
    }
  }

  DeviceLimitsException _mapNetworkException(NetworkException e) {
    if (e is TimeoutException) {
      return DeviceLimitsException(
        'Request timed out',
        type: DeviceLimitsErrorType.timeout,
        originalError: e,
      );
    }

    if (e is NoInternetException) {
      return DeviceLimitsException(
        'No internet connection',
        type: DeviceLimitsErrorType.network,
        originalError: e,
      );
    }

    if (e is SessionExpiredException) {
      return DeviceLimitsException(
        'Session expired. Please login again',
        type: DeviceLimitsErrorType.sessionExpired,
        originalError: e,
      );
    }

    if (e is ServerException) {
      return DeviceLimitsException(
        'Server error occurred',
        type: DeviceLimitsErrorType.server,
        originalError: e,
      );
    }

    final statusCode = e.statusCode ?? 0;

    if (statusCode == 401 || statusCode == 403) {
      return DeviceLimitsException(
        'Authentication failed',
        type: DeviceLimitsErrorType.sessionExpired,
        originalError: e,
      );
    }

    if (statusCode == 404) {
      return DeviceLimitsException(
        'Device limits not found',
        type: DeviceLimitsErrorType.notFound,
        originalError: e,
      );
    }

    if (statusCode >= 500) {
      return DeviceLimitsException(
        'Server error occurred',
        type: DeviceLimitsErrorType.server,
        originalError: e,
      );
    }

    return DeviceLimitsException(
      'Network error: ${e.message}',
      type: DeviceLimitsErrorType.network,
      originalError: e,
    );
  }
}
