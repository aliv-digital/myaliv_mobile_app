import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/services/guest_primary_plan_filter_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';

BasePlanModel _plan(String name) => BasePlanModel.fromApiMap({
  'PlanID': name,
  'PlanName': name,
  'PlanType': 'P',
  'PlanAmount': 70,
  'VATAmount': 7,
  'AvailableBoltOns': [
    {'PlanID': 'addon', 'PlanName': 'freedom data1'},
  ],
});

void main() {
  const service = GuestPrimaryPlanFilterService();
  const allowed = {
    PlanCategory.daily: ['freedom5'],
    PlanCategory.weekly: ['freedom45', 'freedom15', 'freedom8'],
    PlanCategory.monthly: ['liberty120', 'liberty70', 'liberty40'],
    PlanCategory.roaming: ['roam50', 'roam30', 'roam20'],
    PlanCategory.roameasy: [
      'roameasy usa & can',
      'roameasy carib',
      'roameasy europe',
    ],
    PlanCategory.libertyGlobal: [
      'liberty global Caribbean',
      'liberty global China',
      'liberty global Europe',
      'liberty global Haiti',
    ],
    PlanCategory.mifi: [
      'mifi140',
      'mifi90',
      'mifi75',
      'tab140',
      'tab90',
      'tab75',
    ],
  };
  for (final entry in allowed.entries) {
    test('${entry.key} shows exactly its listed names', () {
      final source = [
        for (final names in allowed.values)
          for (final name in names) _plan(name),
      ];
      final result = service.filter(source, category: entry.key);
      expect(result.map((plan) => plan.planName), entry.value);
      expect(source, hasLength(23));
    });

    test(
      '${entry.key} tolerates case and spacing without changing plan data',
      () {
        final source = [
          for (final name in entry.value.reversed) ...[
            _plan(
              '  ${name.toUpperCase().replaceAll(RegExp(r"(?=\d)"), " \t")}  ',
            ),
            _plan(name.replaceAll(RegExp(r'\s+'), '')),
          ],
        ];
        final result = service.filter(source, category: entry.key);
        expect(result, source);
        for (var index = 0; index < source.length; index++) {
          expect(result[index], same(source[index]));
          expect(result[index].planAmount, 70);
          expect(result[index].vatAmount, 7);
          expect(result[index].availableBoltOns.single.planId, 'addon');
        }
      },
    );

    test('${entry.key} rejects near matches, bundles and add-on names', () {
      final names = [
        '',
        'freedom50',
        'freedom35',
        'freedom12+',
        'liberty700',
        r'liberty40 bundle for $90',
        'liberty40 bonus',
        'freedom5 data1',
        'liberty70 data1',
        'promo liberty120',
        'mifi1400',
        'mifi90 bundle',
        'mifi75 data1',
        'tab750',
        'tab75 bonus',
        'roam500',
        'roam35',
        'roam20 bundle',
        'roam30 data1',
        'roameasy20',
        'roameasy caribbean',
        'roameasy carib25',
        'roameasy europe bundle',
        'roameasy usa and can',
        'global20',
        'liberty global Canada',
        'liberty global Caribbean bundle',
        'liberty global Haiti10',
      ];
      expect(
        service.filter(names.map(_plan).toList(), category: entry.key),
        isEmpty,
      );
      expect(service.filter([], category: entry.key), isEmpty);
    });
  }

  for (final category in PlanCategory.values.where(
    (category) => !allowed.containsKey(category),
  )) {
    test('$category is outside this filter', () {
      final source = [_plan('unlisted product'), _plan('freedom35')];
      final result = service.filter(source, category: category);
      expect(result, source);
      expect(result.first, same(source.first));
    });
  }
}
