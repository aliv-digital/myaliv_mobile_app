import 'package:myaliv_mobile_app/app/Plans/shared/repository/services/base_plan_cache.dart';
import '../../models/home_plans_postpaid_plan_model.dart';

/// Manages in-memory cache for postpaid plan data.
///
/// Extends BasePlanCache to inherit raw plans caching.
/// Adds caching for typed postpaid plan models.
class HomePlansPostPaidCache extends BasePlanCache {
  final CacheEntry<List<HomePlansPostPaidPlanModel>> _apiPlansCache =
      CacheEntry();

  void setApiPlans(List<HomePlansPostPaidPlanModel> plans) =>
      _apiPlansCache.set(plans);

  List<HomePlansPostPaidPlanModel> getApiPlans() =>
      _apiPlansCache.get() ?? [];

  DateTime? getApiPlansTimestamp() => _apiPlansCache.getTimestamp();

  @override
  void clearAll() {
    super.clearAll(); // Clear raw plans cache from base class
    _apiPlansCache.clear();
  }
}
