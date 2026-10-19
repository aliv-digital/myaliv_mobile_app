/// Plan group category
enum PlanGroup {
  /// Roaming plans
  roaming('roaming'),

  /// RoamEasy plans
  roameasy('roameasy'),

  /// MiFi plans (30 day)
  mifi('mifi (30 day)'),

  /// Liberty Global plans
  libertyGlobal('liberty global'),

  /// Promotion/Bonus data add-ons (roaming)
  promotionBonusDataAddons('promotion BONUS data add-ons'),

  /// Test standalone plans
  testStandalonePlans('TEST - standalone plans');

  const PlanGroup(this.value);

  /// API value for this group
  final String value;

  /// Parse group from API string value
  static PlanGroup? parse(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final group in PlanGroup.values) {
      if (group.value.toLowerCase() == normalized) {
        return group;
      }
    }
    return null;
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PlanGroup.roaming:
        return 'Roaming';
      case PlanGroup.roameasy:
        return 'RoamEasy';
      case PlanGroup.mifi:
        return 'MiFi';
      case PlanGroup.libertyGlobal:
        return 'Liberty Global';
      case PlanGroup.promotionBonusDataAddons:
        return 'Bonus Data';
      case PlanGroup.testStandalonePlans:
        return 'Test Plans';
    }
  }

  @override
  String toString() => value;
}
