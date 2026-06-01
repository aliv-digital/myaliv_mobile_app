import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

void main() {
  group('API display time offset', () {
    test('adds six hours to bundle plan end dates', () {
      final plan = BasePlanModel.fromApiMap({
        'PlanID': 'liberty40',
        'PlanName': 'Liberty 40',
        'EndDate': '2026-06-05 11:26:00',
      });

      expect(plan.endDateTime, DateTime(2026, 6, 5, 17, 26));
    });

    test('adds six hours to bucket usage expiry dates', () {
      final detail = BucketUsageDetail.fromJson({
        'ExpireTime': '2026-06-05 11:26:00',
        'CurrentAmount': 100,
        'InstanceId': '123',
        'PurchaseSeq': '1',
      });

      expect(detail.expireDateTime, DateTime(2026, 6, 5, 17, 26));
    });
  });
}
