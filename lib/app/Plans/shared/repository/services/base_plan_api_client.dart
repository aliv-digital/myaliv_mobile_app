import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../base_plan_repository_exception.dart';

/// Base API client with shared error handling logic.
///
/// All plan API clients should extend this to get consistent:
/// - Authentication handling
/// - Error mapping
/// - Debug logging
///
/// Benefits:
/// - Eliminates duplicate error handling code
/// - Consistent error messages across all plan services
/// - Easier to maintain and test
/// - Single place to fix bugs
///
/// Usage:
/// ```dart
/// class MyPlanApiClient extends BasePlanApiClient {
///   MyPlanApiClient({
///     NetworkService? networkService,
///     AuthManager? authManager,
///   }) : super(
///           networkService: networkService,
///           authManager: authManager,
///           debugName: 'my-service',
///         );
///
///   Future<String> fetchPlans() async {
///     final auth = requireAuth(); // Throws if not authenticated
///
///     final response = await networkService.request<String>(
///       '/api/plans',
///       method: HttpMethod.get,
///     );
///
///     validateResponse(
///       statusCode: response.statusCode,
///       responseBody: response.data,
///     );
///
///     return response.data ?? '';
///   }
/// }
/// ```
abstract class BasePlanApiClient {
  BasePlanApiClient({
    NetworkService? networkService,
    AuthManager? authManager,
    this.debugName,
  })  : _networkService = networkService ?? instance<NetworkService>(),
        _authManager = authManager ?? instance<AuthManager>();

  final NetworkService _networkService;
  final AuthManager _authManager;
  final String? debugName;

  /// Get network service instance (for subclass usage)
  NetworkService get networkService => _networkService;

  /// Get auth manager instance (for subclass usage)
  AuthManager get authManager => _authManager;

  /// Get current auth or throw if not authenticated
  ///
  /// Convenience method for subclasses to ensure authentication.
  AuthContext requireAuth() {
    final auth = _authManager.getCurrentAuth();

    if (auth == null || !auth.isAuthenticated) {
      throw BasePlanRepositoryException(
        type: BasePlanRepositoryErrorType.unauthorized,
        serverMessage: 'Authentication required',
        statusCode: 401,
        source: debugName,
      );
    }

    return auth;
  }

  /// Map HTTP error to typed exception (shared logic)
  ///
  /// This method handles all common HTTP status codes and converts them
  /// to appropriate exception types.
  BasePlanRepositoryException mapErrorToException({
    required int statusCode,
    required String responseBody,
  }) {
    final serverMessage = extractServerMessage(responseBody);

    // Timeout or no connection
    if (statusCode == 0) {
      if (responseBody.toLowerCase().contains('timeout')) {
        return BasePlanRepositoryException(
          type: BasePlanRepositoryErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage,
          source: debugName,
        );
      }
      return BasePlanRepositoryException(
        type: BasePlanRepositoryErrorType.noInternet,
        statusCode: statusCode,
        serverMessage: serverMessage,
        source: debugName,
      );
    }

    // Map status codes to error types
    switch (statusCode) {
      case 401:
        return BasePlanRepositoryException(
          type: BasePlanRepositoryErrorType.unauthorized,
          statusCode: statusCode,
          serverMessage: serverMessage,
          source: debugName,
        );
      case 403:
        return BasePlanRepositoryException(
          type: BasePlanRepositoryErrorType.forbidden,
          statusCode: statusCode,
          serverMessage: serverMessage,
          source: debugName,
        );
      case 404:
        return BasePlanRepositoryException(
          type: BasePlanRepositoryErrorType.notFound,
          statusCode: statusCode,
          serverMessage: serverMessage,
          source: debugName,
        );
      case 408:
        return BasePlanRepositoryException(
          type: BasePlanRepositoryErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage,
          source: debugName,
        );
      default:
        if (statusCode >= 500) {
          return BasePlanRepositoryException(
            type: BasePlanRepositoryErrorType.server,
            statusCode: statusCode,
            serverMessage: serverMessage,
            source: debugName,
          );
        } else if (statusCode >= 400) {
          return BasePlanRepositoryException(
            type: BasePlanRepositoryErrorType.badResponse,
            statusCode: statusCode,
            serverMessage: serverMessage,
            source: debugName,
          );
        }
        return BasePlanRepositoryException(
          type: BasePlanRepositoryErrorType.unknown,
          statusCode: statusCode,
          serverMessage: serverMessage,
          source: debugName,
        );
    }
  }

  /// Extract error message from response body (shared logic)
  ///
  /// Attempts to parse JSON and extract common error message fields.
  /// Falls back to raw response body if JSON parsing fails.
  String? extractServerMessage(String responseBody) {
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

  /// Validate response and throw on error (helper method)
  ///
  /// Convenience method for subclasses to validate API responses.
  /// Throws BasePlanRepositoryException if status code indicates error.
  void validateResponse({
    required int? statusCode,
    required String? responseBody,
  }) {
    if (statusCode == null || statusCode < 200 || statusCode >= 300) {
      throw mapErrorToException(
        statusCode: statusCode ?? 0,
        responseBody: responseBody ?? '',
      );
    }
  }

  /// Log debug message with optional prefix
  ///
  /// Only logs in debug mode.
  void debugLog(String message) {
    if (kDebugMode) {
      final prefix = debugName != null ? '$debugName: ' : '';
      debugPrint('$prefix$message');
    }
  }
}
