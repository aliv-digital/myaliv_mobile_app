import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/networkService/api_paths.dart';
import '../../../../core/networkService/app_http_client.dart';
import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/daily_plan_model.dart';

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
  return item.map((
      dynamic key,
      dynamic value) => MapEntry<String, dynamic>(key.toString(), value),
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
  final dynamic decoded;
  try {
    decoded = jsonDecode(rawBody);
  } catch (_) {
    return const <Map<String, dynamic>>[];
  }

  if (decoded is! List) {
    return const <Map<String, dynamic>>[];
  }

  return decoded.whereType<Map>().map(_toStringKeyedMapInBackground).toList(growable: false);
}

/// Background worker:
/// Decodes raw JSON and returns only strict Daily plans.
///
/// Return payload shape:
/// - `totalRawPlansCount`: number of normalized plan maps
/// - `matchedRawPlans`: strict daily raw plan maps (PlanType=P, Frequency=D)
Map<String, dynamic> _decodeAndFilterStrictDailyPlansInBackground(
  String rawBody,
) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(rawBody);
  } catch (_) {
    return <String, dynamic>{
      'totalRawPlansCount': 0,
      'matchedRawPlans': const <Map<String, dynamic>>[],
    };
  }

  if (decoded is! List) {
    return <String, dynamic>{
      'totalRawPlansCount': 0,
      'matchedRawPlans': const <Map<String, dynamic>>[],
    };
  }

  int totalRawPlansCount = 0;
  final List<Map<String, dynamic>> matchedRawPlans = <Map<String, dynamic>>[];

  for (final dynamic item in decoded) {
    if (item is! Map) continue;

    final Map<String, dynamic> normalizedPlan = _toStringKeyedMapInBackground(item);
    totalRawPlansCount++;

    final String planType = _normalizedUpperInBackground(normalizedPlan['PlanType']);
    final String frequency = _normalizedUpperInBackground(normalizedPlan['Frequency']);

    if (planType == 'P' && frequency == 'D') {
      matchedRawPlans.add(normalizedPlan);
    }
  }

  return <String, dynamic>{
    'totalRawPlansCount': totalRawPlansCount,
    'matchedRawPlans': matchedRawPlans,
  };
}

// /v1/MyAliv/device/{{deviceAccountId}}/available-plans
class HomePlanRepository {
  HomePlanRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

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
    final String? rawResponseBody = await _fetchPlansRawResponseBody(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
    );
    if (rawResponseBody == null) return const <Map<String, dynamic>>[];

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
      return const <Map<String, dynamic>>[];
    }

    if (plans.isEmpty) return const <Map<String, dynamic>>[];

    _lastFetchedPlans = plans;
    _lastFetchedAt = DateTime.now();

    if (kDebugMode) {
      debugPrint(
        'getPlans: decoded plans=${plans.length}, cachedAt=$_lastFetchedAt',
      );
    }

    return plans;
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
    // Fetch full plans JSON response body.
    final String? rawResponseBody = await _fetchPlansRawResponseBody(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      printRawResponse: printRawResponse,
    );
    if (rawResponseBody == null) return const <DailyPlanModel>[];

    // Step-2 (optimization):
    // Decode + strict-daily filter in the same background isolate.
    // This returns only matched daily maps to the main isolate.
    final Map<String, dynamic> dailyRawResult;
    try {
      dailyRawResult = await compute(
        _decodeAndFilterStrictDailyPlansInBackground,
        rawResponseBody,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'fetchDailyPlansFromApi: background decode/filter failed: $e');
      }
      return const <DailyPlanModel>[];
    }

    final int totalRawPlansCount = _asNonNegativeInt(
      dailyRawResult['totalRawPlansCount'],
    );
    final List<Map<String, dynamic>> strictDailyRawPlans = _asMapList(
      dailyRawResult['matchedRawPlans'],
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

  /// Read-only view of latest raw payload cache.
  List<Map<String, dynamic>> get lastFetchedPlans =>
      List<Map<String, dynamic>>.unmodifiable(_lastFetchedPlans);

  /// Read-only view of latest payload fetch time.
  DateTime? get lastFetchedAt => _lastFetchedAt;

  /// Read-only latest strict daily plans cache.
  List<DailyPlanModel> get lastFetchedDailyPlans =>
      List<DailyPlanModel>.unmodifiable(_lastFetchedDailyPlans);

  /// Read-only latest strict daily filter timestamp.
  DateTime? get lastFetchedDailyAt => _lastFetchedDailyAt;

  /// Builds Basic Auth token from username/password pair.
  String _buildBasicAuthToken(
      {required String username, required String password}) {
    final String credentials = '$username:$password';
    return base64Encode(utf8.encode(credentials));
  }

  /// Shared API call for available plans.
  ///
  /// Returns raw JSON response body on success, otherwise `null`.
  Future<String?> _fetchPlansRawResponseBody({
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
      return null;
    }

    if (kDebugMode && printRawResponse) {
      _debugPrintChunked(
        response.responseJson,
        header: 'plans-api raw response',
      );
    }

    return response.responseJson;
  }

  /// Converts dynamic value to non-negative int.
  int _asNonNegativeInt(dynamic value) {
    final int parsed;
    if (value is int) {
      parsed = value;
    } else if (value is num) {
      parsed = value.toInt();
    } else {
      parsed = int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return parsed < 0 ? 0 : parsed;
  }

  /// Converts dynamic value to list of string-keyed maps safely.
  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];

    return value
        .whereType<Map>()
        .map(_toStringKeyedMapInBackground)
        .toList(growable: false);
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
