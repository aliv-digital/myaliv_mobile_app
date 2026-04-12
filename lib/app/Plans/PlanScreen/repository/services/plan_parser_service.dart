import 'dart:convert';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/models/plan_categorization_result.dart';
import 'plan_categorizer_service.dart';
import 'plan_model_factory.dart';

/// Service for parsing and categorizing plans in a single pass
class PlanParserService {
  PlanParserService({
    PlanCategorizerService? categorizer,
    PlanModelFactory? modelFactory,
  })  : _categorizer = categorizer ?? PlanCategorizerService(),
        _modelFactory = modelFactory ?? PlanModelFactory();

  final PlanCategorizerService _categorizer;
  final PlanModelFactory _modelFactory;

  /// Parse raw JSON string to list of maps
  Future<List<Map<String, dynamic>>> parseRawJson(String rawJson) async {
    try {
      final decoded = json.decode(rawJson);

      if (decoded is! List) {
        throw FormatException(
          'Expected JSON array, got ${decoded.runtimeType}',
        );
      }

      return decoded
          .whereType<Map>()
          .map((map) => map.map(
                (key, value) => MapEntry<String, dynamic>(
                  key.toString(),
                  value,
                ),
              ))
          .toList(growable: false);
    } catch (e) {
      throw FormatException('Failed to parse plans JSON: $e');
    }
  }

  /// Parse and categorize all plans in a single pass
  ///
  /// This is the KEY optimization:
  /// - Loop through raw plans ONCE
  /// - Categorize each plan
  /// - Parse to appropriate model type
  /// - Store in categorized container
  Future<PlanCategorizationResult> parseAndCategorize(
    List<Map<String, dynamic>> rawPlans, {
    bool includeRawPayload = false,
  }) async {
    // Initialize categorized container
    final categorizedPlans = <PlanCategory, List<dynamic>>{
      for (final category in PlanCategory.values) category: [],
    };

    int totalProcessed = 0;
    int totalUnknown = 0;

    // SINGLE PASS: Loop through all plans once
    for (final rawPlan in rawPlans) {
      // Skip invalid plans
      if (!_categorizer.isValidPlan(rawPlan)) {
        continue;
      }

      totalProcessed++;

      // Step 1: Determine category
      final category = _categorizer.categorize(rawPlan);

      // Step 2: Parse to typed model
      final model = _modelFactory.createModel(
        rawPlan: rawPlan,
        category: category,
        includeRawPayload: includeRawPayload,
      );

      // Step 3: Add to appropriate category
      if (model != null) {
        categorizedPlans[category]?.add(model);
      }

      // Track unknown plans
      if (category == PlanCategory.unknown) {
        totalUnknown++;
      }
    }

    return PlanCategorizationResult(
      categorizedPlans: categorizedPlans,
      timestamp: DateTime.now(),
      totalProcessed: totalProcessed,
      totalUnknown: totalUnknown,
    );
  }

  /// Parse bundles JSON
  Future<Map<String, dynamic>> parseBundlesJson(String rawJson) async {
    try {
      final decoded = json.decode(rawJson);

      if (decoded is! Map) {
        throw FormatException('Expected JSON object for bundles');
      }

      return decoded.map(
        (key, value) => MapEntry<String, dynamic>(
          key.toString(),
          value,
        ),
      );
    } catch (e) {
      throw FormatException('Failed to parse bundles JSON: $e');
    }
  }

  /// Get categorization statistics
  Map<String, int> getCategoryStats(PlanCategorizationResult result) {
    return {
      for (final category in PlanCategory.values)
        category.name: result.categorizedPlans[category]?.length ?? 0,
    };
  }

  /// Validate categorization result
  bool validateResult(PlanCategorizationResult result) {
    final totalCategorized = result.categorizedPlans.values
        .fold<int>(0, (sum, list) => sum + list.length);

    return totalCategorized == result.totalProcessed;
  }
}
