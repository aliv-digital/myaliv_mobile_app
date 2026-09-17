import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/models/best_plan_model.dart';

BestPlanModel _makePlan({
  int id = 1,
  String price = '25.00',
  String planName = 'Summer Data',
  String subHeading = '10GB for 30 days',
  String? link = 'https://example.com',
  DateTime? startFrom,
  DateTime? expireOn,
  String? backgroundImageUrl,
  String type = 'prepaid',
  String status = 'active',
}) {
  final now = DateTime.now();
  return BestPlanModel(
    id: id,
    price: price,
    planName: planName,
    subHeading: subHeading,
    link: link,
    startFrom: startFrom ?? now.subtract(const Duration(days: 1)),
    expireOn: expireOn ?? now.add(const Duration(days: 30)),
    backgroundImageUrl: backgroundImageUrl,
    type: type,
    status: status,
  );
}

final _fixtureJson = {
  'id': 1,
  'price': '25.00',
  'planName': 'Summer Data',
  'subHeading': '10GB for 30 days',
  'link': 'https://example.com',
  'startFrom': '2026-01-01T00:00:00.000Z',
  'expireOn': '2026-12-31T00:00:00.000Z',
  'backgroundImageUrl': 'https://example.com/img.png',
  'type': 'prepaid',
  'status': 'active',
};

void main() {
  group('BestPlanModel', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final plan = BestPlanModel.fromJson(_fixtureJson);

        expect(plan.id, 1);
        expect(plan.price, '25.00');
        expect(plan.planName, 'Summer Data');
        expect(plan.subHeading, '10GB for 30 days');
        expect(plan.link, 'https://example.com');
        expect(plan.backgroundImageUrl, 'https://example.com/img.png');
        expect(plan.type, 'prepaid');
        expect(plan.status, 'active');
        expect(plan.startFrom, DateTime.parse('2026-01-01T00:00:00.000Z'));
        expect(plan.expireOn, DateTime.parse('2026-12-31T00:00:00.000Z'));
      });

      test('handles null optional fields gracefully', () {
        final json = Map<String, dynamic>.from(_fixtureJson)
          ..remove('link')
          ..remove('backgroundImageUrl');
        final plan = BestPlanModel.fromJson(json);

        expect(plan.link, isNull);
        expect(plan.backgroundImageUrl, isNull);
      });

      test('defaults price to 0.00 when missing', () {
        final json = Map<String, dynamic>.from(_fixtureJson)..remove('price');
        final plan = BestPlanModel.fromJson(json);
        expect(plan.price, '0.00');
      });
    });

    group('toJson round-trip', () {
      test('fromJson(toJson()) produces equal model', () {
        final original = BestPlanModel.fromJson(_fixtureJson);
        final json = original.toJson();
        final restored = BestPlanModel.fromJson(json);
        expect(restored, equals(original));
      });
    });

    group('isExpired', () {
      test('is false when expireOn is today (plan valid all day)', () {
        final today = DateTime.now();
        final plan = _makePlan(
          expireOn: DateTime(today.year, today.month, today.day, 23, 59),
        );
        expect(plan.isExpired, false);
      });

      test('is false when expireOn is tomorrow', () {
        final plan = _makePlan(
          expireOn: DateTime.now().add(const Duration(days: 1)),
        );
        expect(plan.isExpired, false);
      });

      test('is true when expireOn was yesterday', () {
        final plan = _makePlan(
          expireOn: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(plan.isExpired, true);
      });

      test('is true when expireOn was 30 days ago', () {
        final plan = _makePlan(
          expireOn: DateTime.now().subtract(const Duration(days: 30)),
        );
        expect(plan.isExpired, true);
      });
    });

    group('isStarted', () {
      test('is true when startFrom is today (plan started at day boundary)', () {
        final today = DateTime.now();
        final plan = _makePlan(
          startFrom: DateTime(today.year, today.month, today.day),
        );
        expect(plan.isStarted, true);
      });

      test('is true when startFrom is yesterday', () {
        final plan = _makePlan(
          startFrom: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(plan.isStarted, true);
      });

      test('is false when startFrom is tomorrow', () {
        final plan = _makePlan(
          startFrom: DateTime.now().add(const Duration(days: 1)),
        );
        expect(plan.isStarted, false);
      });
    });

    group('isActive', () {
      test('is true for active non-expired plan', () {
        final plan = _makePlan(status: 'active');
        expect(plan.isActive, true);
      });

      test('is false for inactive plan', () {
        final plan = _makePlan(status: 'inactive');
        expect(plan.isActive, false);
      });

      test('is false for active but expired plan', () {
        final plan = _makePlan(
          status: 'active',
          expireOn: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(plan.isActive, false);
      });
    });

    group('copyWith', () {
      test('only changes the specified field', () {
        final original = _makePlan(price: '10.00', planName: 'Old Plan');
        final updated = original.copyWith(price: '99.00');

        expect(updated.price, '99.00');
        expect(updated.planName, 'Old Plan');
        expect(updated.id, original.id);
        expect(updated.type, original.type);
      });

      test('no-arg copyWith produces equal model', () {
        final original = _makePlan();
        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('two plans with same fields are equal', () {
        final a = BestPlanModel.fromJson(_fixtureJson);
        final b = BestPlanModel.fromJson(_fixtureJson);
        expect(a, equals(b));
      });

      test('plans differing by id are not equal', () {
        final a = BestPlanModel.fromJson(_fixtureJson);
        final b = BestPlanModel.fromJson({..._fixtureJson, 'id': 99});
        expect(a, isNot(equals(b)));
      });
    });
  });
}
