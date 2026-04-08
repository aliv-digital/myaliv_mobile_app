import '../../models/home_plans_postpaid_plan_model.dart';

class HomePlansPostPaidCache {
  List<Map<String, dynamic>> _rawPlans = <Map<String, dynamic>>[];
  DateTime? _rawPlansTimestamp;

  List<HomePlansPostPaidPlanModel> _apiPlans = <HomePlansPostPaidPlanModel>[];
  DateTime? _apiPlansTimestamp;

  void setRawPlans(List<Map<String, dynamic>> plans) {
    _rawPlans = plans;
    _rawPlansTimestamp = DateTime.now();
  }

  List<Map<String, dynamic>> getRawPlans() => _rawPlans;

  DateTime? getRawPlansTimestamp() => _rawPlansTimestamp;

  bool hasRawPlans() => _rawPlans.isNotEmpty;

  void setApiPlans(List<HomePlansPostPaidPlanModel> plans) {
    _apiPlans = plans;
    _apiPlansTimestamp = DateTime.now();
  }

  List<HomePlansPostPaidPlanModel> getApiPlans() => _apiPlans;

  DateTime? getApiPlansTimestamp() => _apiPlansTimestamp;
}
