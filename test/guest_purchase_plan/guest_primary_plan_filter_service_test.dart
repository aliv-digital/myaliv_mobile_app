import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/services/guest_primary_plan_filter_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/payment_option.dart';

BasePlanModel _plan(String name, {String? paymentOption}) =>
    BasePlanModel.fromApiMap({
      'PlanID': name,
      'PlanName': name,
      'PlanType': 'P',
      'PaymentOption': paymentOption,
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
    PlanCategory.postpaidRoaming: ['travel50', 'travel30', 'travel20'],
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
      expect(source, hasLength(26));
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
        'travel500',
        'travel20 bundle',
        'travel30 data1',
      ];
      expect(
        service.filter(names.map(_plan).toList(), category: entry.key),
        isEmpty,
      );
      expect(service.filter([], category: entry.key), isEmpty);
    });
  }

  for (final (category, family, payment) in [
    (PlanCategory.roaming, 'roam', PaymentOption.prepay),
    (PlanCategory.roaming, 'travel', PaymentOption.postpay),
    (PlanCategory.postpaidRoaming, 'travel', PaymentOption.postpay),
  ]) {
    test('$category accepts the real $family duration names', () {
      final source = [
        _plan('${family}50 14-day', paymentOption: payment.value),
        _plan('${family}30 7-day', paymentOption: payment.value),
        _plan('${family}20 7-day', paymentOption: payment.value),
        _plan(
          '${family.toUpperCase()} 20 7 - DAYS',
          paymentOption: payment.value,
        ),
      ];
      final result = service.filter(
        source,
        category: category,
        paymentOption: payment,
      );
      expect(result, source);
      expect(result.first, same(source.first));
    });

    test(
      '$category rejects near matches and non-duration suffixes for $family',
      () {
        final source = [
          '${family}500 14-day',
          '${family}50 7-day',
          '${family}30 14-day',
          '${family}20 7-day bundle',
          '${family}30 7-day data1',
          'promo ${family}50 14-day',
        ].map((name) => _plan(name, paymentOption: payment.value)).toList();
        expect(
          service.filter(source, category: category, paymentOption: payment),
          isEmpty,
        );
      },
    );
  }

  test(
    'verified postpaid uses travel names and rejects conflicting plan metadata',
    () {
      final source = [
        _plan('travel20', paymentOption: 'PostPaid'),
        _plan('travel30', paymentOption: 'PrePay'),
        _plan('roam50', paymentOption: 'PostPay'),
        _plan('travel50'),
      ];
      final result = service.filter(
        source,
        category: PlanCategory.roaming,
        paymentOption: PaymentOption.postpay,
      );
      expect(result.map((plan) => plan.planName), ['travel20', 'travel50']);
    },
  );

  test(
    'without a subscriber option the wire payment option selects the allowlist',
    () {
      final result = service.filter([
        _plan('roam20', paymentOption: 'PrePay'),
        _plan('travel20', paymentOption: 'post-pay'),
        _plan('travel30'),
        _plan('roam30', paymentOption: 'PostPay'),
      ], category: PlanCategory.roaming);
      expect(result.map((plan) => plan.planName), ['roam20', 'travel20']);
    },
  );

  test('verified postpaid cannot show other catalog categories', () {
    for (final entry in allowed.entries) {
      if (entry.key == PlanCategory.roaming ||
          entry.key == PlanCategory.postpaidRoaming) {
        continue;
      }
      expect(
        service.filter(
          entry.value
              .map((name) => _plan(name, paymentOption: 'PostPay'))
              .toList(),
          category: entry.key,
          paymentOption: PaymentOption.postpay,
        ),
        isEmpty,
      );
    }
  });

  test('verified prepaid cannot receive postpaid roaming', () {
    expect(
      service.filter(
        [_plan('travel50', paymentOption: 'PostPay')],
        category: PlanCategory.roaming,
        paymentOption: PaymentOption.prepay,
      ),
      isEmpty,
    );
    expect(
      service.filter(
        [_plan('travel50')],
        category: PlanCategory.postpaidRoaming,
        paymentOption: PaymentOption.prepay,
      ),
      isEmpty,
    );
  });

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
