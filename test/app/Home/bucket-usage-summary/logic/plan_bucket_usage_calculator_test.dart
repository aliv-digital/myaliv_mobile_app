import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage_calculator.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

// ─── builders ────────────────────────────────────────────────────────────────

BasePlanModel _plan({
  required String planId,
  List<Map<String, dynamic>> buckets = const [],
}) {
  return BasePlanModel.fromApiMap({
    'PlanID': planId,
    'PlanBuckets': buckets,
  });
}

Map<String, dynamic> _bucket({
  required String name,
  required double amount,
  String unit = '',
  bool unlimited = false,
  bool suppress = false,
}) {
  return {
    'Name': name,
    'Amount': amount,
    'Unit': unit,
    'BucketOrder': '0',
    'Suppress': suppress,
    'Unlimited': unlimited,
    'BucketUnit': unit,
  };
}

BucketUsageItem _item({
  required String freeUnitTypeName,
  String unitType = '',
  List<BucketUsageDetail> nestedDetails = const [],
  double totalInitialAmount = 0,
  double totalUnusedAmount = 0,
  double totalAmountUsed = 0,
}) {
  return BucketUsageItem(
    freeUnitTypeName: freeUnitTypeName,
    totalInitialAmount: totalInitialAmount,
    totalUnusedAmount: totalUnusedAmount,
    totalAmountUsed: totalAmountUsed,
    nestedDetails: nestedDetails,
    unitType: unitType,
    sortOrder: '0',
  );
}

BucketUsageDetail _detail({
  required String purchaseSeq,
  required double currentAmount,
}) {
  return BucketUsageDetail(
    expireTime: '',
    expireDateTime: null,
    currentAmount: currentAmount,
    instanceId: '',
    purchaseSeq: purchaseSeq,
    mtSubscriptionId: null,
  );
}

// ─── tests ───────────────────────────────────────────────────────────────────

