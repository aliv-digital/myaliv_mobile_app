import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/bucket_usage_summary_exception.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/services/bucket_usage_summary_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/services/bucket_usage_summary_parser_service.dart';

/// Data contract for the bucket usage summary feature.
abstract class BucketUsageSummaryRepository {
  Future<BucketUsageSummaryModel> fetchBucketUsageSummary({
    required int deviceAccountId,
  });
}

/// Fetches raw JSON from the API and parses it into app models.
class BucketUsageSummaryRepositoryImpl implements BucketUsageSummaryRepository {
  final BucketUsageSummaryApiService _apiService;
  final BucketUsageSummaryParserService _parserService;

  BucketUsageSummaryRepositoryImpl({
    required BucketUsageSummaryApiService apiService,
    required BucketUsageSummaryParserService parserService,
  }) : _apiService = apiService,
       _parserService = parserService;

  @override
  Future<BucketUsageSummaryModel> fetchBucketUsageSummary({
    required int deviceAccountId,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'BucketUsageSummaryRepository: fetching for deviceAccountId=$deviceAccountId',
      );
    }

    try {
      final rawJson = await _apiService.fetchBucketUsageSummary(
        deviceAccountId: deviceAccountId,
      );

      return _parserService.parseBucketUsageSummary(rawJson);
    } on BucketUsageSummaryException {
      rethrow;
    } on BucketUsageSummaryParseException catch (e) {
      throw BucketUsageSummaryException(
        e.message,
        type: BucketUsageSummaryErrorType.parsing,
        originalError: e,
      );
    } catch (e) {
      throw BucketUsageSummaryException(
        'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
