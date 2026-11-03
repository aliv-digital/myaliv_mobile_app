import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/authenticated_add_on_filter_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/bundle_response_parser.dart';

Map<String, dynamic> _addOn(String name, {String id = 'addon'}) => {
  'PlanID': id,
  'PlanName': name,
  'PlanType': 'S',
  'PlanAmount': 7.27,
  'VATAmount': 0.73,
  'PlanBuckets': [
    {'Name': 'Data', 'Amount': 1, 'Unit': 'GB'},
  ],
};

BasePlanModel _primary({
  String name = 'freedom45',
  String? start = '2026-11-02T00:00:00Z',
  String? end = '2026-11-09T00:00:00Z',
  List<Map<String, dynamic>>? addOns,
}) => BasePlanModel.fromApiMap({
  'PlanID': 'primary',
  'PlanName': name,
  'PlanType': 'P',
  'StartDate': start,
  'EndDate': end,
  'AvailableBoltOns': addOns ?? [_addOn('freedom data1')],
});

void main() {
  const service = AuthenticatedAddOnFilterService();
  final now = DateTime.utc(2026, 11, 3, 12);

  group('authenticated name matching', () {
    for (final family in ['freedom', 'liberty']) {
      for (final (benefit, amount) in [
        ('data', '10'),
        ('data', '3'),
        ('data', '2'),
        ('data', '1'),
        ('talk', '100'),
        ('text', '100'),
      ]) {
        test(
          '$family $benefit $amount matches spacing and ordering variants',
          () {
            for (final name in [
              '$family $benefit $amount',
              '$family$benefit$amount',
              'BONUS $family $benefit$amount offer',
              '$benefit$amount $family',
              '$benefit $family $amount',
              '$amount $benefit $family',
              '$family $amount $benefit',
              '$amount $family $benefit',
              '  ${family.toUpperCase()}\t$benefit\n$amount  ',
              '$family-$benefit-$amount',
            ]) {
              expect(service.matchesName(name), isTrue, reason: name);
            }
            for (final planNumber in ['35', '45', '70']) {
              for (final name in [
                '$family$planNumber $benefit$amount',
                '$family $planNumber $benefit $amount',
                '$family$planNumber$benefit$amount',
                '$benefit$amount $family$planNumber',
              ]) {
                expect(service.matchesName(name), isFalse, reason: name);
              }
            }
          },
        );
      }
    }

    test('rejects missing words and unsupported quantities', () {
      for (final name in [
        '',
        'data1',
        'travel data1',
        'freedom',
        'freedom data',
        'freedom data5',
        'freedom data15',
        'liberty data100',
        'freedom10 data5',
        'liberty talk1000',
        'liberty text1000',
        'freedom talk10',
        'freedom text1',
        'freedom data 1.5',
        'freedom45 data1',
        'freedom45 data10',
        'freedom45 data2',
        'freedom45 data3',
        'freedom35 data1',
        'freedom35 data2',
      ]) {
        expect(service.matchesName(name), isFalse, reason: name);
      }
    });
  });

  group('active primary add-ons', () {
    test('returns only matches and preserves API ordering and values', () {
      final primary = _primary(
        addOns: [
          _addOn('data 10 freedom', id: 'first'),
          _addOn('travel data1', id: 'hidden'),
          _addOn('freedom45 data10', id: 'numbered'),
          _addOn('liberty text100', id: 'last'),
        ],
      );
      final original = primary.toJson();
      final result = service.filter([primary], now: now);

      expect(result.map((addOn) => addOn.id), ['first', 'last']);
      expect(result.first.title, 'data 10 freedom');
      expect(result.first.price, 7.27);
      expect(result.first.vatAmount, 0.73);
      expect(result.first.label, 'data balance');
      expect(result.first.value, '1gb');
      expect(result.first.planTypeCode, 'S');
      expect(primary.toJson(), original);
    });

    test('returns empty with no primary plan or no matching add-ons', () {
      expect(service.filter([], now: now), isEmpty);
      expect(service.filter([_primary(addOns: [])], now: now), isEmpty);
      expect(
        service.filter([
          _primary(addOns: [_addOn('travel data1')]),
        ], now: now),
        isEmpty,
      );
    });

    test('excludes expired, just-ended and future primary plans', () {
      for (final primary in [
        _primary(
          end: now.subtract(const Duration(seconds: 1)).toIso8601String(),
        ),
        _primary(end: now.toIso8601String()),
        _primary(start: now.add(const Duration(days: 1)).toIso8601String()),
      ]) {
        expect(service.filter([primary], now: now), isEmpty);
      }
    });

    test('finds an active plan among expired and future plans', () {
      final expired = _primary(end: '2026-11-01T00:00:00Z');
      final active = _primary(addOns: [_addOn('liberty data2', id: 'active')]);
      final future = _primary(start: '2026-11-05T00:00:00Z');
      expect(
        service.filter([expired, active, future], now: now).single.id,
        'active',
      );
    });

    test('uses only the first active primary plan', () {
      expect(
        service.filter([
          _primary(addOns: [_addOn('travel data1')]),
          _primary(),
        ], now: now),
        isEmpty,
      );
    });

    test('matches the existing missing-date semantics', () {
      expect(
        service.filter([_primary(start: null, end: null)], now: now),
        hasLength(1),
      );
    });

    test('preserves shared-parser display mapping for each bucket shape', () {
      for (final buckets in [
        [],
        [
          {'Name': '', 'Amount': 2, 'Unit': ''},
        ],
        [
          {'Name': 'Data', 'Amount': 1.5, 'Unit': 'GB'},
        ],
        [
          {'Name': 'Minutes', 'Amount': 100, 'Unit': 'min'},
        ],
        [
          {'Name': 'Texts', 'Amount': 100, 'Unit': ''},
        ],
      ]) {
        final primary = _primary(
          addOns: [
            {..._addOn('freedom data1'), 'PlanBuckets': buckets},
          ],
        );
        final shared = BundleResponseParser.parse({
          'PrimaryPlans': [primary.toJson()],
        }).addOns.single;
        expect(
          service.filter([primary], now: now).single.toJson(),
          shared.toJson(),
        );
      }
    });
  });
}
