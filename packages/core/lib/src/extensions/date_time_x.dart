import 'package:intl/intl.dart';

import '../time/api_date_parser.dart';

const String _dashPlaceholder = '--/--/--';

extension DateTimeX on DateTime {
  /// Converts a UTC `DateTime` to the device's local timezone. A
  /// non-UTC value is returned untouched so this is safe to call
  /// repeatedly.
  DateTime toDeviceLocal() => isUtc ? toLocal() : this;

  /// `dd/MM/yy`, rendered in the device timezone.
  String formatDdMmYy() => DateFormat('dd/MM/yy').format(toDeviceLocal());

  /// `dd MMM yyyy, hh:mm a`, rendered in the device timezone.
  String formatDdMmmYyyyHm() =>
      DateFormat('dd MMM yyyy, hh:mm a').format(toDeviceLocal());

/// `dd MMM yyyy`, rendered in the device timezone.
String formatDdMmmYyyy() =>
    DateFormat('dd MMM yyyy').format(toDeviceLocal());
}

extension NullableDateTimeX on DateTime? {
  /// Card-friendly formatter that falls back to `--/--/--` when the
  /// underlying value is null or unparseable.
  String formatDdMmYyOrDash() {
    final value = this;
    if (value == null) return _dashPlaceholder;
    return value.formatDdMmYy();
  }
}

extension ApiDateString on String {
  /// Parses an API date string (assumed UTC) and converts to the
  /// device's local timezone. Returns null when the string is empty
  /// or cannot be parsed.
  DateTime? toLocalApiDate() => parseApiDate(this)?.toDeviceLocal();

  /// Parses an API date string and returns it in UTC. Returns null on
  /// empty/unparseable input.
  DateTime? toUtcApiDate() => parseApiDate(this);
}
