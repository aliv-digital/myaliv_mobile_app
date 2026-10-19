/// Parses date strings returned by the backend. Bare strings (no `Z`
/// and no explicit `±hh:mm` offset) are treated as **UTC** — that is
/// what the backend sends. The returned `DateTime` is always in UTC
/// (`isUtc == true`); callers convert to device-local via
/// `DateTimeX.toDeviceLocal()` when they need it for display.
///
/// Supported shapes:
/// - ISO with space separator: `2026-04-21 18:00:00`
/// - ISO with `T`: `2026-04-21T18:00:00`
/// - ISO with `Z` / offset: `2026-04-21T18:00:00Z`
/// - US format with meridiem: `4/21/2026 6:00:00 PM`
DateTime? parseApiDate(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  final isoCandidate = trimmed.replaceFirst(' ', 'T');
  final isoParsed = DateTime.tryParse(isoCandidate);
  if (isoParsed != null) {
    return isoParsed.isUtc
        ? isoParsed
        : DateTime.utc(
            isoParsed.year,
            isoParsed.month,
            isoParsed.day,
            isoParsed.hour,
            isoParsed.minute,
            isoParsed.second,
            isoParsed.millisecond,
            isoParsed.microsecond,
          );
  }

  final meridiemPattern = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})\s+(AM|PM)$',
    caseSensitive: false,
  );
  final match = meridiemPattern.firstMatch(_collapseSpaces(trimmed));
  if (match == null) return null;

  final month = int.tryParse(match.group(1) ?? '') ?? 1;
  final day = int.tryParse(match.group(2) ?? '') ?? 1;
  final year = int.tryParse(match.group(3) ?? '') ?? 1970;
  var hour = int.tryParse(match.group(4) ?? '') ?? 0;
  final minute = int.tryParse(match.group(5) ?? '') ?? 0;
  final second = int.tryParse(match.group(6) ?? '') ?? 0;
  final meridiem = (match.group(7) ?? '').toUpperCase();

  if (meridiem == 'PM' && hour < 12) hour += 12;
  if (meridiem == 'AM' && hour == 12) hour = 0;

  return DateTime.utc(year, month, day, hour, minute, second);
}

String _collapseSpaces(String value) {
  var result = value;
  while (result.contains('  ')) {
    result = result.replaceAll('  ', ' ');
  }
  return result;
}
