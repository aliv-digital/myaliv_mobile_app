/// Filters plan data by type, frequency, and group.
///
/// This service provides strict filtering logic for plan categorization.
class PlanFilterService {
  /// Normalize value for case-insensitive comparison
  String _normalize(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }

  /// Filter plans by PlanType and Frequency
  ///
  /// Example: Filter for Daily plans (PlanType='P', Frequency='D')
  List<Map<String, dynamic>> filterByTypeAndFrequency({
    required List<Map<String, dynamic>> plans,
    required String planType,
    required String frequency,
  }) {
    final normalizedType = planType.trim().toUpperCase();
    final normalizedFrequency = frequency.trim().toUpperCase();

    return plans.where((plan) {
      final currentType = _normalize(plan['PlanType']);
      final currentFrequency = _normalize(plan['Frequency']);

      return currentType == normalizedType &&
          currentFrequency == normalizedFrequency;
    }).toList(growable: false);
  }

  /// Filter plans by PlanType and PlanGroup
  ///
  /// Example: Filter for Roaming plans (PlanType='A', PlanGroup='roaming')
  List<Map<String, dynamic>> filterByTypeAndGroup({
    required List<Map<String, dynamic>> plans,
    required String planType,
    required String planGroup,
  }) {
    final normalizedType = planType.trim().toUpperCase();
    final normalizedGroup = planGroup.trim().toUpperCase();

    return plans.where((plan) {
      final currentType = _normalize(plan['PlanType']);
      final currentGroup = _normalize(plan['PlanGroup']);

      return currentType == normalizedType && currentGroup == normalizedGroup;
    }).toList(growable: false);
  }
}
