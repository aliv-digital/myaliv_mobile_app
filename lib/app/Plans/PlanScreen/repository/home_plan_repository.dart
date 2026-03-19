import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/networkService/api_paths.dart';
import '../../../../core/networkService/app_http_client.dart';
import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/daily_plan_model.dart';
import '../models/monthly_plan_model.dart';
import '../models/weekly_plan_model.dart';
import 'plan_repository_exception.dart';

enum HomePlanTab {
  daily,
  weekly,
  monthly,
  roaming,
  roameasy,
  addOns,
  mifi,
  libertyGlobal,
}

/// Converts one dynamic map to string-keyed map.
Map<String, dynamic> _toStringKeyedMapInBackground(Map<dynamic, dynamic> item) {
  return item.map((dynamic key, dynamic value) => MapEntry<String, dynamic>(key.toString(), value),
  );
}

/// Normalizes a value for strict case-insensitive comparison.
String _normalizedUpperInBackground(dynamic value) {
  return value?.toString().trim().toUpperCase() ?? '';
}

/// Background worker:
/// Decodes raw JSON and normalizes it into `List<Map<String, dynamic>>`.
///
/// Important:
/// - Must stay top-level for `compute(...)`.
/// - Must return only isolate-safe data structures.
List<Map<String, dynamic>> _decodePlansJsonInBackground(String rawBody) {
  final dynamic decoded = jsonDecode(rawBody);

  if (decoded is! List) {
    throw const FormatException('Expected JSON array root for plans response.');
  }

  return decoded
      .whereType<Map>()
      .map(_toStringKeyedMapInBackground)
      .toList(growable: false);
}

// /v1/MyAliv/device/{{deviceAccountId}}/available-plans
class HomePlanRepository {
  HomePlanRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  /// Holds the latest full payload in normalized format.
  /// This is repository-only cache for debug/inspection.
  List<Map<String, dynamic>> _lastFetchedPlans = <Map<String, dynamic>>[];

  /// Timestamp for last successful fetch.
  DateTime? _lastFetchedAt;

  /// Holds strict daily plans parsed from latest API payload.
  List<DailyPlanModel> _lastFetchedDailyPlans = <DailyPlanModel>[];

  /// Timestamp for latest successful strict daily filtering.
  DateTime? _lastFetchedDailyAt;

  /// Holds strict weekly plans parsed from latest API payload.
  List<WeeklyPlanModel> _lastFetchedWeeklyPlans = <WeeklyPlanModel>[];

  /// Timestamp for latest successful strict weekly filtering.
  DateTime? _lastFetchedWeeklyAt;

  /// Holds strict monthly plans parsed from latest API payload.
  List<MonthlyPlanModel> _lastFetchedMonthlyPlans = <MonthlyPlanModel>[];

  /// Timestamp for latest successful strict monthly filtering.
  DateTime? _lastFetchedMonthlyAt;

  /// Fetches full available-plans payload and normalizes it.
  ///
  /// Steps:
  /// 1. Request API with Basic Auth header.
  /// 2. Validate HTTP success status.
  /// 3. Decode JSON safely.
  /// 4. Normalize to `List<Map<String, dynamic>>`.
  /// 5. Cache payload + fetch time.
  Future<List<Map<String, dynamic>>> getPlans({
    required String username,
    required String password,
    required String deviceAccountID,
    bool printRawResponse = false,
  }) async {
    final String rawResponseBody = await _fetchPlansRawResponseBody(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
    );

    // Step-3:
    // Decode JSON in background isolate to keep UI thread smooth.
    // This avoids parse-related jank on slower devices.
    final List<Map<String, dynamic>> plans;
    try {
      plans = await compute(_decodePlansJsonInBackground, rawResponseBody);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getPlans: background decode failed: $e');
      }
      throw PlanRepositoryException(
        type: PlanRepositoryErrorType.parsing,
        debugMessage: 'Failed to decode plans response JSON in background.',
      );
    }

    _lastFetchedPlans = plans;
    _lastFetchedAt = DateTime.now();

    if (kDebugMode) {
      debugPrint(
        'getPlans: decoded plans=${plans.length}, cachedAt=$_lastFetchedAt',
      );
    }

