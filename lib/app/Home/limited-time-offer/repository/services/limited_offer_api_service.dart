import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/app_http_client.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/limited_offer_repository_exception.dart';

/// Service for fetching limited time offer data from API
///
/// Uses ApiService for HTTP communication with the ads-timer endpoint.
/// Does NOT require authentication (public endpoint).
///
/// Features:
/// - Detailed debug logging (request URL, method, response, errors)
/// - Automatic error handling and mapping
/// - Response validation
class LimitedOfferApiService {
  final ApiService _apiService;

  LimitedOfferApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetch active limited time offers from API
  ///
  /// Returns raw JSON string response from /v1/ads-timer/active
  ///
  /// Throws [LimitedOfferApiException] on API errors
  ///
  /// Debug logging includes:
  /// - Request URL and method
  /// - Response status code
  /// - Response body (truncated if too long)
  /// - Error details (if any)
  Future<String> fetchActiveOffers() async {
    const String url = Api.adsTimer;
    const String method = 'GET';

    // ========== DEBUG: Request Info ==========
    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────────────────────────');
      debugPrint('│ 🌐 LIMITED OFFER API REQUEST');
      debugPrint('├─────────────────────────────────────────────────────────────');
      debugPrint('│ Method: $method');
      debugPrint('│ URL: $url');
      debugPrint('│ Body: None (GET request)');
      debugPrint('│ Auth: Not required (public endpoint)');
      debugPrint('└─────────────────────────────────────────────────────────────');
    }

    try {
      // Make GET request
      final response = await _apiService.get(url);

      // ========== DEBUG: Response Info ==========
      if (kDebugMode) {
        debugPrint('');
        debugPrint('┌─────────────────────────────────────────────────────────────');
        debugPrint('│ ✅ LIMITED OFFER API RESPONSE');
        debugPrint('├─────────────────────────────────────────────────────────────');
        debugPrint('│ Status Code: ${response.statusCode}');
        debugPrint('│ Success: ${ApiService.isSuccessStatusCode(response.statusCode)}');

        // Show response body (truncate if too long)
        final responseBody = response.responseJson ?? '';
        if (responseBody.length > 500) {
          debugPrint('│ Response Body (truncated):');
          debugPrint('│ ${responseBody.substring(0, 500)}...');
        } else {
          debugPrint('│ Response Body:');
          debugPrint('│ $responseBody');
        }

        debugPrint('└─────────────────────────────────────────────────────────────');
        debugPrint('');
      }

      // Validate response status
      if (!ApiService.isSuccessStatusCode(response.statusCode)) {
        // Get friendly error message
        final errorMessage = ApiService.friendlyErrorFromResponse(response) ??
            'Failed to fetch offers: HTTP ${response.statusCode}';

        if (kDebugMode) {
          debugPrint('❌ LIMITED OFFER API ERROR: $errorMessage');
        }

        throw LimitedOfferApiException(
          statusCode: response.statusCode,
          message: errorMessage,
        );
      }

      // Validate response data
      final data = response.responseJson;
      if (data == null || data.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ LIMITED OFFER API: Empty response body');
        }

        throw const LimitedOfferApiException(
          statusCode: 204,
          message: 'Empty response from server',
        );
      }

      return data;
    } on LimitedOfferApiException {
      // Re-throw our custom exceptions
      rethrow;
    } catch (e, stackTrace) {
      // ========== DEBUG: Error Info ==========
      if (kDebugMode) {
        debugPrint('');
        debugPrint('┌─────────────────────────────────────────────────────────────');
        debugPrint('│ ❌ LIMITED OFFER API EXCEPTION');
        debugPrint('├─────────────────────────────────────────────────────────────');
        debugPrint('│ Method: $method');
        debugPrint('│ URL: $url');
        debugPrint('│ Error Type: ${e.runtimeType}');
        debugPrint('│ Error Message: $e');
        debugPrint('├─────────────────────────────────────────────────────────────');
        debugPrint('│ Stack Trace:');
        debugPrint('│ $stackTrace');
        debugPrint('└─────────────────────────────────────────────────────────────');
        debugPrint('');
      }

      // Wrap unexpected errors
      throw LimitedOfferApiException(
        statusCode: null,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Dispose of the ApiService
  void dispose() {
    _apiService.dispose();
  }
}
