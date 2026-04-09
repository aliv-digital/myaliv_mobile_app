import '../models/home_plans_postpaid_plan_model.dart';

abstract class BaseHomePlansPostPaidRepository {
  Future<List<Map<String, dynamic>>> getPlans({
    bool printRawResponse = false,
  });

  Future<List<HomePlansPostPaidPlanModel>> fetchPlansFromApi({
    bool printRawResponse = false,
  });

  List<Map<String, dynamic>> get lastFetchedPlans;

  DateTime? get lastFetchedAt;

  List<HomePlansPostPaidPlanModel> get lastFetchedApiPlans;

  DateTime? get lastFetchedApiAt;
}
