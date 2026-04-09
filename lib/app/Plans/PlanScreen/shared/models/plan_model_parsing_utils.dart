/// Shared utilities for parsing API response data into typed models.
///
/// All plan models can use these helpers to reduce duplication and ensure
/// consistent parsing behavior across the application.
///
/// Usage:
/// ```dart
/// import 'package:myaliv_mobile_app/app/Plans/shared/models/plan_model_parsing_utils.dart';
///
/// factory MyModel.fromApiMap(Map<String, dynamic> map) {
///   return MyModel(
///     id: PlanModelParsingUtils.asString(map['ID']),
///     amount: PlanModelParsingUtils.asDouble(map['Amount']),
///     isActive: PlanModelParsingUtils.asBool(map['IsActive']),
///   );
/// }
/// ```
class PlanModelParsingUtils {
  PlanModelParsingUtils._(); // Private constructor - static class

  /// Parse dynamic value to String (null-safe, trimmed)
  ///
  /// Returns empty string for null values.
  static String asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  /// Parse dynamic value to int (null-safe with fallback)
  ///
  /// Returns 0 for null or unparseable values.
  static int asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Parse dynamic value to double (null-safe with fallback)
  ///
  /// Returns 0.0 for null or unparseable values.
  static double asDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Parse dynamic value to bool
  ///
  /// Recognizes: true, false, 1, 0, yes, no, y, n (case-insensitive)
  /// Also treats non-zero numbers as true.
  ///
  /// Returns false for null or unrecognized values.
  static bool asBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value.toString().trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'y';
  }

  /// Convert dynamic-keyed map to String-keyed map
  ///
  /// Ensures all keys are strings for safe access.
  static Map<String, dynamic> toStringKeyedMap(Map<dynamic, dynamic> map) {
    return map.map(
      (dynamic key, dynamic value) =>
          MapEntry<String, dynamic>(key.toString(), value),
    );
  }

  /// Parse dynamic value to String-keyed map (null-safe)
  ///
  /// Returns null if value is not a Map.
  static Map<String, dynamic>? asMapOrNull(dynamic value) {
    if (value is! Map) return null;
    return toStringKeyedMap(value);
  }

  /// Parse dynamic value to list of String-keyed maps
  ///
  /// Returns empty list if value is not a List or contains no Maps.
  static List<Map<String, dynamic>> asMapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];

    return value
        .whereType<Map>()
        .map((item) => toStringKeyedMap(item))
        .toList(growable: false);
  }

  /// Parse CSV string into list of trimmed non-empty strings
  ///
  /// Example: "item1, item2, item3" -> ["item1", "item2", "item3"]
  static List<String> csvToList(String value) {
    if (value.trim().isEmpty) return const <String>[];
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  /// Try to parse API date string into DateTime
  ///
  /// Supports multiple formats:
  /// - ISO 8601: "2024-01-15T10:30:00"
  /// - API format: "2024-01-15 10:30:00"
  /// - US format with AM/PM: "1/15/2024 10:30:00 AM"
  ///
  /// Returns null if parsing fails.
  static DateTime? tryParseApiDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;

    // Try ISO format first (replace space with 'T')
    final isoCandidate = normalized.replaceFirst(' ', 'T');
    final isoParsed = DateTime.tryParse(isoCandidate);
    if (isoParsed != null) return isoParsed;

    // Try parsing US format with AM/PM: "1/15/2024 10:30:00 AM"
    final meridiemPattern = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4}) (\d{1,2}):(\d{2}):(\d{2}) (AM|PM)$',
      caseSensitive: false,
    );
    final match = meridiemPattern.firstMatch(normalized);
    if (match == null) return null;

    final month = int.tryParse(match.group(1) ?? '') ?? 1;
    final day = int.tryParse(match.group(2) ?? '') ?? 1;
    final year = int.tryParse(match.group(3) ?? '') ?? 1970;
    int hour = int.tryParse(match.group(4) ?? '') ?? 0;
    final minute = int.tryParse(match.group(5) ?? '') ?? 0;
    final second = int.tryParse(match.group(6) ?? '') ?? 0;
    final meridiem = (match.group(7) ?? '').toUpperCase();

    // Convert 12-hour to 24-hour
    if (meridiem == 'PM' && hour < 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;

    return DateTime(year, month, day, hour, minute, second);
  }

  /// Format double as whole number or decimal string
  ///
  /// Example: 5.0 -> "5", 5.5 -> "5.5"
  static String formatWholeOrDecimal(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  /// Strip HTML tags from string (simple parser)
  ///
  /// Removes all HTML tags and normalizes whitespace.
  /// Useful for extracting plain text from HTML content.
  static String stripHtml(String value) {
    final buffer = StringBuffer();
    var insideTag = false;

    for (final codeUnit in value.codeUnits) {
      if (codeUnit == 60) {
        // '<'
        insideTag = true;
        continue;
      }

      if (codeUnit == 62) {
        // '>'
        insideTag = false;
        buffer.write(' ');
        continue;
      }

      if (!insideTag) {
        if (_isWhitespace(codeUnit)) {
          buffer.write(' ');
        } else {
          buffer.writeCharCode(codeUnit);
        }
      }
    }

    // Collapse multiple spaces
    final normalized = buffer.toString().replaceAll('&nbsp;', ' ');
    final collapsed = StringBuffer();
    var previousWasSpace = false;

    for (final codeUnit in normalized.codeUnits) {
      final isWhitespace = _isWhitespace(codeUnit);
      if (isWhitespace) {
        if (!previousWasSpace) {
          collapsed.write(' ');
        }
        previousWasSpace = true;
        continue;
      }

      collapsed.writeCharCode(codeUnit);
      previousWasSpace = false;
    }

    return collapsed.toString().trim();
  }

  static bool _isWhitespace(int codeUnit) {
    return codeUnit == 9 || // tab
        codeUnit == 10 || // newline
        codeUnit == 13 || // carriage return
        codeUnit == 32; // space
  }
}
