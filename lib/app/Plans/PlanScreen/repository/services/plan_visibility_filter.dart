import '../../models/base_plan_model.dart';

/// Shared catalogue exclusions used by authenticated and guest plan lists.
///
/// These names reflect products that the current tab-based UI does not expose.
/// Keeping the rule in one place prevents the two catalogues from drifting.
class PlanVisibilityFilter {
  const PlanVisibilityFilter._();

  static const List<String> _excludedPlanNames = <String>[
    '3gb bonus roaming data us/can',
    '1.5gb bonus roaming data us/can',
    '750mb bonus roaming data',
    'bmp 1-day',
    'bmp 7-day',
    'bmp 30-day',
    'liberty bonus data2',
    'freedom bonus data5',
    'freedom35 bonus data5',
    'freedom4 bonus data2',
    'junkanoo5',
    'test',
  ];

  static bool isVisibleName(String planName) {
    final normalizedName = planName.trim().toLowerCase();
    return !_excludedPlanNames.any(normalizedName.contains);
  }

  static List<BasePlanModel> visibleBasePlans(List<BasePlanModel> plans) {
    return plans
        .where((plan) => isVisibleName(plan.planName))
        .toList(growable: false);
  }
}
