import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

/// Primary plan families whose `AvailableBoltOns` surface on the add-ons tab.
/// Mirrors the web rule — plans outside these families show no add-ons.
const Set<String> addOnPlanFamilies = <String>{'freedom', 'liberty'};

/// Bolt-on name suffixes that may appear on the add-ons tab. Any bolt-on whose
/// normalized name does not end with one of these is filtered out.
const Set<String> allowedBoltOnSuffixes = <String>{
  'data10',
  'data3',
  'data2',
  'data1',
  'talk100',
  'text100',
};

String _normalize(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'\s+'), '');

bool isAddOnEligiblePrimaryName(String planName) {
  final normalized = _normalize(planName);
  return addOnPlanFamilies.any(normalized.startsWith);
}

bool isAllowedBoltOnName(String planName) {
  final normalized = _normalize(planName);
  return allowedBoltOnSuffixes.any(normalized.endsWith);
}

/// Picks the earliest-start primary plan whose name belongs to an add-on
/// eligible family. Returns `null` when none of the plans qualify.
///
/// The incoming list is assumed to already be sorted by earliest start date
/// (as produced by `BundleResponseParser._sortByEarliestStartDate`), so this
/// simply picks the first match.
BasePlanModel? firstAddOnEligiblePrimary(
  List<BasePlanModel> sortedPrimaryPlans,
) {
  for (final plan in sortedPrimaryPlans) {
    if (isAddOnEligiblePrimaryName(plan.planName)) return plan;
  }
  return null;
}
