import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/models/consumption_limit_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/consumption_limit_repository_exception.dart';

/// Service for parsing consumption limit JSON responses
///
/// Converts raw JSON strings to typed ConsumptionLimitModel objects.
/// Handles parsing errors gracefully with detailed logging.
class ConsumptionLimitParserService {
  /// Parse JSON string to list of ConsumptionLimitModel
  ///
  /// [jsonString] - Raw JSON response from API
  /// Returns sorted list of consumption limits
  /// Throws [ConsumptionLimitRepositoryException] on parsing errors
  ///
  /// Expected JSON format:
  /// ```json
  /// [
  ///   {"Name": "C_SMS_local_Restriction", "InitialAmount": 30.00, "UsedAmount": 15.00},
  ///   {"Name": "C_GPRS_Local", "InitialAmount": 30.00, "UsedAmount": 15.00}
  /// ]
  /// ```
  List<ConsumptionLimitModel> parseLimits(String jsonString) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🔄 CONSUMPTION LIMITS PARSER');
      debugPrint('│ Input Length: ${jsonString.length} chars');
      debugPrint('└─────────────────────────────────────────');
    }

    try {
      final dynamic decoded = jsonDecode(jsonString);

      // Handle array response
      if (decoded is List) {
        final limits = decoded
            .whereType<Map<String, dynamic>>()
            .map((json) => ConsumptionLimitModel.fromJson(json))
            .toList();

        // Sort by display order
        limits.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        if (kDebugMode) {
          debugPrint('┌─────────────────────────────────────────');
          debugPrint('│ ✅ CONSUMPTION LIMITS PARSER SUCCESS');
          debugPrint('│ Parsed ${limits.length} limits');
          for (final limit in limits) {
            debugPrint(
                '│   - ${limit.displayName}: \$${limit.remainingAmount.toStringAsFixed(2)} of \$${limit.initialAmount.toStringAsFixed(2)}');
          }
          debugPrint('└─────────────────────────────────────────');
          debugPrint('');
        }

        return limits;
      }

      // Handle unexpected format
      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ⚠️ CONSUMPTION LIMITS PARSER: Unexpected format');
        debugPrint('│ Expected: List');
        debugPrint('│ Got: ${decoded.runtimeType}');
        debugPrint('└─────────────────────────────────────────');
      }

      throw ConsumptionLimitRepositoryException(
        'Invalid response format: expected array',
        type: ConsumptionLimitErrorType.parsing,
      );
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ❌ CONSUMPTION LIMITS PARSER ERROR');
        debugPrint('│ JSON Parse Error: $e');
        debugPrint('└─────────────────────────────────────────');
      }

      throw ConsumptionLimitRepositoryException(
        'Failed to parse JSON response',
        type: ConsumptionLimitErrorType.parsing,
        originalError: e,
      );
    } catch (e) {
      if (e is ConsumptionLimitRepositoryException) rethrow;

      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ❌ CONSUMPTION LIMITS PARSER ERROR');
        debugPrint('│ Error: $e');
        debugPrint('│ Type: ${e.runtimeType}');
        debugPrint('└─────────────────────────────────────────');
      }

      throw ConsumptionLimitRepositoryException(
        'Failed to parse consumption limits: ${e.toString()}',
        type: ConsumptionLimitErrorType.parsing,
        originalError: e,
      );
    }
  }
}