void main() {
  group('computePlanBucketUsage — empty inputs', () {
    test('returns empty when activePlans is empty', () {
      expect(
        computePlanBucketUsage(activePlans: const [], items: const []),
        isEmpty,
      );
    });

    test('returns empty when plans have no buckets', () {
      expect(
        computePlanBucketUsage(
          activePlans: [_plan(planId: '29866')],
          items: const [],
        ),
        isEmpty,
      );
    });
  });

  group('computePlanBucketUsage — single plan, GB conversion', () {
    test('joins planBuckets with usage item and produces display values', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 14 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            nestedDetails: [
              _detail(
                purchaseSeq: '29866.20260303153113.001.20260303153124',
                currentAmount: 2.4 * 1024 * 1024,
              ),
            ],
          ),
        ],
      );

      expect(result, hasLength(1));
      final usage = result.first;
      expect(usage.bucketName, 'Data');
      expect(usage.unitLabel, 'GB');
      expect(usage.isUnlimited, false);
      expect(usage.initial, closeTo(14.0, 1e-9));
      expect(usage.remaining, closeTo(2.4, 1e-9));
      expect(usage.used, closeTo(11.6, 1e-9));
      expect(usage.progress, closeTo(11.6 / 14.0, 1e-9));
      expect(usage.matchedDetailCount, 1);
    });

    test('sums multiple nested details for the same plan id', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 14 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 1024 * 1024),
              _detail(purchaseSeq: '29866.b', currentAmount: 2 * 1024 * 1024),
              _detail(purchaseSeq: '29866.c', currentAmount: 4 * 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result.first.remaining, closeTo(7.0, 1e-9));
      expect(result.first.matchedDetailCount, 3);
    });

    test('ignores nested details with non-matching plan id', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 10 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 1024 * 1024),
              _detail(purchaseSeq: '99999.b', currentAmount: 5 * 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result.first.remaining, closeTo(1.0, 1e-9));
      expect(result.first.matchedDetailCount, 1);
    });
  });

  group('computePlanBucketUsage — minutes conversion', () {
    test('converts seconds to minutes', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Voice', amount: 1800, unit: 'Minutes'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'voice',
            unitType: 'Minutes',
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 600),
            ],
          ),
        ],
      );

      expect(result.first.unitLabel, 'mins');
      expect(result.first.initial, 30.0);
      expect(result.first.remaining, 10.0);
      expect(result.first.used, 20.0);
    });
  });

  group('computePlanBucketUsage — multi-plan aggregation', () {
    test('sums initial across primary + secondary, matches both plan ids', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 14 * 1024 * 1024, unit: 'GB'),
            ],
          ),
          _plan(
            planId: '30112',
            buckets: [
              _bucket(name: 'Data', amount: 5 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 2 * 1024 * 1024),
              _detail(purchaseSeq: '30112.b', currentAmount: 3 * 1024 * 1024),
              _detail(purchaseSeq: '99999.c', currentAmount: 100 * 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result, hasLength(1));
      final usage = result.first;
      expect(usage.initial, closeTo(19.0, 1e-9));
      expect(usage.remaining, closeTo(5.0, 1e-9));
      expect(usage.used, closeTo(14.0, 1e-9));
      expect(usage.matchedDetailCount, 2);
    });

    test('any-unlimited wins when one plan has unlimited bucket', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(
                name: 'Voice',
                amount: 0,
                unit: 'Minutes',
                unlimited: true,
              ),
            ],
          ),
          _plan(
            planId: '30112',
            buckets: [
              _bucket(name: 'Voice', amount: 600, unit: 'Minutes'),
            ],
          ),
        ],
        items: const [],
      );

      expect(result, hasLength(1));
      expect(result.first.isUnlimited, isTrue);
      expect(result.first.unitLabel, 'mins');
    });

    test('suppressed buckets are dropped from that plan only', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(
                name: 'Data',
                amount: 14 * 1024 * 1024,
                unit: 'GB',
                suppress: true,
              ),
            ],
          ),
          _plan(
            planId: '30112',
            buckets: [
              _bucket(name: 'Data', amount: 5 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: const [],
      );

      expect(result, hasLength(1));
      expect(result.first.initial, closeTo(5.0, 1e-9));
    });

    test('produces multiple buckets when plans expose different bucket names',
        () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 14 * 1024 * 1024, unit: 'GB'),
              _bucket(name: 'Voice', amount: 1800, unit: 'Minutes'),
            ],
          ),
        ],
        items: const [],
      );

      expect(result, hasLength(2));
      expect(result.map((u) => u.bucketName).toList(), ['Data', 'Voice']);
      expect(result[0].unitLabel, 'GB');
      expect(result[1].unitLabel, 'mins');
    });
  });

  group('computePlanBucketUsage — edge cases', () {
    test('no matching usage item → remaining = 0, used = initial', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 10 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: const [],
      );

      expect(result.first.initial, closeTo(10.0, 1e-9));
      expect(result.first.remaining, 0);
      expect(result.first.used, closeTo(10.0, 1e-9));
      expect(result.first.progress, 1.0);
    });

    test('matched item but no matching detail → remaining = 0', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 10 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            nestedDetails: [
              _detail(purchaseSeq: '99999.a', currentAmount: 5 * 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result.first.remaining, 0);
      expect(result.first.matchedDetailCount, 0);
    });

    test('initial = 0 → progress = 0 (no division by zero)', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: const [],
      );

      expect(result.first.progress, 0);
    });

    test('remaining > initial (stacked add-ons) → used clamped to 0', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 1 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 5 * 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result.first.initial, closeTo(1.0, 1e-9));
      expect(result.first.remaining, closeTo(5.0, 1e-9));
      expect(result.first.used, 0);
      expect(result.first.progress, 0);
    });

    test('malformed purchaseSeq (no dot) does not crash and uses full string',
        () {
      // "29866" with no dot → planIdOf() returns "29866", which matches.
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 10 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            nestedDetails: [
              _detail(purchaseSeq: '29866', currentAmount: 1024 * 1024),
              _detail(purchaseSeq: '', currentAmount: 999 * 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result.first.matchedDetailCount, 1);
      expect(result.first.remaining, closeTo(1.0, 1e-9));
    });

    test('bucket name matching is case-insensitive', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 10 * 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'DATA',
            unitType: 'GB',
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 4 * 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result.first.remaining, closeTo(4.0, 1e-9));
    });

    test('falls back to bucket.unit when matched item has empty unitType', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 1024 * 1024, unit: 'GB'),
            ],
          ),
        ],
        items: [_item(freeUnitTypeName: 'data', unitType: '')],
      );

      expect(result.first.unitLabel, 'GB');
      expect(result.first.initial, closeTo(1.0, 1e-9));
    });
  });
}
