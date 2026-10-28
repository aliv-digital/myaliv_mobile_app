import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';

/// Resolve which Plans tab a reward's SUGName points at by matching the
/// SUGName against the plan names already loaded in [state]. Returns `null`
/// when no plan name is a substring of the normalized SUGName.
///
/// Matching is case-insensitive and whitespace-insensitive, so SUG
/// `"liberty data 1 .99"` matches plan `"liberty data1 .99"`.
///
/// Longer plan names win over shorter ones so `Liberty120` beats `Liberty12`
/// when both are present in the catalogue.
HomePlanTab? resolveTabForRewardSug(String sugName, PlansState state) {
  final sug = _normalize(sugName);
  if (sug.isEmpty) return null;

  final candidates = <_Candidate>[];
  void collect(HomePlanTab tab, Iterable<String> names) {
    for (final name in names) {
      final normalized = _normalize(name);
      if (normalized.isEmpty) continue;
      candidates.add(_Candidate(tab: tab, name: normalized));
    }
  }

  collect(HomePlanTab.daily, state.dailyApiPlans.map((p) => p.planName));
  collect(HomePlanTab.weekly, state.weeklyApiPlans.map((p) => p.planName));
  collect(HomePlanTab.monthly, state.monthlyApiPlans.map((p) => p.planName));
  collect(HomePlanTab.roaming, state.roamingApiPlans.map((p) => p.planName));
  collect(HomePlanTab.roameasy, state.roamEasyApiPlans.map((p) => p.planName));
  collect(HomePlanTab.mifi, state.mifiApiPlans.map((p) => p.planName));
  collect(
    HomePlanTab.libertyGlobal,
    state.libertyGlobalApiPlans.map((p) => p.planName),
  );
  collect(
    HomePlanTab.postpaidRoaming,
    state.postpaidRoamingApiPlans.map((p) => p.planName),
  );

  candidates.sort((a, b) => b.name.length.compareTo(a.name.length));

  for (final c in candidates) {
    if (sug.contains(c.name)) return c.tab;
  }
  return null;
}

String _normalize(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'\s+'), '');

class _Candidate {
  const _Candidate({required this.tab, required this.name});
  final HomePlanTab tab;
  final String name;
}
