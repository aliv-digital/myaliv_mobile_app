import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository_exception.dart';

/// Service for making HTTP requests to Balance API
///
/// Uses NetworkService for HTTP calls with automatic authentication.
/// Handles network errors and converts them to typed exceptions.
class BalanceApiService {
  final NetworkService _networkService;

  BalanceApiService({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  /// Fetch balances from API
  ///
  /// [deviceAccountId] - The account ID for the device
  /// Returns raw JSON string response.
  /// Throws [BalanceRepositoryException] on network or HTTP errors.
  ///
  /// Note: NetworkService automatically includes auth headers from GlobalState
  Future<String> fetchBalances({required int deviceAccountId}) async {
    final String url = '${Api.balances}/$deviceAccountId/balances';

    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🌐 BALANCE API REQUEST');
      debugPrint('│ Method: GET');
      debugPrint('│ URL: $url');
      debugPrint('│ Account ID: $deviceAccountId');
      debugPrint('└─────────────────────────────────────────');
    }

    try {
      // NetworkService automatically includes auth headers from GlobalState
      final response = await _networkService.request<String>(
        url,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ✅ BALANCE API RESPONSE');
        debugPrint('│ Status Code: ${response.statusCode}');
        debugPrint('│ Response Body Length: ${response.data?.length ?? 0} chars');
        if (response.data != null && response.data!.length < 500) {
          debugPrint('│ Response Body: ${response.data}');
        }
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      // Return response data as JSON string
      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException catch (e) {
      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ❌ BALANCE API ERROR: NetworkException');
        debugPrint('│ Type: ${e.runtimeType}');
        debugPrint('│ Status: ${e.statusCode}');
        debugPrint('│ Message: ${e.message}');
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      throw _mapNetworkExceptionToBalanceException(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ❌ BALANCE API ERROR: Unknown');
        debugPrint('│ Error: $e');
        debugPrint('│ Type: ${e.runtimeType}');
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      throw BalanceRepositoryException(
        'Failed to fetch balances: ${e.toString()}',
        type: BalanceErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Maps NetworkException to BalanceRepositoryException
  BalanceRepositoryException _mapNetworkExceptionToBalanceException(
    NetworkException e,
  ) {
    // Handle specific network exception types
    if (e is TimeoutException) {
      return BalanceRepositoryException(
        'Request timed out',
        type: BalanceErrorType.timeout,
        originalError: e,
      );
    }

    if (e is HostUnreachableException) {
      return BalanceRepositoryException(
        e.message,
        type: BalanceErrorType.network,
        originalError: e,
      );
    }

    if (e is NoInternetException) {
      return BalanceRepositoryException(
        'No internet connection',
        type: BalanceErrorType.network,
        originalError: e,
      );
    }

    if (e is SessionExpiredException) {
      return BalanceRepositoryException(
        'Session expired. Please login again',
        type: BalanceErrorType.sessionExpired,
        originalError: e,
      );
    }

    if (e is ServerException) {
      return BalanceRepositoryException(
        'Server error occurred',
        type: BalanceErrorType.server,
        originalError: e,
      );
    }

    // Map based on status code
    final statusCode = e.statusCode ?? 0;

    switch (statusCode) {
      case 401:
      case 403:
        return BalanceRepositoryException(
          'Authentication failed',
          type: BalanceErrorType.sessionExpired,
          originalError: e,
        );
      case 404:
        return BalanceRepositoryException(
          'Balances not found',
          type: BalanceErrorType.notFound,
          originalError: e,
        );
      case 408:
        return BalanceRepositoryException(
          'Request timed out',
          type: BalanceErrorType.timeout,
          originalError: e,
        );
      default:
        if (statusCode >= 500) {
          return BalanceRepositoryException(
            'Server error occurred',
            type: BalanceErrorType.server,
            originalError: e,
          );
        } else if (statusCode >= 400) {
          return BalanceRepositoryException(
            'Bad request: ${e.message}',
            type: BalanceErrorType.unknown,
            originalError: e,
          );
        }
        return BalanceRepositoryException(
          'Network error: ${e.message}',
          type: BalanceErrorType.network,
          originalError: e,
        );
    }
  }
}
