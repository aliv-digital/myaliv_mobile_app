import 'dart:convert';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/consumption_limit_repository_exception.dart';

/// Service for making HTTP requests to Consumption Limits API
///
/// Uses NetworkService for HTTP calls with automatic authentication.
/// Handles network errors and converts them to typed exceptions.
class ConsumptionLimitApiService {
  final NetworkService _networkService;

  ConsumptionLimitApiService({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  /// Fetch consumption limits from API
  ///
  /// [deviceAccountId] - The account ID for the device
  /// Returns raw JSON string response.
  /// Throws [ConsumptionLimitRepositoryException] on network or HTTP errors.
  ///
  /// Note: NetworkService automatically includes auth headers from GlobalState
  Future<String> fetchConsumptionLimits({required int deviceAccountId}) async {
    final String url =
        '${Api.consumptionLimits}/$deviceAccountId/query-consumption-limit';

    try {
      // NetworkService automatically includes auth headers from GlobalState
      final response = await _networkService.request<String>(
        url,
        method: HttpMethod.get,
      );

      // Return response data as JSON string
      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException catch (e) {
      throw _mapNetworkException(e);
    } catch (e) {
      throw ConsumptionLimitRepositoryException(
        'Failed to fetch consumption limits: ${e.toString()}',
        type: ConsumptionLimitErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Maps NetworkException to ConsumptionLimitRepositoryException
  ConsumptionLimitRepositoryException _mapNetworkException(NetworkException e) {
    // Handle specific network exception types
    if (e is TimeoutException) {
      return ConsumptionLimitRepositoryException(
        'Request timed out',
        type: ConsumptionLimitErrorType.timeout,
        originalError: e,
      );
    }

    if (e is HostUnreachableException) {
      return ConsumptionLimitRepositoryException(
        e.message,
        type: ConsumptionLimitErrorType.network,
        originalError: e,
      );
    }

    if (e is NoInternetException) {
      return ConsumptionLimitRepositoryException(
        'No internet connection',
        type: ConsumptionLimitErrorType.network,
        originalError: e,
      );
    }

    if (e is SessionExpiredException) {
      return ConsumptionLimitRepositoryException(
        'Session expired. Please login again',
        type: ConsumptionLimitErrorType.sessionExpired,
        originalError: e,
      );
    }

    if (e is ServerException) {
      return ConsumptionLimitRepositoryException(
        'Server error occurred',
        type: ConsumptionLimitErrorType.server,
        originalError: e,
      );
    }

    // Map based on status code
    final statusCode = e.statusCode ?? 0;

    switch (statusCode) {
      case 401:
      case 403:
        return ConsumptionLimitRepositoryException(
          'Authentication failed',
          type: ConsumptionLimitErrorType.sessionExpired,
          originalError: e,
        );
      case 404:
        return ConsumptionLimitRepositoryException(
          'Consumption limits not found',
          type: ConsumptionLimitErrorType.notFound,
          originalError: e,
        );
      case 408:
        return ConsumptionLimitRepositoryException(
          'Request timed out',
          type: ConsumptionLimitErrorType.timeout,
          originalError: e,
        );
      default:
        if (statusCode >= 500) {
          return ConsumptionLimitRepositoryException(
            'Server error occurred',
            type: ConsumptionLimitErrorType.server,
            originalError: e,
          );
        } else if (statusCode >= 400) {
          return ConsumptionLimitRepositoryException(
            'Bad request: ${e.message}',
            type: ConsumptionLimitErrorType.unknown,
            originalError: e,
          );
        }
        return ConsumptionLimitRepositoryException(
          'Network error: ${e.message}',
          type: ConsumptionLimitErrorType.network,
          originalError: e,
        );
    }
  }
}
