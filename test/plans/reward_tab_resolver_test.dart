import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/logic/reward_tab_resolver.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';

void main() {
  group('resolveTabForRewardSug', () {
    test(
      'returns monthly tab for SUGName referencing a monthly plan',
      () {
        final state = PlansState(
          monthlyApiPlans: [_plan('Liberty40')],
          weeklyApiPlans: [_plan('Freedom15')],
        );

        final tab = resolveTabForRewardSug(
          r'$10 off Liberty40 for 1 month',
          state,
        );

        expect(tab, HomePlanTab.monthly);
      },
    );

    test(
      'returns weekly tab for SUGName referencing a weekly plan',
      () {
        final state = PlansState(
          monthlyApiPlans: [_plan('Liberty40')],
          weeklyApiPlans: [_plan('Freedom15')],
        );

        final tab = resolveTabForRewardSug(
          r'$3 off Freedom15 for 2 weeks',
          state,
        );

        expect(tab, HomePlanTab.weekly);
      },
    );

    test('longer plan name wins over shorter prefix match', () {
      final state = PlansState(
        monthlyApiPlans: [_plan('Liberty12'), _plan('Liberty120')],
        weeklyApiPlans: [_plan('Liberty12')],
      );

      final tab = resolveTabForRewardSug(
        r'$5 off Liberty120 for 1 month',
        state,
      );

      expect(tab, HomePlanTab.monthly);
    });

    test('is case-insensitive', () {
      final state = PlansState(monthlyApiPlans: [_plan('Liberty40')]);

      final tab = resolveTabForRewardSug(
        r'$10 OFF LIBERTY40 FOR 1 MONTH',
        state,
      );

      expect(tab, HomePlanTab.monthly);
    });

    test('returns null when no plan name is a substring', () {
      final state = PlansState(monthlyApiPlans: [_plan('Liberty40')]);

      final tab = resolveTabForRewardSug(
        r'$5 off Freedom15 for 2 weeks',
        state,
      );

      expect(tab, isNull);
    });

    test('returns null when state has no loaded plans', () {
      const state = PlansState();

      final tab = resolveTabForRewardSug(
        r'$10 off Liberty40 for 1 month',
        state,
      );

      expect(tab, isNull);
    });

    test('returns null for empty sugName', () {
      final state = PlansState(monthlyApiPlans: [_plan('Liberty40')]);

      final tab = resolveTabForRewardSug('', state);

      expect(tab, isNull);
    });

    test('ignores plans with blank planName', () {
      final state = PlansState(monthlyApiPlans: [_plan('')]);

      final tab = resolveTabForRewardSug('anything at all', state);

      expect(tab, isNull);
    });

    test(
      'is whitespace-insensitive — "liberty data 1" matches plan "liberty data1"',
      () {
        final state = PlansState(monthlyApiPlans: [_plan('liberty data1')]);

        final tab = resolveTabForRewardSug(
          r'$5 off liberty data 1 .99',
          state,
        );

        expect(tab, HomePlanTab.monthly);
      },
    );

    test(
      'whitespace-insensitive match tolerates spaces in SUG and plan both',
      () {
        final state = PlansState(monthlyApiPlans: [_plan('Liberty 40')]);

        final tab = resolveTabForRewardSug(
          r'$10 off Liberty40 for 1 month',
          state,
        );

        expect(tab, HomePlanTab.monthly);
      },
    );
  });

  group('resolveTabForRewardSug — real /available-sugs dataset', () {
    // Available-plans catalogue inferred from the SUGName corpus.
    final catalogue = PlansState(
      monthlyApiPlans: [
        _plan('Liberty40'),
        _plan('Liberty46'),
        _plan('Liberty60'),
        _plan('Liberty70'),
        _plan('Liberty120'),
      ],
      weeklyApiPlans: [
        _plan('Freedom4'),
        _plan('Freedom8'),
        _plan('Freedom14'),
        _plan('Freedom15'),
        _plan('Freedom16'),
        _plan('Freedom45'),
      ],
      mifiApiPlans: [_plan('mifi90'), _plan('mifi140')],
      roamEasyApiPlans: [_plan('roameasy carib')],
    );

    final cases = <String, HomePlanTab?>{
      // Monthly (Liberty-family) rewards
      r'$10 off Liberty40 for 1 month': HomePlanTab.monthly,
      r'$5 off Liberty40 for 3 months': HomePlanTab.monthly,
      r'liberty40 for $30': HomePlanTab.monthly,
      r'liberty40 for $30 Oct25': HomePlanTab.monthly,
      r'liberty40 for $35': HomePlanTab.monthly,
      r'Liberty40 for $35.00': HomePlanTab.monthly,
      r'Liberty46': HomePlanTab.monthly,
      r'liberty60bundle': HomePlanTab.monthly,
      r'Liberty70 bundle for $110': HomePlanTab.monthly,
      r'Liberty70 Bundle for $150': HomePlanTab.monthly,
      r'liberty70 for $50': HomePlanTab.monthly,
      r'liberty120 for $90': HomePlanTab.monthly,
      'liberty120 for 115': HomePlanTab.monthly,
      'Port In- Liberty40 Bundle': HomePlanTab.monthly,
      // Weekly (Freedom-family) rewards
      r'$2 off Freedom8 for 4 weeks': HomePlanTab.weekly,
      r'$3 off Freedom15 for 2 weeks': HomePlanTab.weekly,
      r'$3 off Freedom15 for 4 weeks': HomePlanTab.weekly,
      'Freedom14': HomePlanTab.weekly,
      r'freedom15 for $12': HomePlanTab.weekly,
      'freedom15 for 12 September 2025': HomePlanTab.weekly,
      'Freedom16': HomePlanTab.weekly,
      'Freedom4 Bogo': HomePlanTab.weekly,
      'freedom4 data 1 .99': HomePlanTab.weekly,
      r'freedom45 for $35': HomePlanTab.weekly,
      r'Freedom45 for $40': HomePlanTab.weekly,
      'freedom45 for 40': HomePlanTab.weekly,
      'freedom8 for 6 September 2025': HomePlanTab.weekly,
      // MiFi rewards
      r'Bimini mifi140 for $99': HomePlanTab.mifi,
      r'Bimini mifi90 for $80': HomePlanTab.mifi,
      r'mifi140 for $119 Tenure': HomePlanTab.mifi,
      r'mifi140 for $99 Tenure': HomePlanTab.mifi,
      r'mifi90 for $80 Tenure': HomePlanTab.mifi,
      // RoamEasy
      'roameasy carib for 15.00': HomePlanTab.roameasy,
      // No match → default fallback (null returned)
      'CANTO Bahamas': null,
      'freedom data 1 .99': null,
      'junkanoo is aliv': null,
      'liberty data 1 .99': null,
      'Mothers Day Tokens': null,
      'roameasy port in promo': null,
      'test': null,
      'university of the bahamas alumni': null,
    };

    for (final entry in cases.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        expect(resolveTabForRewardSug(entry.key, catalogue), entry.value);
      });
    }
  });

  // Snapshot of /v1/MyAliv/device/{id}/available-plans primary plans
  // (PlanType=P/A) only — add-ons (PlanType=S) are omitted because the
  // categorizer routes them to `addOns`, which the resolver ignores by design.
  //
  // This device's catalogue has NO weekly / daily plans and NO Freedom-family
  // plans. Freedom SUGs correctly resolve to null (→ monthly default) because
  // the weekly tab would be empty and hidden by `_visibleTabs()`.
  group('resolveTabForRewardSug — real /available-plans snapshot', () {
    final catalogue = PlansState(
      monthlyApiPlans: [
        _plan('liberty40 bundle for \$90'),
        _plan('liberty70'),
        _plan('liberty40'),
        _plan('liberty120'),
        _plan('liberty40 for \$30'),
        _plan('liberty jr'),
        _plan('bmp 30-day'),
      ],
      mifiApiPlans: [
        _plan('mifi90'),
        _plan('mifi75'),
        _plan('tab140'),
        _plan('tab90'),
        _plan('tab75'),
        _plan('Mifi25 for \$25'),
      ],
      roamingApiPlans: [_plan('roam50 for \$40')],
    );

    final cases = <String, HomePlanTab?>{
      // Liberty-family rewards resolve to monthly via the actual plan names
      // in the catalogue.
      r'$10 off Liberty40 for 1 month': HomePlanTab.monthly,
      r'$5 off Liberty40 for 3 months': HomePlanTab.monthly,
      r'liberty40 for $30': HomePlanTab.monthly,
      r'liberty40 for $30 Oct25': HomePlanTab.monthly,
      r'liberty40 for $35': HomePlanTab.monthly,
      r'Liberty40 for $35.00': HomePlanTab.monthly,
      r'Liberty70 bundle for $110': HomePlanTab.monthly,
      r'Liberty70 Bundle for $150': HomePlanTab.monthly,
      r'liberty70 for $50': HomePlanTab.monthly,
      r'liberty120 for $90': HomePlanTab.monthly,
      'liberty120 for 115': HomePlanTab.monthly,
      'Port In- Liberty40 Bundle': HomePlanTab.monthly,
      // Rewards referencing plan names that are NOT in this device's catalogue:
      'Liberty46': null, // no Liberty46 primary plan
      'liberty60bundle': null, // no Liberty60 primary plan
      // MiFi rewards — only mifi90 matches; mifi140 is not in catalogue.
      r'Bimini mifi90 for $80': HomePlanTab.mifi,
      r'mifi90 for $80 Tenure': HomePlanTab.mifi,
      r'Bimini mifi140 for $99': null, // no mifi140 primary plan
      r'mifi140 for $119 Tenure': null,
      r'mifi140 for $99 Tenure': null,
      // Freedom-family rewards — this device has zero Freedom plans, so all
      // of these fall through to monthly default (weekly tab would be empty
      // and hidden by _visibleTabs anyway).
      r'$2 off Freedom8 for 4 weeks': null,
      r'$3 off Freedom15 for 2 weeks': null,
      r'$3 off Freedom15 for 4 weeks': null,
      'Freedom14': null,
      r'freedom15 for $12': null,
      'freedom15 for 12 September 2025': null,
      'Freedom16': null,
      'Freedom4 Bogo': null,
      'freedom4 data 1 .99': null,
      r'freedom45 for $35': null,
      r'Freedom45 for $40': null,
      'freedom45 for 40': null,
      'freedom8 for 6 September 2025': null,
      // RoamEasy rewards — catalogue has `roam50 for $40` only; no roameasy
      // plan exists so these fall through.
      'roameasy carib for 15.00': null,
      'roameasy port in promo': null,
      // Spaced vs. unspaced plan-name — SUG "liberty data 1 .99" does NOT
      // substring-match PlanName "liberty data1 .99" (space difference).
      // Documented behaviour; space-insensitive matching could be a future
      // enhancement.
      'liberty data 1 .99': null,
      'freedom data 1 .99': null,
      // Affinity-group / promo SUGs with no plan name reference.
      'CANTO Bahamas': null,
      'junkanoo is aliv': null,
      'Mothers Day Tokens': null,
      'test': null,
      'university of the bahamas alumni': null,
    };

    for (final entry in cases.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        expect(resolveTabForRewardSug(entry.key, catalogue), entry.value);
      });
    }
  });
}

BasePlanModel _plan(String name) =>
    BasePlanModel.fromApiMap({'PlanID': name, 'PlanName': name});
