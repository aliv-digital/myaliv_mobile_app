class PlanNameFormatterService {
  const PlanNameFormatterService._();

  // Also matches before the separate " - 7 days" duration in purchase titles.
  static final _daySuffix = RegExp(
    r'\s+\d+\s*-\s*days?(?=\s*(?:$|-\s))',
    caseSensitive: false,
  );

  /// Hides the numeric day tag for display without changing the API name.
  static String format(String planName) {
    final match = _daySuffix.firstMatch(planName);
    if (match == null) {
      return planName;
    }
    return planName.replaceRange(match.start, match.end, '').trimRight();
  }
}
