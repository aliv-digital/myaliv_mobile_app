import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';

BucketUsageItem _item({
  required String unitType,
  double totalInitialAmount = 0,
  double totalUnusedAmount = 0,
  double totalAmountUsed = 0,
}) {
  return BucketUsageItem(
    freeUnitTypeName: 'data',
    totalInitialAmount: totalInitialAmount,
    totalUnusedAmount: totalUnusedAmount,
    totalAmountUsed: totalAmountUsed,
    nestedDetails: const [],
    unitType: unitType,
    sortOrder: '0',
  );
}

void main() {
  group('BucketUsageItem display getters — GB', () {
    test('converts raw KB totals to GB', () {
      final item = _item(
        unitType: 'GB',
        totalInitialAmount: 14 * 1024 * 1024, // 14 GB in KB
        totalUnusedAmount: 7 * 1024 * 1024, // 7 GB in KB
        totalAmountUsed: 7 * 1024 * 1024, // 7 GB in KB
      );

      expect(item.displayInitialAmount, 14.0);
      expect(item.displayUnusedAmount, 7.0);
      expect(item.displayUsedAmount, 7.0);
      expect(item.displayUnitLabelText, 'GB');
    });

    test('GB conversion is case-insensitive', () {
      final item = _item(
        unitType: 'gb',
        totalInitialAmount: 1024 * 1024,
      );
      expect(item.displayInitialAmount, 1.0);
      expect(item.displayUnitLabelText, 'GB');
    });
  });

  group('BucketUsageItem display getters — Minutes', () {
    test('converts raw seconds to minutes', () {
      final item = _item(
        unitType: 'Minutes',
        totalInitialAmount: 1800, // 30 min
        totalUnusedAmount: 600, // 10 min
        totalAmountUsed: 1200, // 20 min
      );

      expect(item.displayInitialAmount, 30.0);
      expect(item.displayUnusedAmount, 10.0);
      expect(item.displayUsedAmount, 20.0);
      expect(item.displayUnitLabelText, 'mins');
    });
  });

  group('BucketUsageItem display getters — unknown unit', () {
    test('passes raw values through unchanged', () {
      final item = _item(
        unitType: 'SMS',
        totalInitialAmount: 200,
        totalUnusedAmount: 50,
        totalAmountUsed: 150,
      );

      expect(item.displayInitialAmount, 200.0);
      expect(item.displayUnusedAmount, 50.0);
      expect(item.displayUsedAmount, 150.0);
      expect(item.displayUnitLabelText, 'SMS');
    });
  });

  group('BucketUsageItem existing ratio getters', () {
    test('usagePercent is unaffected by unit conversion (ratio cancels)', () {
      final item = _item(
        unitType: 'GB',
        totalInitialAmount: 14 * 1024 * 1024,
        totalUnusedAmount: 7 * 1024 * 1024,
        totalAmountUsed: 7 * 1024 * 1024,
      );

      expect(item.usagePercent, 50.0);
      expect(item.unusedPercent, 50.0);
    });

    test('returns 0 when totalInitialAmount is 0', () {
      final item = _item(unitType: 'GB');
      expect(item.usagePercent, 0);
      expect(item.unusedPercent, 0);
      expect(item.displayInitialAmount, 0);
    });
  });
}
