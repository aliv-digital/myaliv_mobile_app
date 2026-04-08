import 'package:core/core.dart';

import '../models/home_plans_postpaid_plan_model.dart';
import 'base_home_plans_postpaid_repository.dart';
import 'services/home_plans_postpaid_api_client.dart';
import 'services/home_plans_postpaid_cache.dart';
import 'services/home_plans_postpaid_json_parser.dart';

class HomePlansPostPaidRepository implements BaseHomePlansPostPaidRepository {
  HomePlansPostPaidRepository({
    NetworkService? networkService,
    AuthManager? authManager,
    HomePlansPostPaidCache? cache,
    HomePlansPostPaidApiClient? apiClient,
    HomePlansPostPaidJsonParser? jsonParser,
  })  : _cache = cache ?? HomePlansPostPaidCache(),
        _apiClient = apiClient ??
            HomePlansPostPaidApiClient(
              networkService: networkService,
              authManager: authManager,
            ),
        _jsonParser = jsonParser ?? HomePlansPostPaidJsonParser();

  final HomePlansPostPaidCache _cache;
  final HomePlansPostPaidApiClient _apiClient;
  final HomePlansPostPaidJsonParser _jsonParser;

  @override
  Future<List<Map<String, dynamic>>> getPlans({
    bool printRawResponse = false,
  }) async {
    final rawJson = await _apiClient.fetchRawPlansJson();
    final plans = await _jsonParser.parse(rawJson);

    _cache.setRawPlans(plans);
    return plans;
  }

  @override
  Future<List<HomePlansPostPaidPlanModel>> fetchPlansFromApi({
    bool printRawResponse = false,
  }) async {
    final plans = await _ensureCacheLoaded();

    final models = plans
        .map(
          (map) => HomePlansPostPaidPlanModel.fromApiMap(
            map,
            includeRawPayload: false,
          ),
        )
        .toList(growable: false);

    _cache.setApiPlans(models);
    return models;
  }

  @override
  List<Map<String, dynamic>> get lastFetchedPlans =>
      List.unmodifiable(_cache.getRawPlans());

  @override
  DateTime? get lastFetchedAt => _cache.getRawPlansTimestamp();

  @override
  List<HomePlansPostPaidPlanModel> get lastFetchedApiPlans =>
      List.unmodifiable(_cache.getApiPlans());

  @override
  DateTime? get lastFetchedApiAt => _cache.getApiPlansTimestamp();

  Future<List<Map<String, dynamic>>> _ensureCacheLoaded() async {
    if (_cache.hasRawPlans()) {
      return _cache.getRawPlans();
    }

    return getPlans();
  }
}
