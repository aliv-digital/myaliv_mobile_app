import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository_exception.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/core/networkService/app_http_client.dart';

/// Service for making HTTP requests to Best Plans API
///
/// Uses ApiService for HTTP calls with detailed debug logging.
/// Handles network errors and converts them to typed exceptions.
class BestPlanApiService {
  final ApiService _apiService;

  BestPlanApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetch active plans from API
  ///
  /// Returns raw JSON string response.
  /// Throws [BestPlanRepositoryException] on network or HTTP errors.
  Future<String> fetchActivePlans() async {
    const String url = Api.bestPlans;

    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🌐 BEST PLANS API REQUEST');
      debugPrint('│ Method: GET');
      debugPrint('│ URL: $url');
      debugPrint('└─────────────────────────────────────────');
    }

    try {
      final response = await _apiService.get(url);

      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ✅ BEST PLANS API RESPONSE');
        debugPrint('│ Status Code: ${response.statusCode}');
        debugPrint('│ Response Body Length: ${response.responseJson?.length ?? 0} chars');
        debugPrint('│ Response Body: ${response.responseJson}');
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      if (response.responseJson == null || response.responseJson!.isEmpty) {
        throw const BestPlanRepositoryException(
          'Empty response from server',
          type: BestPlanErrorType.server,
        );
      }

      return response.responseJson!;
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ❌ BEST PLANS API ERROR: Network');
        debugPrint('│ Error: $e');
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      throw BestPlanRepositoryException(
        'No internet connection',
        type: BestPlanErrorType.network,
        originalError: e,
      );
    } on HttpException catch (e) {
      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ❌ BEST PLANS API ERROR: HTTP');
        debugPrint('│ Error: $e');
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      // Check for specific HTTP status codes
      final errorMessage = e.message ?? 'HTTP error occurred';
      if (errorMessage.contains('404')) {
        throw BestPlanRepositoryException(
          'Plans not found',
          type: BestPlanErrorType.notFound,
          originalError: e,
        );
      } else if (errorMessage.contains('500') ||
          errorMessage.contains('502') ||
          errorMessage.contains('503')) {
        throw BestPlanRepositoryException(
          'Server error',
          type: BestPlanErrorType.server,
          originalError: e,
        );
      }

      throw BestPlanRepositoryException(
        errorMessage,
        type: BestPlanErrorType.server,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ❌ BEST PLANS API ERROR: Unknown');
        debugPrint('│ Error: $e');
        debugPrint('│ Type: ${e.runtimeType}');
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      // Check if it's a timeout
      if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        throw BestPlanRepositoryException(
          'Request timed out',
          type: BestPlanErrorType.timeout,
          originalError: e,
        );
      }

      throw BestPlanRepositoryException(
        'Failed to fetch plans: ${e.toString()}',
        type: BestPlanErrorType.unknown,
        originalError: e,
      );
    }
  }
}
