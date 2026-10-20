import 'package:core/core.dart';

/// Resolves the expiry displayed on a scheduled plan without changing its
/// backend timestamp or the rules that determine when it becomes active.
class FuturePlanExpiry {
  const FuturePlanExpiry._(this.value, {this.hasTime = false});

  final DateTime? value;
  final bool hasTime;

  factory FuturePlanExpiry.fromApiDate(String endDate) {
    final rawDate = endDate.trim();
    final dateOnly = RegExp(r'^(\d{4})-?(\d{2})-?(\d{2})$').firstMatch(rawDate);
    if (dateOnly != null) {
      final year = int.parse(dateOnly.group(1)!);
      final month = int.parse(dateOnly.group(2)!);
      final day = int.parse(dateOnly.group(3)!);
      final expiry = DateTime(year, month, day);
      if (expiry.year != year || expiry.month != month || expiry.day != day) {
        return const FuturePlanExpiry._(null);
      }

      // A calendar date has no timezone or time to convert. Preserve its date
      // and leave the time unavailable rather than inventing a cutoff.
      return FuturePlanExpiry._(expiry);
    }

    final expiry = parseApiDate(rawDate)?.toDeviceLocal();
    return FuturePlanExpiry._(
      expiry,
      hasTime: expiry != null && RegExp(r'[T\s]\d{1,2}').hasMatch(rawDate),
    );
  }

  String get date => value.formatDdMmYyOrDash();

  String get time => hasTime ? value.formatHmAOrEmpty() : '';
}
