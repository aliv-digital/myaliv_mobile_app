import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Usage/models/future_plan_expiry.dart';

void main() {
  test(
    'date-only API expiry preserves its calendar date without inventing a time',
    () {
      final expiry = FuturePlanExpiry.fromApiDate(' 2099-11-07 ');

      expect(expiry.date, '07/11/99');
      expect(expiry.time, isEmpty);
      expect(expiry.hasTime, isFalse);
      expect(expiry.value, DateTime(2099, 11, 7));
    },
  );

  test('compact date-only expiry also leaves time unavailable', () {
    final expiry = FuturePlanExpiry.fromApiDate('20991107');

    expect(expiry.date, '07/11/99');
    expect(expiry.time, isEmpty);
    expect(expiry.hasTime, isFalse);
  });

  for (final rawDate in ['', ' ', 'invalid', '2099-02-30', '2099-13-07']) {
    test('unavailable or invalid API expiry stays unknown: "$rawDate"', () {
      final expiry = FuturePlanExpiry.fromApiDate(rawDate);

      expect(expiry.value, isNull);
      expect(expiry.date, '--/--/--');
      expect(expiry.time, isEmpty);
    });
  }

  for (final (rawDate, expected) in [
    ('2099-11-07T18:30:00Z', DateTime.utc(2099, 11, 7, 18, 30)),
    ('2099-11-07 18:30:00', DateTime.utc(2099, 11, 7, 18, 30)),
    ('11/7/2099 6:30:00 PM', DateTime.utc(2099, 11, 7, 18, 30)),
    ('2099-11-07T18:30:00-05:00', DateTime.utc(2099, 11, 7, 23, 30)),
    ('2099-11-07T00:00:00Z', DateTime.utc(2099, 11, 7)),
    ('20991107T183000Z', DateTime.utc(2099, 11, 7, 18, 30)),
  ]) {
    test('explicit API timestamp is preserved and localized: $rawDate', () {
      final expiry = FuturePlanExpiry.fromApiDate(rawDate);

      expect(expiry.value!.toUtc(), expected);
      expect(expiry.hasTime, isTrue);
      expect(expiry.date, DateFormat('dd/MM/yy').format(expected.toLocal()));
      expect(expiry.time, DateFormat('hh:mm a').format(expected.toLocal()));
    });
  }
}