    return plans;
  }

  /// Ensures the full available-plans response is loaded into repository cache.
  ///
  /// Why this exists:
  /// - Daily and Weekly both come from the same API endpoint
  /// - we should fetch that large payload only once
  /// - later tab switches should reuse the in-memory normalized list
  Future<List<Map<String, dynamic>>> _ensureFullPlansCacheLoaded({
    required String username,
    required String password,
    required String deviceAccountID,
    required bool printRawResponse,
  }) async {
    if (_lastFetchedPlans.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 450));
      return _lastFetchedPlans;
    }

    return getPlans(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
    );
  }

  /// Filters one tab's strict primary plans from the full cached response.
  ///
  /// This works on the already-normalized cache, so we avoid re-fetching the API
  /// and avoid re-decoding the full response for every tab.
  List<Map<String, dynamic>> _filterStrictPlansFromFullCache({required String planType, required String frequency}) {
    final String normalizedPlanType = planType.trim().toUpperCase();
    final String normalizedFrequency = frequency.trim().toUpperCase();

    return _lastFetchedPlans.where((Map<String, dynamic> plan) {
      final String currentPlanType =
          _normalizedUpperInBackground(plan['PlanType']);
      final String currentFrequency =
          _normalizedUpperInBackground(plan['Frequency']);

      return currentPlanType == normalizedPlanType &&
          currentFrequency == normalizedFrequency;
    }).toList(growable: false);
  }

  /// Fetch and parse API payload into dedicated Daily model list.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - Frequency = D
  ///
  /// Notes:
  /// - Keeps UI untouched; this is API data preparation only.
  /// - Stores result in repository cache for later state update.
  Future<List<DailyPlanModel>> fetchDailyPlansFromApi({
    required String username,
    required String password,
    required String deviceAccountID,
    bool printRawResponse = false,
    bool printFilteredDailyPlans = false,
  }) async {
    // Step-1:
    // Load the full plans response only once and keep it in repository memory.
    final List<Map<String, dynamic>> fullPlans = await _ensureFullPlansCacheLoaded(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
    );

    // Step-2:
    // Filter Daily primary plans from the cached full list.
    final int totalRawPlansCount = fullPlans.length;
    final List<Map<String, dynamic>> strictDailyRawPlans = _filterStrictPlansFromFullCache(
      planType: 'P',
      frequency: 'D',
    );

    // Step-3:
    // Parse only matched raw daily maps into typed DailyPlanModel list.
    // `includeRawPayload: false` keeps memory usage low in runtime.
    final List<DailyPlanModel> strictDailyPlans = strictDailyRawPlans
        .map(
          (Map<String, dynamic> planMap) => DailyPlanModel.fromApiMap(
            planMap,
            includeRawPayload: false,
          ),
        )
        .toList(growable: false);

    _lastFetchedDailyPlans = strictDailyPlans;
    _lastFetchedDailyAt = DateTime.now();

    // Step-4:
    // Optional debug summary/details in console.
    if (printFilteredDailyPlans) {
      _logDailyFilterResult(
        totalRawPlansCount: totalRawPlansCount,
        matchedRawPlansCount: strictDailyRawPlans.length,
        dailyPlans: strictDailyPlans,
      );
    }

    return strictDailyPlans;
  }

  /// Debug wrapper:
  /// fetch strict daily plans and print summary/details in console.
  Future<List<Map<String, dynamic>>> debugFetchAndPrintDailyPlans({
    required String username,
    required String password,
    required String deviceAccountID,
    bool printRawResponse = false,
  }) async {
    final List<DailyPlanModel> dailyPlans = await fetchDailyPlansFromApi(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
      printFilteredDailyPlans: true,
    );

    return dailyPlans.map((plan) => plan.toDebugMap()).toList(growable: false);
  }

  /// Fetch and parse API payload into dedicated Weekly model list.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - Frequency = W
  ///
  /// Notes:
  /// - This mirrors the Daily repository flow.
  Future<List<WeeklyPlanModel>> fetchWeeklyPlansFromApi({
    required String username,
    required String password,
    required String deviceAccountID,
    bool printRawResponse = false,
    bool printFilteredWeeklyPlans = false,
  }) async {
    // Step-1:
    // Load the full plans response only once and keep it in repository memory.
    final List<Map<String, dynamic>> fullPlans =
        await _ensureFullPlansCacheLoaded(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
    );

    // Step-2:
    // Filter Weekly primary plans from the cached full list.
    final int totalRawPlansCount = fullPlans.length;
    final List<Map<String, dynamic>> strictWeeklyRawPlans =
        _filterStrictPlansFromFullCache(
      planType: 'P',
      frequency: 'W',
    );

    // Step-3:
    // Parse only matched raw weekly maps into typed WeeklyPlanModel list.
    // `includeRawPayload: false` keeps memory usage low in runtime.
    final List<WeeklyPlanModel> strictWeeklyPlans = strictWeeklyRawPlans
        .map(
          (Map<String, dynamic> planMap) => WeeklyPlanModel.fromApiMap(
            planMap,
            includeRawPayload: false,
          ),
        )
        .toList(growable: false);

    _lastFetchedWeeklyPlans = strictWeeklyPlans;
    _lastFetchedWeeklyAt = DateTime.now();

    // Step-4:
    // Optional debug summary/details in console.
    if (printFilteredWeeklyPlans) {
      _logWeeklyFilterResult(
        totalRawPlansCount: totalRawPlansCount,
        matchedRawPlansCount: strictWeeklyRawPlans.length,
        weeklyPlans: strictWeeklyPlans,
      );
    }

    return List<WeeklyPlanModel>.unmodifiable(_lastFetchedWeeklyPlans);
  }

  /// Debug wrapper:
  /// fetch strict weekly plans and print summary/details in console.
  Future<List<Map<String, dynamic>>> debugFetchAndPrintWeeklyPlans({
    required String username,
    required String password,
    required String deviceAccountID,
    bool printRawResponse = false,
  }) async {
    final List<WeeklyPlanModel> weeklyPlans = await fetchWeeklyPlansFromApi(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
      printFilteredWeeklyPlans: true,
    );

    return weeklyPlans.map((plan) => plan.toDebugMap()).toList(growable: false);
  }

  /// Fetch and parse API payload into dedicated Monthly model list.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - Frequency = M
  ///
  /// Notes:
  /// - This mirrors the Daily and Weekly repository flow.
  Future<List<MonthlyPlanModel>> fetchMonthlyPlansFromApi({
    required String username,
    required String password,
    required String deviceAccountID,
    bool printRawResponse = false,
    bool printFilteredMonthlyPlans = false,
  }) async {
    // Step-1:
    // Load the full plans response only once and keep it in repository memory.
    final List<Map<String, dynamic>> fullPlans = await _ensureFullPlansCacheLoaded(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
    );

    // Step-2:
    // Filter Monthly primary plans from the cached full list.
    final int totalRawPlansCount = fullPlans.length;
    final List<Map<String, dynamic>> strictMonthlyRawPlans =
    _filterStrictPlansFromFullCache(
      planType: 'P',
      frequency: 'M',
    );

    // Step-3:
    // Parse only matched raw monthly maps into typed MonthlyPlanModel list.
    // `includeRawPayload: false` keeps memory usage low in runtime.
    final List<MonthlyPlanModel> strictMonthlyPlans = strictMonthlyRawPlans.map((Map<String, dynamic> planMap) => MonthlyPlanModel.fromApiMap(
            planMap,
            includeRawPayload: false,
          ),
        ).toList(growable: false);
    _lastFetchedMonthlyPlans = strictMonthlyPlans;
    _lastFetchedMonthlyAt = DateTime.now();

    // Step-4:
    // Optional debug summary/details in console.
    if (printFilteredMonthlyPlans) {
      _logMonthlyFilterResult(
        totalRawPlansCount: totalRawPlansCount,
        matchedRawPlansCount: strictMonthlyRawPlans.length,
        monthlyPlans: strictMonthlyPlans,
      );
    }

    return List<MonthlyPlanModel>.unmodifiable(_lastFetchedMonthlyPlans);
  }

  /// Debug wrapper:
  /// fetch strict monthly plans and print summary/details in console.
  Future<List<Map<String, dynamic>>> debugFetchAndPrintMonthlyPlans({
    required String username,
    required String password,
    required String deviceAccountID,
    bool printRawResponse = false,
  }) async {
    final List<MonthlyPlanModel> monthlyPlans = await fetchMonthlyPlansFromApi(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
      printFilteredMonthlyPlans: true,
    );

    return monthlyPlans.map((plan) => plan.toDebugMap()).toList(growable: false);
  }

  /// Read-only view of latest raw payload cache.
  List<Map<String, dynamic>> get lastFetchedPlans => List<Map<String, dynamic>>.unmodifiable(_lastFetchedPlans);

  /// Read-only view of latest payload fetch time.
  DateTime? get lastFetchedAt => _lastFetchedAt;

  /// Read-only latest strict daily plans cache.
  List<DailyPlanModel> get lastFetchedDailyPlans => List<DailyPlanModel>.unmodifiable(_lastFetchedDailyPlans);

  /// Read-only latest strict daily filter timestamp.
  DateTime? get lastFetchedDailyAt => _lastFetchedDailyAt;

  /// Read-only latest strict weekly plans cache.
  List<WeeklyPlanModel> get lastFetchedWeeklyPlans => List<WeeklyPlanModel>.unmodifiable(_lastFetchedWeeklyPlans);

  /// Read-only latest strict weekly filter timestamp.
  DateTime? get lastFetchedWeeklyAt => _lastFetchedWeeklyAt;

  /// Read-only latest strict monthly plans cache.
  List<MonthlyPlanModel> get lastFetchedMonthlyPlans => List<MonthlyPlanModel>.unmodifiable(_lastFetchedMonthlyPlans);

  /// Read-only latest strict monthly filter timestamp.
  DateTime? get lastFetchedMonthlyAt => _lastFetchedMonthlyAt;

  /// Builds Basic Auth token from username/password pair.
  String _buildBasicAuthToken(
      {required String username, required String password}) {
    final String credentials = '$username:$password';
    return base64Encode(utf8.encode(credentials));
  }

  /// Shared API call for available plans.
  ///
  /// Returns raw JSON response body on success.
  /// Throws [PlanRepositoryException] for any network/API failure.
  Future<String> _fetchPlansRawResponseBody({
    required String username,
    required String password,
    required String deviceAccountID,
    required bool printRawResponse,
  }) async {
    final String basicAuthToken = _buildBasicAuthToken(
      username: username,
      password: password,
    );

    if (kDebugMode) {
      debugPrint('plans-api: request initiated for user=$username');
    }

    final response = await _api.get(
      "${Api.getAllPlans}/$deviceAccountID/available-plans",
      headers: <String, String>{'Authorization': 'Basic $basicAuthToken'},
    );

    if (kDebugMode) {
      debugPrint('plans-api: status=${response.statusCode}');
    }

    if (!ApiService.isSuccessStatusCode(response.statusCode)) {
      if (kDebugMode) {
        debugPrint(
          'plans-api: failed, status=${response.statusCode}, '
          'responseLength=${response.responseJson.length}',
        );
      }
      throw _mapApiFailureToException(
        statusCode: response.statusCode,
        responseBody: response.responseJson,
      );
    }

    if (kDebugMode && printRawResponse) {
      _debugPrintChunked(
        response.responseJson,
        header: 'plans-api raw response',
      );
    }

    return response.responseJson;
  }

  /// Maps API status/body to typed repository exception.
  PlanRepositoryException _mapApiFailureToException({
    required int statusCode,
    required String responseBody,
  }) {
    final String normalized = responseBody.trim().toLowerCase();
    final String? serverMessage = _tryExtractServerMessage(responseBody);

    if (statusCode == 0) {
      if (normalized.contains('timeout')) {
        return PlanRepositoryException(
          type: PlanRepositoryErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage,
          debugMessage: responseBody,
        );
      }
      return PlanRepositoryException(
        type: PlanRepositoryErrorType.noInternet,
        statusCode: statusCode,
        serverMessage: serverMessage,
        debugMessage: responseBody,
      );
    }

    if (statusCode == 408) {
      return PlanRepositoryException(
        type: PlanRepositoryErrorType.timeout,
        statusCode: statusCode,
        serverMessage: serverMessage,
        debugMessage: responseBody,
      );
    }

    if (statusCode == 401) {
      return PlanRepositoryException(
        type: PlanRepositoryErrorType.unauthorized,
        statusCode: statusCode,
        serverMessage: serverMessage,
        debugMessage: responseBody,
      );
    }

    if (statusCode == 403) {
      return PlanRepositoryException(
        type: PlanRepositoryErrorType.forbidden,
        statusCode: statusCode,
        serverMessage: serverMessage,
        debugMessage: responseBody,
      );
    }

    if (statusCode == 404) {
      return PlanRepositoryException(
        type: PlanRepositoryErrorType.notFound,
        statusCode: statusCode,
        serverMessage: serverMessage,
        debugMessage: responseBody,
      );
    }

    if (statusCode >= 500) {
      return PlanRepositoryException(
        type: PlanRepositoryErrorType.server,
        statusCode: statusCode,
        serverMessage: serverMessage,
        debugMessage: responseBody,
      );
    }

    if (statusCode >= 400) {
      return PlanRepositoryException(
        type: PlanRepositoryErrorType.badResponse,
        statusCode: statusCode,
        serverMessage: serverMessage,
        debugMessage: responseBody,
      );
    }

    return PlanRepositoryException(
      type: PlanRepositoryErrorType.unknown,
      statusCode: statusCode,
      serverMessage: serverMessage,
      debugMessage: responseBody,
    );
  }

  /// Tries to extract backend message text from JSON/primitive response body.
  String? _tryExtractServerMessage(String responseBody) {
    if (responseBody.trim().isEmpty) return null;

    try {
      final dynamic decoded = jsonDecode(responseBody);

      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }

      if (decoded is Map) {
        final List<String> keysToCheck = <String>[
          'message',
          'error',
          'errorMessage',
          'detail',
          'title',
        ];
        for (final String key in keysToCheck) {
          final dynamic value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
    } catch (_) {
      // Response is not JSON, fallback below.
    }

    final String trimmed = responseBody.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Logs daily filter summary and per-plan bucket details.
  void _logDailyFilterResult({
    required int totalRawPlansCount,
    required int matchedRawPlansCount,
    required List<DailyPlanModel> dailyPlans,
  }) {
    if (!kDebugMode) return;

    debugPrint(
      'daily-filter: total=$totalRawPlansCount, '
      'matchedRaw=$matchedRawPlansCount, '
      'parsedDaily=${dailyPlans.length}, '
      'rule=(PlanType=P && Frequency=D)',
    );

    if (dailyPlans.isEmpty) {
      debugPrint('daily-filter: no plan matched.');
      return;
    }

    for (final DailyPlanModel plan in dailyPlans) {
      debugPrint(
        'daily-plan: id=${plan.planId}, '
        'name=${plan.planName}, '
        'amount=${plan.planAmount.toStringAsFixed(2)}, '
        'group=${plan.planGroup}, '
        'sort=${plan.planSortOrder}, '
        'buckets=${plan.planBuckets.length}',
      );

      for (final DailyPlanBucketModel bucket in plan.planBuckets) {
        debugPrint(
          '  bucket: name=${bucket.name}, '
          'amount=${bucket.amount}, '
          'unit=${bucket.unit}, '
          'bucketUnit=${bucket.bucketUnit}, '
          'unlimited=${bucket.unlimited}',
        );
      }
    }
  }

  /// Logs weekly filter summary and per-plan bucket details.
  void _logWeeklyFilterResult({
    required int totalRawPlansCount,
    required int matchedRawPlansCount,
    required List<WeeklyPlanModel> weeklyPlans,
  }) {
    if (!kDebugMode) return;

    debugPrint(
      'weekly-filter: total=$totalRawPlansCount, '
      'matchedRaw=$matchedRawPlansCount, '
      'parsedWeekly=${weeklyPlans.length}, '
      'rule=(PlanType=P && Frequency=W)',
    );

    if (weeklyPlans.isEmpty) {
      debugPrint('weekly-filter: no plan matched.');
      return;
    }

    for (final WeeklyPlanModel plan in weeklyPlans) {
      debugPrint(
        'weekly-plan: id=${plan.planId}, '
        'name=${plan.planName}, '
        'amount=${plan.planAmount.toStringAsFixed(2)}, '
        'group=${plan.planGroup}, '
        'sort=${plan.planSortOrder}, '
        'buckets=${plan.planBuckets.length}',
      );

      for (final WeeklyPlanBucketModel bucket in plan.planBuckets) {
        debugPrint(
          '  bucket: name=${bucket.name}, '
          'amount=${bucket.amount}, '
          'unit=${bucket.unit}, '
          'bucketUnit=${bucket.bucketUnit}, '
          'unlimited=${bucket.unlimited}',
        );
      }
    }
  }

  /// Logs monthly filter summary and per-plan bucket details.
  void _logMonthlyFilterResult({
    required int totalRawPlansCount,
    required int matchedRawPlansCount,
    required List<MonthlyPlanModel> monthlyPlans,
  }) {
    if (!kDebugMode) return;

    debugPrint(
      'monthly-filter: total=$totalRawPlansCount, '
      'matchedRaw=$matchedRawPlansCount, '
      'parsedMonthly=${monthlyPlans.length}, '
      'rule=(PlanType=P && Frequency=M)',
    );

    if (monthlyPlans.isEmpty) {
      debugPrint('monthly-filter: no plan matched.');
      return;
    }

    for (final MonthlyPlanModel plan in monthlyPlans) {
      debugPrint(
        'monthly-plan: id=${plan.planId}, '
        'name=${plan.planName}, '
        'amount=${plan.planAmount.toStringAsFixed(2)}, '
        'group=${plan.planGroup}, '
        'sort=${plan.planSortOrder}, '
        'buckets=${plan.planBuckets.length}',
      );

      for (final MonthlyPlanBucketModel bucket in plan.planBuckets) {
        debugPrint(
          '  bucket: name=${bucket.name}, '
          'amount=${bucket.amount}, '
          'unit=${bucket.unit}, '
          'bucketUnit=${bucket.bucketUnit}, '
          'unlimited=${bucket.unlimited}',
        );
      }
    }
  }

  /// Prints large text in chunks to avoid console truncation.
  void _debugPrintChunked(String text, {required String header}) {
    if (!kDebugMode) return;

    const int chunkSize = 900;
    debugPrint('$header: length=${text.length}');

    for (int i = 0; i < text.length; i += chunkSize) {
      final int end =
          (i + chunkSize < text.length) ? i + chunkSize : text.length;
      debugPrint(text.substring(i, end));
    }
  }

  Future<List<HomePlanModel>> fetchPlans({required HomePlanTab tab}) async {
    await Future.delayed(const Duration(milliseconds: 450));

    switch (tab) {
      case HomePlanTab.daily:
        return const [
          HomePlanModel(
            id: 'd1',
            title: 'freedom5',
            subtitle: '1 day',
            price: 5.00,
            description: 'A simple daily plan for quick usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '2',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: '30',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: '30',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText, //.mms,
                label: 'us/can text',
                value: '300',
                sub: 'int’l text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms, //.mms,
                label: 'int\'l us/can talk',
                value: '30',
                sub: 'int’l talk',
              ),
            ],
          ),
          // HomePlanModel(
          //   id: 'd2',
          //   title: 'freedom 5',
          //   subtitle: '1 day',
          //   price: 20.00,
          //   description: 'Higher daily bundle for heavier usage.',
          //   benefits: [
          //     HomePlanBenefit(
          //         type: HomePlanBenefitType.data,
          //         label: 'data',
          //         value: '2',
          //         sub: 'GB'),
          //     HomePlanBenefit(
          //         type: HomePlanBenefitType.talkMins,
          //         label: 'talk mins',
          //         value: '20',
          //         sub: 'local talk mins'),
          //     HomePlanBenefit(
          //         type: HomePlanBenefitType.sms,
          //         label: 'sms',
          //         value: '20',
          //         sub: 'local text'
          //     ),
          //   ],
          // ),
          // HomePlanModel(
          //   id: 'd3',
          //   title: 'freedom 5',
          //   subtitle: '1 day',
          //   price: 30.00,
          //   description: 'Premium daily option for maximum value.',
          //   benefits: [
          //     HomePlanBenefit(
          //         type: HomePlanBenefitType.data,
          //         label: 'data',
          //         value: '5',
          //         sub: 'GB'),
          //     HomePlanBenefit(
          //         type: HomePlanBenefitType.talkMins,
          //         label: 'talk mins',
          //         value: '50',
          //         sub: 'local talk mins'),
          //     HomePlanBenefit(
          //         type: HomePlanBenefitType.sms,
          //         label: 'sms',
          //         value: '50',
          //         sub: 'local text'),
          //   ],
          // ),
        ];

      case HomePlanTab.weekly:
        return const [
          // ✅ weekly card screenshot অনুযায়ী: unlimited talk + unlimited sms
          HomePlanModel(
            id: 'w1',
            title: 'freedom8',
            subtitle: '7 day',
            price: 8.00,
            description: 'Weekly plan with unlimited local talk and text.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '1',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText, //.mms,
                label: 'us/can text',
                value: '300',
                sub: 'int’l text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms, //.mms,
                label: 'int\'l us/can talk',
                value: '30',
                sub: 'int’l talk',
              ),
            ],
          ),
          HomePlanModel(
            id: 'w2',
            title: 'freedom15',
            subtitle: '7 day',
            price: 15.00,
            description: 'Weekly plan with unlimited local talk and text.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '3',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText, //.mms,
                label: 'us/can text',
                value: '300',
                sub: 'int’l text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms, //.mms,
                label: 'int\'l us/can talk',
                value: '30',
                sub: 'int’l talk',
              ),
            ],
          ),
          HomePlanModel(
            id: 'w3',
            title: 'freedom45',
            subtitle: '7 day',
            price: 45.00,
            description: 'Weekly plan with unlimited local talk and text.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: 'unlimited',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText, //.mms,
                label: 'us/can text',
                value: '300',
                sub: 'int’l text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms, //.mms,
                label: 'int\'l us/can talk',
                value: '30',
                sub: 'int’l talk',
              ),
            ],
          ),
        ];

      case HomePlanTab.monthly:
        return const [
          HomePlanModel(
            id: 'm1',
            title: 'liberty40',
            subtitle: '30 days',
            price: 40.00,
            description:
                'The ALIV Freedom 6 Plan provides users with unlimited talk and text within the Bahamas...',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '5',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),

              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText, //.mms,
                label: 'us/can text',
                value: '300',
                sub: 'int’l text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms, //.mms,
                label: 'int\'l us/can talk',
                value: '30',
                sub: 'int’l talk',
              ),
              // HomePlanBenefit(
              //     type: HomePlanBenefitType.bonusData,
              //     label: 'bonus data',
              //     value: '5',
              //     sub: 'gb'),
              // HomePlanBenefit(
              //     type: HomePlanBenefitType.intlTalkText,
              //     label: "us/can text",
              //     value: '300',
              //     sub: 'sms text'),
              // HomePlanBenefit(
              //     type: HomePlanBenefitType.mms,
              //     label: 'mms',
              //     value: '0',
              //     sub: 'ALIV to ALIV'),
            ],
          ),
          HomePlanModel(
            id: 'm2',
            title: 'liberty70',
            subtitle: '30 days',
            price: 70.00,
            description: 'Monthly plan with extended value.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '14',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText, //.mms,
                label: 'us/can text',
                value: '300',
                sub: 'int’l text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms, //.mms,
                label: 'int\'l us/can talk',
                value: '30',
                sub: 'int’l talk',
              ),
              /*
              HomePlanBenefit(
                  type: HomePlanBenefitType.bonusData,
                  label: 'bonus data',
                  value: '5',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.intlTalkText,
                  label: "int'l talk & text",
                  value: '300',
                  sub: 'sms text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.mms,
                  label: 'mms',
                  value: '0',
                  sub: 'ALIV to ALIV'
              ),
            */
            ],
          ),
          HomePlanModel(
            id: 'm3',
            title: 'liberty120',
            subtitle: '30 days',
            price: 120.00,
            description: 'Premium monthly option for heavy usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: 'unlimited',
                sub: 'gb',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.talkMins,
                label: 'talk mins',
                value: 'unlimited',
                sub: 'local talk mins',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.sms,
                label: 'sms',
                value: 'unlimited',
                sub: 'local text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.bonusData,
                label: 'bonus data',
                value: 'unlimited',
                sub: 'whatsApp messaging',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.intlTalkText, //.mms,
                label: 'us/can text',
                value: '300',
                sub: 'int’l text',
              ),
              HomePlanBenefit(
                type: HomePlanBenefitType.mms, //.mms,
                label: 'int\'l us/can talk',
                value: '30',
                sub: 'int’l talk',
              ),
              /*
              HomePlanBenefit(
                  type: HomePlanBenefitType.bonusData,
                  label: 'bonus data',
                  value: '5',
                  sub: 'gb'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.intlTalkText,
                  label: "int'l talk & text",
                  value: '300',
                  sub: 'sms text'),
              HomePlanBenefit(
                  type: HomePlanBenefitType.mms,
                  label: 'mms',
                  value: '0',
                  sub: 'ALIV to ALIV'),
              */
            ],
          ),
        ];

      case HomePlanTab.roaming:
        return const [
          // ✅ roaming card: center metric usually data (you made roaming card separately)
          HomePlanModel(
            id: 'r1',
            title: 'roam20',
            subtitle: '7 days',
            price: 20.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '0.25',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 'r2',
            title: 'roam30',
            subtitle: '7 days',
            price: 30.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '0.5',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 'r3',
            title: 'roam50',
            subtitle: '14 days',
            price: 50.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '1',
                sub: 'gb',
              ),
            ],
          ),
          /*
          HomePlanModel(
            id: 'r4',
            title: 'roam 20',
            subtitle: '7 days',
            price: 20.00,
            description: 'Roaming plan for travel usage.',
            benefits: [
              HomePlanBenefit(
                  type: HomePlanBenefitType.data,
                  label: 'data',
                  value: '0.25',
                  sub: 'gb'),
            ],
          ),*/
        ];

      case HomePlanTab.roameasy:
        return const [
          // ✅ roameasy same like roaming
          HomePlanModel(
            id: 're1',
            title: 'roameasy carib',
            subtitle: '7 days',
            price: 25.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '1.5',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 're2',
            title: 'roameasy usa & can',
            subtitle: '7 days',
            price: 25.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '2',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 're3',
            title: 'roameasy europe',
            subtitle: '7 days',
            price: 30.00,
            description: 'Easy roaming pack for short trips.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '1',
                sub: 'gb',
              ),
            ],
          ),
        ];

      case HomePlanTab.mifi:
        return const [
          // ✅ mifi card: center metric = data
          HomePlanModel(
            id: 'mi1',
            title: 'mifi75',
            subtitle: '30 days',
            price: 75.00,
            description: 'MiFi data plan for hotspot usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '50',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 'mi2',
            title: 'mifi90',
            subtitle: '30 days',
            price: 125.00,
            description: 'MiFi data plan for hotspot usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '125',
                sub: 'gb',
              ),
            ],
          ),
          HomePlanModel(
            id: 'mi3',
            title: 'mifi140',
            subtitle: '30 days',
            price: 140.00,
            description: 'MiFi data plan for hotspot usage.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.data,
                label: 'data',
                value: '200',
                sub: 'gb',
              ),
            ],
          ),
        ];

      case HomePlanTab.libertyGlobal:
        return [
          // ✅ liberty global card: center metric = intl talk
          HomePlanModel(
            id: 'lg1',
            title: 'liberty global haiti',
            subtitle: '365 days',
            price: 10.00,
            description: 'International talk plan for Liberty Global.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l talk",
                value: '30',
                sub: 'talk mins',
              ),
            ],
          ),
          //liberty global caribbean
          HomePlanModel(
            id: 'lg2',
            title: 'liberty global caribbean',
            subtitle: '365 days',
            price: 21.00,
            description: 'International talk plan for Liberty Global.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l talk",
                value: '50',
                sub: 'talk mins',
              ),
            ],
          ),
          HomePlanModel(
            id: 'lg3',
            title: 'liberty global china',
            subtitle: '365 days',
            price: 21.00,
            description: 'International talk plan for Liberty Global.',
            benefits: [
              HomePlanBenefit(
                type: HomePlanBenefitType.mms,
                label: "int'l talk",
                value: '250',
                sub: 'talk mins',
              ),
            ],
          ),
        ];

      case HomePlanTab.addOns:
        // ✅ AddOns tab এর জন্য plans না, addons আলাদা model হওয়া উচিত
        // তাই এখানে empty list return করছি (screen addOns হলে fetchAddOns() call করবে)
        return const [];
    }
  }

  // ✅ AddOns tab data (separate model for checkbox selection)
  Future<List<HomePlanAddOnModel>> fetchAddOns() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return const [
      HomePlanAddOnModel(
        id: 'a1',
        title: 'liberty data 1',
        label: 'data balance',
        value: '1gb',
        price: 5.00,
      ),
      HomePlanAddOnModel(
        id: 'a2',
        title: 'liberty data 2',
        label: 'data balance',
        value: '2gb',
        price: 10.00,
      ),
      HomePlanAddOnModel(
        id: 'a3',
        title: 'liberty data 3',
        label: 'data balance',
        value: '3gb',
        price: 16.00,
      ),
    ];
  }
}

/*
JSON decode/parse is still on main isolate (can cause jank on slower phones).
Daily tab still re-hits API each visit (fresh, but not fastest UX).
No refresh strategy policy yet (TTL / stale-while-revalidate / manual pull-to-refresh).
 */
