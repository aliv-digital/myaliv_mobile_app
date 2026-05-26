/// Converts an API-raw amount into the unit named by `UnitType`.
///
/// The bucket usage API returns counters in a small base unit (KB for data,
/// seconds for minutes) together with a `UnitType` string that names both
/// the display unit and the conversion key.
///
/// Unknown unit types pass through unchanged so callers don't silently break
/// when the API adds a new category (e.g. "Count", "SMS").
double toDisplayUnit(double rawAmount, String unitType) {
  switch (_normalize(unitType)) {
    case 'gb':
      return rawAmount / (1024 * 1024);
    case 'minutes':
    case 'mins':
    case 'min':
      return rawAmount / 60;
    default:
      return rawAmount;
  }
}

/// Canonical display label for a `UnitType` value.
///
/// Keeps UI from rendering "minutes" vs "Mins" inconsistently.
String displayUnitLabel(String unitType) {
  switch (_normalize(unitType)) {
    case 'gb':
      return 'GB';
    case 'minutes':
    case 'mins':
    case 'min':
      return 'mins';
    default:
      return unitType.trim();
  }
}

String _normalize(String s) => s.trim().toLowerCase();
