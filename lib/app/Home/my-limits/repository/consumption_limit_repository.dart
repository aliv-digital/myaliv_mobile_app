import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/models/consumption_limit_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/consumption_limit_repository_exception.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/services/consumption_limit_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/services/consumption_limit_parser_service.dart';

/// Abstract repository interface for Consumption Limits
abstract class ConsumptionLimitRepository {
  /// Fetch consumption limits for the device account
  ///
  /// [deviceAccountId] - The account ID for the device
  /// Returns list of consumption limits
  /// Throws [ConsumptionLimitRepositoryException] on errors
  Future<List<ConsumptionLimitModel>> fetchLimits({
    required int deviceAccountId,
  });
}

/// Concrete implementation of ConsumptionLimitRepository
///
/// Orchestrates API service and parser service to fetch and parse limits.
class ConsumptionLimitRepositoryImpl implements ConsumptionLimitRepository {
  final ConsumptionLimitApiService _apiService;
  final ConsumptionLimitParserService _parserService;

  ConsumptionLimitRepositoryImpl({
    required ConsumptionLimitApiService apiService,
    required ConsumptionLimitParserService parserService,
  })  : _apiService = apiService,
        _parserService = parserService;

  @override
  Future<List<ConsumptionLimitModel>> fetchLimits({
    required int deviceAccountId,
  }) async {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('📦 CONSUMPTION LIMIT REPOSITORY: fetchLimits()');
      debugPrint('   Device Account ID: $deviceAccountId');
    }

    try {
      // 1. Fetch raw JSON from API
      if (kDebugMode) {
        debugPrint('   Step 1: Fetching from API...');
      }
      final rawJson = await _apiService.fetchConsumptionLimits(
        deviceAccountId: deviceAccountId,
      );

      // 2. Parse JSON to models
      if (kDebugMode) {
        debugPrint('   Step 2: Parsing JSON...');
      }
      final limits = _parserService.parseLimits(rawJson);

      if (kDebugMode) {
        debugPrint('   ✅ Repository returning ${limits.length} limits');
        debugPrint('');
      }

      return limits;
    } on ConsumptionLimitRepositoryException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ❌ Repository error: $e');
      }
      throw ConsumptionLimitRepositoryException(
        'Failed to fetch consumption limits: ${e.toString()}',
        type: ConsumptionLimitErrorType.unknown,
        originalError: e,
      );
    }
  }
}
