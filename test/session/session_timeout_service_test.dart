import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const kLastActiveKey = 'session_last_active_ms';
  final kTimeout = SessionTimeoutService.sessionTimeout;

  late SessionTimeoutService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    service = SessionTimeoutService();
  });

  group('markActive', () {
    test('writes the current timestamp to SharedPreferences', () async {
      final before = DateTime.now().millisecondsSinceEpoch;
      await service.markActive();
      final after = DateTime.now().millisecondsSinceEpoch;

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getInt(kLastActiveKey);

      expect(stored, isNotNull);
      expect(stored, greaterThanOrEqualTo(before));
      expect(stored, lessThanOrEqualTo(after));
    });

    test('overwrites an older timestamp on repeat calls', () async {
      final old = DateTime.now()
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({kLastActiveKey: old});

      await service.markActive();

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getInt(kLastActiveKey)!;
      expect(stored, greaterThan(old));
    });
  });

  group('hasTimedOut', () {
    test('returns true when no timestamp has ever been written', () async {
      expect(await service.hasTimedOut(), isTrue);
    });

    test('returns false immediately after markActive', () async {
      await service.markActive();
      expect(await service.hasTimedOut(), isFalse);
    });

    test('returns false when timestamp is just inside the window', () async {
      // 1 second shy of the 20-min threshold → still active.
      final insideWindow = DateTime.now()
          .subtract(kTimeout - const Duration(seconds: 1))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({kLastActiveKey: insideWindow});

      expect(await service.hasTimedOut(), isFalse);
    });

    test('returns true when timestamp is exactly at the threshold', () async {
      // At or past threshold → timed out (uses >=).
      final atThreshold = DateTime.now()
          .subtract(kTimeout)
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({kLastActiveKey: atThreshold});

      expect(await service.hasTimedOut(), isTrue);
    });

    test('returns true when timestamp is well past the threshold', () async {
      final longAgo = DateTime.now()
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({kLastActiveKey: longAgo});

      expect(await service.hasTimedOut(), isTrue);
    });

    test('refreshes the window after a new markActive', () async {
      // Start with a long-expired timestamp.
      final longAgo = DateTime.now()
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({kLastActiveKey: longAgo});
      expect(await service.hasTimedOut(), isTrue);

      // User becomes active → timeout window resets.
      await service.markActive();
      expect(await service.hasTimedOut(), isFalse);
    });
  });

  group('sessionTimeout constant', () {
    test('is 20 minutes', () {
      expect(SessionTimeoutService.sessionTimeout, const Duration(minutes: 20));
    });
  });
}
