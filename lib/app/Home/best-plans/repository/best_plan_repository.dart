import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/models/best_plan_model.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository_exception.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/services/best_plan_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/services/best_plan_parser_service.dart';

/// Abstract interface for Best Plan data operations
abstract class BestPlanRepository {
  /// Fetch active plans from API
  ///
  /// [userType] - 'prepaid' or 'postpaid' (default: 'prepaid')
  /// Returns list of active, valid plans filtered by user type
  /// Throws [BestPlanRepositoryException] on errors
  Future<List<BestPlanModel>> fetchActivePlans({String userType = 'prepaid'});
}

/// Implementation of BestPlanRepository
///
/// Orchestrates API calls and JSON parsing.
/// Filters plans by user type (prepaid/postpaid).
class BestPlanRepositoryImpl implements BestPlanRepository {
  final BestPlanApiService _apiService;
  final BestPlanParserService _parserService;

  BestPlanRepositoryImpl({
    required BestPlanApiService apiService,
    required BestPlanParserService parserService,
  })  : _apiService = apiService,
        _parserService = parserService;

  @override
  Future<List<BestPlanModel>> fetchActivePlans({
    String userType = 'prepaid',
  }) async {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('🏪 BEST PLANS REPOSITORY: Fetching active plans');
      debugPrint('   User Type: $userType');
    }

    try {
      // Step 1: Fetch raw JSON from API
      final rawJson = await _apiService.fetchActivePlans();

      if (kDebugMode) {
        debugPrint('✓ API call successful, parsing response...');
      }

      // Step 2: Parse JSON to models
      final allPlans = _parserService.parsePlans(rawJson);

      if (kDebugMode) {
        debugPrint(
            '✓ Parsing complete: ${allPlans.length} total plans parsed');
      }

      // Step 3: Filter by user type
      final userTypeLower = userType.toLowerCase();
      final filteredPlans = allPlans
          .where((plan) => plan.type.toLowerCase() == userTypeLower)
          .toList();

      if (kDebugMode) {
        debugPrint(
            '✓ Filtered by user type "$userType": ${filteredPlans.length} plans');
        debugPrint('');
      }

      return filteredPlans;
    } on BestPlanRepositoryException {
      if (kDebugMode) {
        debugPrint('❌ Repository error occurred');
        debugPrint('');
      }
      rethrow;
    } on BestPlanParseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Parsing error occurred: $e');
        debugPrint('');
      }

      throw BestPlanRepositoryException(
        'Failed to parse plans: ${e.message}',
        type: BestPlanErrorType.parsing,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unknown error occurred: $e');
        debugPrint('');
      }

      throw BestPlanRepositoryException(
        'Unexpected error: ${e.toString()}',
        type: BestPlanErrorType.unknown,
        originalError: e,
      );
    }
  }
}
