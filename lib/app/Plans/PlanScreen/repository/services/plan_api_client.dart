import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../../../../../core/networkService/api_paths.dart';
import '../plan_repository_exception.dart';

/// Handles API calls for plan data.
///
/// Responsibilities:
/// - Make authenticated API requests
/// - Parse JSON responses
/// - Map HTTP errors to PlanRepositoryException
class PlanApiClient {
  PlanApiClient({
    NetworkService? networkService,
    AuthManager? authManager,
  })  : _networkService = networkService ?? instance<NetworkService>(),
        _authManager = authManager ?? instance<AuthManager>();

  final NetworkService _networkService;
  final AuthManager _authManager;

  /// Fetch raw plans JSON from API
  ///
  /// Returns the raw response body as a string.
  /// Throws [PlanRepositoryException] on errors.
  Future<String> fetchRawPlansJson() async {
    // Get auth context
    final auth = _authManager.getCurrentAuth();

    if (auth == null || !auth.isAuthenticated) {
      throw PlanRepositoryException(
        type: PlanRepositoryErrorType.unauthorized,
        serverMessage: 'Authentication required to fetch plans',
        statusCode: 401,
      );
    }

    if (kDebugMode) {
      debugPrint('PlanApiClient: Fetching plans for device=${auth.deviceAccountID}');
    }

    // Make API request
    final response = await _networkService.request<String>(
      "${Api.getAllPlans}/${auth.deviceAccountID}/available-plans",
      method: HttpMethod.get,
    );

    if (kDebugMode) {
      debugPrint('PlanApiClient: Response status=${response.statusCode}');
    }

    // Validate response
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw _mapErrorToException(
        statusCode: response.statusCode ?? 0,
        responseBody: response.data ?? '',
      );
    }

    return response.data ?? '';
  }

  /// Fetch raw bundles JSON from API.
  ///
  /// Returns the raw response body as a string.
  /// Throws [PlanRepositoryException] on errors.
  Future<String> fetchRawBundlesJson() async {
    final auth = _authManager.getCurrentAuth();

    if (auth == null || !auth.isAuthenticated) {
      throw PlanRepositoryException(
        type: PlanRepositoryErrorType.unauthorized,
        serverMessage: 'Authentication required to fetch add-ons',
        statusCode: 401,
      );
    }

    if (kDebugMode) {
      debugPrint(
        'PlanApiClient: Fetching bundles for device=${auth.deviceAccountID}',
      );
    }

    final response = await _networkService.request<String>(
      "${Api.getBundles}/${auth.deviceAccountID}/bundles",
      method: HttpMethod.get,
    );

    if (kDebugMode) {
      debugPrint(
          'PlanApiClient: Bundles response status=${response.statusCode}');
    }

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw _mapErrorToException(
        statusCode: response.statusCode ?? 0,
        responseBody: response.data ?? '',
      );
    }

    return response.data ?? '';
  }

  /// Map HTTP error to typed exception
  PlanRepositoryException _mapErrorToException({
    required int statusCode,
    required String responseBody,
  }) {
    final serverMessage = _extractServerMessage(responseBody);

    // Timeout or no connection
    if (statusCode == 0) {
      if (responseBody.toLowerCase().contains('timeout')) {
        return PlanRepositoryException(
          type: PlanRepositoryErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      }
      return PlanRepositoryException(
        type: PlanRepositoryErrorType.noInternet,
        statusCode: statusCode,
        serverMessage: serverMessage,
      );
    }

    // Map status codes to error types
    switch (statusCode) {
      case 401:
        return PlanRepositoryException(
          type: PlanRepositoryErrorType.unauthorized,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      case 403:
        return PlanRepositoryException(
          type: PlanRepositoryErrorType.forbidden,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      case 404:
        return PlanRepositoryException(
          type: PlanRepositoryErrorType.notFound,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      case 408:
        return PlanRepositoryException(
          type: PlanRepositoryErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
      default:
        if (statusCode >= 500) {
          return PlanRepositoryException(
            type: PlanRepositoryErrorType.server,
            statusCode: statusCode,
            serverMessage: serverMessage,
          );
        } else if (statusCode >= 400) {
          return PlanRepositoryException(
            type: PlanRepositoryErrorType.badResponse,
            statusCode: statusCode,
            serverMessage: serverMessage,
          );
        }
        return PlanRepositoryException(
          type: PlanRepositoryErrorType.unknown,
          statusCode: statusCode,
          serverMessage: serverMessage,
        );
    }
  }

  /// Extract error message from response body
  String? _extractServerMessage(String responseBody) {
    if (responseBody.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(responseBody);

      // String response
      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }

      // Map response - check common error keys
      if (decoded is Map) {
        for (final key in [
          'message',
          'error',
          'errorMessage',
          'detail',
          'title'
        ]) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
    } catch (_) {
      // Not JSON, return as-is
    }

    final trimmed = responseBody.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
