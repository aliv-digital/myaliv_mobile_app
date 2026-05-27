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
  double totalInitialAmount = 0,
  double totalUnusedAmount = 0,
  double totalAmountUsed = 0,
  List<BucketUsageDetail> nestedDetails = const [],
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

    test('returns empty when items is empty (API not loaded yet)', () {
      expect(
        computePlanBucketUsage(
          activePlans: [
            _plan(
              planId: '29866',
              buckets: [
                _bucket(name: 'Data', amount: 14 * 1024 * 1024, unit: 'GB'),
              ],
            ),
          ],
          items: const [],
        ),
        isEmpty,
      );
    });

    test('returns empty when plans have no buckets', () {
      expect(
        computePlanBucketUsage(
          activePlans: [_plan(planId: '29866')],
          items: [
            _item(
              freeUnitTypeName: 'data',
              unitType: 'GB',
              totalInitialAmount: 1024 * 1024,
            ),
          ],
        ),
        isEmpty,
      );
    });
  });

  group('computePlanBucketUsage — initial comes from API', () {
    test(
      'initial uses totalInitialAmount, not plan bucket.amount '
      '(fixes "900 of 15 mins" bug)',
      () {
        final result = computePlanBucketUsage(
          activePlans: [
            _plan(
              planId: '29866',
              buckets: [
                // Plan says 15 mins (900 raw seconds) — but API knows better.
                _bucket(name: 'us/can mins', amount: 900, unit: 'Minutes'),
              ],
            ),
          ],
          items: [
            _item(
              freeUnitTypeName: 'us/can mins',
              unitType: 'Minutes',
              totalInitialAmount: 54000, // 900 mins
              nestedDetails: [
                _detail(purchaseSeq: '29866.a', currentAmount: 54000),
              ],
            ),
          ],
        );

        expect(result, hasLength(1));
        expect(result.first.initial, 900.0);
        expect(result.first.remaining, 900.0);
        expect(result.first.used, 0);
        expect(result.first.progress, 0);
        expect(result.first.unitLabel, 'mins');
      },
    );

    test('remaining sums currentAmount filtered by active plan ids', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 14 * 1024 * 1024,
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 2 * 1024 * 1024),
              _detail(purchaseSeq: '29866.b', currentAmount: 1 * 1024 * 1024),
              // Foreign plan id — must be excluded.
              _detail(
                purchaseSeq: '99999.c',
                currentAmount: 100 * 1024 * 1024,
              ),
            ],
          ),
        ],
      );

      expect(result.first.initial, closeTo(14.0, 1e-9));
      expect(result.first.remaining, closeTo(3.0, 1e-9));
      expect(result.first.used, closeTo(11.0, 1e-9));
      expect(result.first.matchedDetailCount, 2);
    });

    test('multi-plan: details filtered by union of plan ids', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
          _plan(
            planId: '30112',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 19 * 1024 * 1024,
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 2 * 1024 * 1024),
              _detail(purchaseSeq: '30112.b', currentAmount: 3 * 1024 * 1024),
              _detail(
                purchaseSeq: '99999.c',
                currentAmount: 100 * 1024 * 1024,
              ),
            ],
          ),
        ],
      );

      expect(result, hasLength(1)); // deduped by bucket name
      expect(result.first.initial, closeTo(19.0, 1e-9));
      expect(result.first.remaining, closeTo(5.0, 1e-9));
      expect(result.first.matchedDetailCount, 2);
    });
  });

  group('computePlanBucketUsage — unit conversion', () {
    test('GB: raw KB → GB on both initial and remaining', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 14 * 1024 * 1024,
            nestedDetails: [
              _detail(
                purchaseSeq: '29866.a',
                currentAmount: 2.4 * 1024 * 1024,
              ),
            ],
          ),
        ],
      );

      expect(result.first.initial, closeTo(14.0, 1e-9));
      expect(result.first.remaining, closeTo(2.4, 1e-9));
      expect(result.first.unitLabel, 'GB');
    });

    test('Minutes: raw seconds → mins on both initial and remaining', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Voice', amount: 0, unit: 'Minutes')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'voice',
            unitType: 'Minutes',
            totalInitialAmount: 1800, // 30 min
            nestedDetails: [_detail(purchaseSeq: '29866.a', currentAmount: 600)],
          ),
        ],
      );

      expect(result.first.unitLabel, 'mins');
      expect(result.first.initial, 30.0);
      expect(result.first.remaining, 10.0);
      expect(result.first.used, 20.0);
    });

    test('falls back to bucket.unit when matched item has empty unitType', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: '',
            totalInitialAmount: 1024 * 1024,
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result.first.unitLabel, 'GB');
      expect(result.first.initial, closeTo(1.0, 1e-9));
    });
  });

  group('computePlanBucketUsage — unlimited treatment', () {
    test('plan-marked unlimited overrides API numbers', () {
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
        ],
        items: [
          _item(
            freeUnitTypeName: 'voice',
            unitType: 'Minutes',
            totalInitialAmount: 1800,
            nestedDetails: [_detail(purchaseSeq: '29866.a', currentAmount: 600)],
          ),
        ],
      );

      expect(result.first.isUnlimited, isTrue);
      expect(result.first.unitLabel, 'mins');
    });

    test('any-unlimited-wins when one of multiple plans marks unlimited', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Voice', amount: 600, unit: 'Minutes')],
          ),
          _plan(
            planId: '30112',
            buckets: [
              _bucket(
                name: 'Voice',
                amount: 0,
                unit: 'Minutes',
                unlimited: true,
              ),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'voice',
            unitType: 'Minutes',
            totalInitialAmount: 36000,
            nestedDetails: [_detail(purchaseSeq: '29866.a', currentAmount: 600)],
          ),
        ],
      );

      expect(result.first.isUnlimited, isTrue);
    });

    test(
      'effectively unlimited: API has remaining but no initial allowance '
      '(fixes "5 GB of 0.0 GB" bug)',
      () {
        final result = computePlanBucketUsage(
          activePlans: [
            _plan(
              planId: '29866',
              buckets: [_bucket(name: 'whatsapp full', amount: 0, unit: 'GB')],
            ),
          ],
          items: [
            _item(
              freeUnitTypeName: 'whatsapp full',
              unitType: 'GB',
              totalInitialAmount: 0,
              nestedDetails: [
                _detail(
                  purchaseSeq: '29866.a',
                  currentAmount: 5 * 1024 * 1024,
                ),
              ],
            ),
          ],
        );

        expect(result.first.isUnlimited, isTrue);
        expect(result.first.unitLabel, 'GB');
      },
    );

    test('initial = 0 AND remaining = 0 does NOT trigger unlimited rule', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 0,
            nestedDetails: const [],
          ),
        ],
      );

      expect(result.first.isUnlimited, isFalse);
      expect(result.first.initial, 0);
      expect(result.first.remaining, 0);
      expect(result.first.progress, 0); // no division by zero
    });
  });

  group('computePlanBucketUsage — skip / suppress / dedup', () {
    test('plan-declared bucket missing from API is skipped', () {
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
        items: [
          // Only Data reported, no Voice item
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 14 * 1024 * 1024,
            nestedDetails: [
              _detail(
                purchaseSeq: '29866.a',
                currentAmount: 14 * 1024 * 1024,
              ),
            ],
          ),
        ],
      );

      expect(result, hasLength(1));
      expect(result.first.bucketName, 'Data');
    });

    test('suppressed buckets drop only that plan-row, not the bucket name', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 0, unit: 'GB', suppress: true),
            ],
          ),
          _plan(
            planId: '30112',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 5 * 1024 * 1024,
            nestedDetails: const [],
          ),
        ],
      );

      expect(result, hasLength(1));
      expect(result.first.initial, closeTo(5.0, 1e-9));
    });

    test('all-suppressed buckets do not render', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 0, unit: 'GB', suppress: true),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 5 * 1024 * 1024,
          ),
        ],
      );

      expect(result, isEmpty);
    });

    test('bucket names dedupe across plans (case-insensitive)', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
          _plan(
            planId: '30112',
            buckets: [_bucket(name: 'data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'DATA',
            unitType: 'GB',
            totalInitialAmount: 10 * 1024 * 1024,
            nestedDetails: [
              _detail(purchaseSeq: '29866.a', currentAmount: 4 * 1024 * 1024),
            ],
          ),
        ],
      );

      expect(result, hasLength(1));
      expect(result.first.bucketName, 'Data'); // first-seen casing wins
      expect(result.first.initial, closeTo(10.0, 1e-9));
      expect(result.first.remaining, closeTo(4.0, 1e-9));
    });

    test('output preserves first-seen plan order across plans', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [
              _bucket(name: 'Data', amount: 0, unit: 'GB'),
              _bucket(name: 'Voice', amount: 0, unit: 'Minutes'),
            ],
          ),
          _plan(
            planId: '30112',
            buckets: [
              _bucket(name: 'SMS', amount: 0, unit: 'SMS'),
              _bucket(name: 'Voice', amount: 0, unit: 'Minutes'),
            ],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 1024 * 1024,
          ),
          _item(
            freeUnitTypeName: 'voice',
            unitType: 'Minutes',
            totalInitialAmount: 60,
          ),
          _item(freeUnitTypeName: 'sms', unitType: 'SMS', totalInitialAmount: 0),
        ],
      );

      expect(
        result.map((u) => u.bucketName).toList(),
        ['Data', 'Voice', 'SMS'],
      );
    });
  });

  group('computePlanBucketUsage — purchaseSeq filter robustness', () {
    test('malformed purchaseSeq (no dot) matches when full string == planId',
        () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 10 * 1024 * 1024,
            nestedDetails: [
              _detail(purchaseSeq: '29866', currentAmount: 1024 * 1024),
              _detail(
                purchaseSeq: '',
                currentAmount: 99 * 1024 * 1024,
              ),
            ],
          ),
        ],
      );

      expect(result.first.remaining, closeTo(1.0, 1e-9));
      expect(result.first.matchedDetailCount, 1);
    });
  });

  group('computePlanBucketUsage — math safety', () {
    test('used clamps to 0 when remaining > initial (data anomaly)', () {
      final result = computePlanBucketUsage(
        activePlans: [
          _plan(
            planId: '29866',
            buckets: [_bucket(name: 'Data', amount: 0, unit: 'GB')],
          ),
        ],
        items: [
          _item(
            freeUnitTypeName: 'data',
            unitType: 'GB',
            totalInitialAmount: 1 * 1024 * 1024, // 1 GB
            nestedDetails: [
              _detail(
                purchaseSeq: '29866.a',
                currentAmount: 5 * 1024 * 1024, // 5 GB
              ),
            ],
          ),
        ],
      );

      expect(result.first.initial, closeTo(1.0, 1e-9));
      expect(result.first.remaining, closeTo(5.0, 1e-9));
      expect(result.first.used, 0);
      expect(result.first.progress, 0);
    });
  });
}
