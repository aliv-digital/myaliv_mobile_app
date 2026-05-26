import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/bucket_usage_summary_exception.dart';

/// Parses bucket usage summary JSON into typed models.
class BucketUsageSummaryParserService {
  /// Parse the API response.
  ///
  /// Expected root shape:
  /// ```json
  /// [
  ///   {
  ///     "FreeUnitTypeName": "data",
  ///     "TotalInitialAmount": 62914560.0,
  ///     "NestedDetail": []
  ///   }
  /// ]
  /// ```
  BucketUsageSummaryModel parseBucketUsageSummary(String jsonString) {
    if (kDebugMode) {
      debugPrint('BucketUsageSummaryParserService: parsing response');
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        throw const BucketUsageSummaryParseException(
          'Invalid JSON structure: expected a list at the root',
        );
      }

      final items = <BucketUsageItem>[];

      for (int index = 0; index < decoded.length; index++) {
        final rawItem = decoded[index];

        if (rawItem is! Map) {
          if (kDebugMode) {
            debugPrint(
              'BucketUsageSummaryParserService: skipped item $index because it is not an object',
            );
          }
          continue;
        }

        final item = BucketUsageItem.fromJson(
          Map<String, dynamic>.from(rawItem),
        );
        items.add(item);
      }

      if (kDebugMode) {
        debugPrint(
          'BucketUsageSummaryParserService: parsed ${items.length} bucket items',
        );
      }

      return BucketUsageSummaryModel(items: items, fetchedAt: DateTime.now());
    } on BucketUsageSummaryParseException {
      rethrow;
    } catch (e) {
      throw BucketUsageSummaryParseException(
        'Failed to parse bucket usage summary: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
