import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/bucket_unit_converter.dart';

void main() {
  group('toDisplayUnit', () {
    test('converts KB to GB by dividing by 1024 * 1024', () {
      expect(toDisplayUnit(1024 * 1024, 'GB'), 1.0);
      expect(toDisplayUnit(14 * 1024 * 1024, 'GB'), 14.0);
      expect(toDisplayUnit(7340032, 'GB'), 7.0);
    });

    test('GB conversion is case insensitive', () {
      expect(toDisplayUnit(1024 * 1024, 'gb'), 1.0);
      expect(toDisplayUnit(1024 * 1024, 'Gb'), 1.0);
      expect(toDisplayUnit(1024 * 1024, ' GB '), 1.0);
    });

    test('converts seconds to minutes by dividing by 60', () {
      expect(toDisplayUnit(60, 'Minutes'), 1.0);
      expect(toDisplayUnit(1800, 'Minutes'), 30.0);
      expect(toDisplayUnit(0, 'Minutes'), 0.0);
    });

    test('Minutes conversion accepts mins / min aliases', () {
      expect(toDisplayUnit(60, 'mins'), 1.0);
      expect(toDisplayUnit(60, 'min'), 1.0);
      expect(toDisplayUnit(60, 'MINUTES'), 1.0);
    });

    test('unknown unit types pass through unchanged', () {
      expect(toDisplayUnit(200, 'SMS'), 200.0);
      expect(toDisplayUnit(5, 'Count'), 5.0);
      expect(toDisplayUnit(42, ''), 42.0);
    });
  });

  group('displayUnitLabel', () {
    test('returns canonical GB label', () {
      expect(displayUnitLabel('GB'), 'GB');
      expect(displayUnitLabel('gb'), 'GB');
      expect(displayUnitLabel(' Gb '), 'GB');
    });

    test('returns canonical mins label for minute variants', () {
      expect(displayUnitLabel('Minutes'), 'mins');
      expect(displayUnitLabel('mins'), 'mins');
      expect(displayUnitLabel('min'), 'mins');
      expect(displayUnitLabel('MINUTES'), 'mins');
    });

    test('unknown labels pass through trimmed', () {
      expect(displayUnitLabel('SMS'), 'SMS');
      expect(displayUnitLabel(' Count '), 'Count');
      expect(displayUnitLabel(''), '');
    });
  });
}
