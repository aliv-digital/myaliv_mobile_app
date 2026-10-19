/// Thin abstraction over the device's clock and timezone so that
/// timezone-dependent code can be deterministically tested by swapping
/// in a fake via the DI container.
abstract class TimezoneService {
  DateTime nowLocal();
  DateTime nowUtc();
  Duration get deviceOffset;
  DateTime toDeviceLocal(DateTime value);
}

class DeviceTimezoneService implements TimezoneService {
  const DeviceTimezoneService();

  @override
  DateTime nowLocal() => DateTime.now();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  Duration get deviceOffset => DateTime.now().timeZoneOffset;

  @override
  DateTime toDeviceLocal(DateTime value) {
    return value.isUtc ? value.toLocal() : value;
  }
}
