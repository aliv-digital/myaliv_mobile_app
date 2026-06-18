import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

void main() {
  group('parseApiDate', () {
    test('treats bare ISO strings as UTC', () {
      final result = parseApiDate('2026-06-05 11:26:00');
      expect(result, isNotNull);
      expect(result!.isUtc, isTrue);
      expect(result, DateTime.utc(2026, 6, 5, 11, 26));
    });

    test('honours explicit Z suffix', () {
      final result = parseApiDate('2026-06-05T11:26:00Z');
      expect(result, DateTime.utc(2026, 6, 5, 11, 26));
    });

    test('handles US format with meridiem as UTC', () {
      final result = parseApiDate('6/5/2026 1:26:00 PM');
      expect(result, DateTime.utc(2026, 6, 5, 13, 26));
    });

    test('returns null for empty / unparseable input', () {
      expect(parseApiDate(null), isNull);
      expect(parseApiDate(''), isNull);
      expect(parseApiDate('   '), isNull);
      expect(parseApiDate('not-a-date'), isNull);
    });
  });

  group('BasePlanModel date getters', () {
    test('startDateTime and endDateTime are returned in device-local time', () {
      final plan = BasePlanModel.fromApiMap({
        'PlanID': 'liberty40',
        'PlanName': 'Liberty 40',
        'StartDate': '2026-06-05 03:00:00',
        'EndDate': '2026-06-05 11:26:00',
      });

      // Underlying API value is UTC; getter localizes for display.
      final expectedStart = DateTime.utc(2026, 6, 5, 3).toLocal();
      final expectedEnd = DateTime.utc(2026, 6, 5, 11, 26).toLocal();

      expect(plan.startDateTime, expectedStart);
      expect(plan.endDateTime, expectedEnd);
      expect(plan.endDateTime!.isUtc, isFalse);
    });
  });

  group('BucketUsageDetail expiry parsing', () {
    test('expireDateTime preserves UTC instant from API', () {
      final detail = BucketUsageDetail.fromJson({
        'ExpireTime': '2026-06-05 11:26:00',
        'CurrentAmount': 100,
        'InstanceId': '123',
        'PurchaseSeq': '1',
      });

      expect(detail.expireDateTime, DateTime.utc(2026, 6, 5, 11, 26));
    });
  });
}
