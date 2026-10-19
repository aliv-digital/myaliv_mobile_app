import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/models/best_plan_model.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository_exception.dart';

/// Service for parsing best plan JSON responses
///
/// Handles JSON parsing and validation of API responses.
/// Filters active plans and validates data structure.
class BestPlanParserService {
  /// In debug mode, automatically extend expired plans by 1 month
  /// This allows testing with expired backend data without modifying the API
  static const bool _autoExtendExpiredInDebug = true;

  /// Parse raw JSON response to list of BestPlanModel
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Operation successful",
  ///   "data": [
  ///     {
  ///       "id": 12,
  ///       "price": "45.00",
  ///       "planName": "Test 1001",
  ///       "subHeading": "7 days plan",
  ///       "link": "https://www.google.com",
  ///       "startFrom": "2026-04-06T00:00:00.000Z",
  ///       "expireOn": "2026-04-06T00:00:00.000Z",
  ///       "backgroundImageUrl": "https://...",
  ///       "type": "postpaid",
  ///       "status": "active"
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Returns list of active plans only
  /// Throws [BestPlanParseException] on parsing errors
  List<BestPlanModel> parsePlans(String jsonString) {
    try {
      // Decode JSON
      final json = jsonDecode(jsonString);

      // Validate root structure
      if (json is! Map<String, dynamic>) {
        throw const BestPlanParseException(
          'Invalid JSON structure: expected object',
        );
      }

      // Check success flag
      final success = json['success'] as bool? ?? false;
      if (kDebugMode) {
        debugPrint('✓ Success flag: $success');
      }

      if (!success) {
        final message = json['message'] as String? ?? 'Unknown error';
        throw BestPlanParseException('API returned success=false: $message');
      }

      // Extract data array
      final data = json['data'];
      if (data == null) {
        return [];
      }

      if (data is! List) {
        throw const BestPlanParseException(
          'Invalid data structure: expected array',
        );
      }

      // Parse each plan
      final plans = <BestPlanModel>[];
      for (int i = 0; i < data.length; i++) {
        final item = data[i];

        if (item is! Map<String, dynamic>) {
          continue;
        }

        try {
          var plan = BestPlanModel.fromJson(item);

          if (kDebugMode && _autoExtendExpiredInDebug) {
            plan = _extendExpiredPlanForDebug(plan);
          }

          // For best plans, include plans that:
          // 1. Have active status
          // 2. Are not yet expired
          // 3. Have already started (exclude future-start plans)
          final isActiveStatus = plan.status.toLowerCase() == 'active';
          final shouldInclude =
              isActiveStatus && !plan.isExpired && plan.isStarted;

          if (shouldInclude) {
            plans.add(plan);
          } else {
            if (kDebugMode) {
              if (plan.isExpired) {
                debugPrint('  ❌ Skipped (expired)');
              } else if (!plan.isStarted) {
                debugPrint('  ❌ Skipped (not yet started)');
              } else {
                debugPrint('  ❌ Skipped (inactive status)');
              }
            }
          }
        } catch (e) {
          continue;
        }
      }

      return plans;
    } on BestPlanParseException {
      rethrow;
    } catch (e) {
      throw BestPlanParseException(
        'Failed to parse plans: ${e.toString()}',
        originalError: e,
      );
    }
  }

  BestPlanModel _extendExpiredPlanForDebug(BestPlanModel plan) {
    final isActiveStatus = plan.status.toLowerCase() == 'active';
    if (!isActiveStatus || !plan.isExpired) {
      return plan;
    }

    final now = DateTime.now();
    final extendedExpireOn = DateTime(
      now.year,
      now.month + 1,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    if (kDebugMode) {
      debugPrint('  🛠️ Debug mode: extended expired plan by 1 month');
      debugPrint('  - Original expireOn: ${plan.expireOn}');
      debugPrint('  - Extended expireOn: $extendedExpireOn');
    }

    return plan.copyWith(expireOn: extendedExpireOn);
  }
}
