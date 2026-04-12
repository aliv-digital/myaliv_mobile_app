# Plan Repository Refactoring Plan

## Overview
This document outlines a comprehensive refactoring plan to eliminate code duplication in the `HomePlanRepositoryV2` and related services. The main goal is to reduce duplicate code by 80%+ while maintaining backward compatibility.

## Current Problems

### 1. Code Duplication (Critical)
All 8 fetch methods follow the **exact same pattern**:

```dart
Future<List<XxxPlanModel>> fetchXxxPlansFromApi() async {
  final plans = await _ensureCacheLoaded();        // Step 1: Same
  final filtered = _filterService.filterByXxx(...); // Step 2: Similar (different criteria)
  final models = filtered.map(...).toList();        // Step 3: Different model type
  _cache.setXxxPlans(models);                      // Step 4: Different cache method
  return models;                                    // Step 5: Same
}
```

**Duplication count**: 8 methods × ~10 lines = 80 lines of nearly identical code

### 2. Hardcoded Values (Critical)
Filter criteria are hardcoded strings scattered across the code:

- **PlanType**: `'P'`, `'A'`
- **Frequency**: `'D'`, `'W'`, `'M'`
- **PlanGroup**: `'roaming'`, `'roameasy'`, `'mifi (30 day)'`, `'liberty global'`
- **PaymentOption**: `'postpay'`

**Problems**:
- No type safety
- Easy to make typos
- Hard to discover valid values
- Difficult to maintain

### 3. Filter Service Duplication
Three filter methods doing essentially the same thing:
- `filterByTypeAndFrequency()` - 2 criteria
- `filterByTypeAndGroup()` - 2 criteria
- `filterByTypeGroupAndPaymentOption()` - 3 criteria

All have identical filtering logic, just different field combinations.

### 4. Cache Duplication
Each plan type has 3 dedicated cache methods:
- `setXxxPlans()`, `getXxxPlans()`, `getXxxPlansTimestamp()`
- Repeated 8 times = 24 methods

---

## Proposed Solution

### Phase 1: Create Type-Safe Enums

#### 1.1 Create `lib/app/Plans/PlanScreen/repository/plan_enums.dart`

```dart
/// Plan type indicator from API
enum PlanType {
  /// Primary plan (P)
  primary('P'),

  /// Add-on plan (A)
  addon('A');

  const PlanType(this.value);
  final String value;

  /// Parse from API string value
  static PlanType? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    for (final type in PlanType.values) {
      if (type.value == normalized) return type;
    }
    return null;
  }
}

/// Plan frequency (billing cycle)
enum PlanFrequency {
  /// Daily (D)
  daily('D'),

  /// Weekly (W)
  weekly('W'),

  /// Monthly (M)
  monthly('M');

  const PlanFrequency(this.value);
  final String value;

  static PlanFrequency? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    for (final frequency in PlanFrequency.values) {
      if (frequency.value == normalized) return frequency;
    }
    return null;
  }
}

/// Plan group category
enum PlanGroup {
  /// Roaming plans
  roaming('roaming'),

  /// RoamEasy plans
  roameasy('roameasy'),

  /// MiFi plans (30 day)
  mifi('mifi (30 day)'),

  /// Liberty Global plans
  libertyGlobal('liberty global');

  const PlanGroup(this.value);
  final String value;

  static PlanGroup? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final group in PlanGroup.values) {
      if (group.value.toLowerCase() == normalized) return group;
    }
    return null;
  }
}

/// Payment option for plans
enum PaymentOption {
  /// Prepaid/Prepay
  prepay('prepay'),

  /// Postpaid/Postpay
  postpay('postpay');

  const PaymentOption(this.value);
  final String value;

  static PaymentOption? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final option in PaymentOption.values) {
      if (option.value == normalized) return option;
    }
    return null;
  }
}
```

**Benefits**:
- ✅ Type safety - compiler catches invalid values
- ✅ IDE autocomplete - discover valid values easily
- ✅ Centralized definition - single source of truth
- ✅ Easy to extend - add new values in one place

---

### Phase 2: Create Unified Filter Criteria

#### 2.1 Create `lib/app/Plans/PlanScreen/repository/plan_filter_criteria.dart`

```dart
import 'plan_enums.dart';

/// Encapsulates filter criteria for plan filtering
class PlanFilterCriteria {
  const PlanFilterCriteria({
    this.planType,
    this.frequency,
    this.planGroup,
    this.paymentOption,
  });

  final PlanType? planType;
  final PlanFrequency? frequency;
  final PlanGroup? planGroup;
  final PaymentOption? paymentOption;

  /// Factory for daily plans (PlanType=P, Frequency=D)
  factory PlanFilterCriteria.daily() => const PlanFilterCriteria(
        planType: PlanType.primary,
        frequency: PlanFrequency.daily,
      );

  /// Factory for weekly plans (PlanType=P, Frequency=W)
  factory PlanFilterCriteria.weekly() => const PlanFilterCriteria(
        planType: PlanType.primary,
        frequency: PlanFrequency.weekly,
      );

  /// Factory for monthly plans (PlanType=P, Frequency=M)
  factory PlanFilterCriteria.monthly() => const PlanFilterCriteria(
        planType: PlanType.primary,
        frequency: PlanFrequency.monthly,
      );

  /// Factory for roaming plans (PlanType=A, PlanGroup=roaming)
  factory PlanFilterCriteria.roaming() => const PlanFilterCriteria(
        planType: PlanType.addon,
        planGroup: PlanGroup.roaming,
      );

  /// Factory for RoamEasy plans (PlanType=A, PlanGroup=roameasy)
  factory PlanFilterCriteria.roameasy() => const PlanFilterCriteria(
        planType: PlanType.addon,
        planGroup: PlanGroup.roameasy,
      );

  /// Factory for MiFi plans (PlanType=P, PlanGroup=mifi)
  factory PlanFilterCriteria.mifi() => const PlanFilterCriteria(
        planType: PlanType.primary,
        planGroup: PlanGroup.mifi,
      );

  /// Factory for Liberty Global plans (PlanType=A, PlanGroup=liberty global)
  factory PlanFilterCriteria.libertyGlobal() => const PlanFilterCriteria(
        planType: PlanType.addon,
        planGroup: PlanGroup.libertyGlobal,
      );

  /// Factory for postpaid roaming plans (PlanType=A, PlanGroup=roaming, PaymentOption=postpay)
  factory PlanFilterCriteria.postpaidRoaming() => const PlanFilterCriteria(
        planType: PlanType.addon,
        planGroup: PlanGroup.roaming,
        paymentOption: PaymentOption.postpay,
      );

  /// Get criteria for a specific tab
  factory PlanFilterCriteria.forTab(HomePlanTab tab) {
    switch (tab) {
      case HomePlanTab.daily:
        return PlanFilterCriteria.daily();
      case HomePlanTab.weekly:
        return PlanFilterCriteria.weekly();
      case HomePlanTab.monthly:
        return PlanFilterCriteria.monthly();
      case HomePlanTab.roaming:
        return PlanFilterCriteria.roaming();
      case HomePlanTab.roameasy:
        return PlanFilterCriteria.roameasy();
      case HomePlanTab.mifi:
        return PlanFilterCriteria.mifi();
      case HomePlanTab.libertyGlobal:
        return PlanFilterCriteria.libertyGlobal();
      case HomePlanTab.postpaidRoaming:
        return PlanFilterCriteria.postpaidRoaming();
      case HomePlanTab.addOns:
        throw ArgumentError('Add-ons tab does not use filter criteria');
    }
  }

  @override
  String toString() {
    return 'PlanFilterCriteria('
        'planType: $planType, '
        'frequency: $frequency, '
        'planGroup: $planGroup, '
        'paymentOption: $paymentOption)';
  }
}
```

**Benefits**:
- ✅ Encapsulates all filter parameters in one object
- ✅ Named factory constructors for each plan type
- ✅ Easy to understand and use
- ✅ Can be extended with additional criteria

---

### Phase 3: Refactor Filter Service

#### 3.1 Update `PlanFilterService` to use unified filtering

```dart
import 'plan_enums.dart';
import 'plan_filter_criteria.dart';

class PlanFilterService {
  /// Unified filter method using criteria object
  ///
  /// Filters plans by any combination of:
  /// - PlanType
  /// - Frequency
  /// - PlanGroup
  /// - PaymentOption
  ///
  /// Only non-null criteria are checked (AND logic).
  List<Map<String, dynamic>> filterByCriteria({
    required List<Map<String, dynamic>> plans,
    required PlanFilterCriteria criteria,
  }) {
    return plans.where((plan) {
      // Check PlanType if specified
      if (criteria.planType != null) {
        final planType = _normalize(plan['PlanType']);
        if (planType != criteria.planType!.value) return false;
      }

      // Check Frequency if specified
      if (criteria.frequency != null) {
        final frequency = _normalize(plan['Frequency']);
        if (frequency != criteria.frequency!.value) return false;
      }

      // Check PlanGroup if specified
      if (criteria.planGroup != null) {
        final planGroup = _normalizeGroup(plan['PlanGroup']);
        if (planGroup != criteria.planGroup!.value.toUpperCase()) return false;
      }

      // Check PaymentOption if specified
      if (criteria.paymentOption != null) {
        final paymentOption = _normalizeGroup(plan['PaymentOption']);
        if (paymentOption != criteria.paymentOption!.value.toUpperCase()) {
          return false;
        }
      }

      return true;
    }).toList(growable: false);
  }

  /// Normalize value for case-insensitive comparison (for PlanType/Frequency)
  String _normalize(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }

  /// Normalize value for case-insensitive comparison (for PlanGroup/PaymentOption)
  String _normalizeGroup(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }

  // ========== DEPRECATED - Keep for backward compatibility ==========

  @Deprecated('Use filterByCriteria instead')
  List<Map<String, dynamic>> filterByTypeAndFrequency({
    required List<Map<String, dynamic>> plans,
    required String planType,
    required String frequency,
  }) {
    return filterByCriteria(
      plans: plans,
      criteria: PlanFilterCriteria(
        planType: PlanType.fromString(planType),
        frequency: PlanFrequency.fromString(frequency),
      ),
    );
  }

  @Deprecated('Use filterByCriteria instead')
  List<Map<String, dynamic>> filterByTypeAndGroup({
    required List<Map<String, dynamic>> plans,
    required String planType,
    required String planGroup,
  }) {
    return filterByCriteria(
      plans: plans,
      criteria: PlanFilterCriteria(
        planType: PlanType.fromString(planType),
        planGroup: PlanGroup.fromString(planGroup),
      ),
    );
  }

  @Deprecated('Use filterByCriteria instead')
  List<Map<String, dynamic>> filterByTypeGroupAndPaymentOption({
    required List<Map<String, dynamic>> plans,
    required String planType,
    required String planGroup,
    required String paymentOption,
  }) {
    return filterByCriteria(
      plans: plans,
      criteria: PlanFilterCriteria(
        planType: PlanType.fromString(planType),
        planGroup: PlanGroup.fromString(planGroup),
        paymentOption: PaymentOption.fromString(paymentOption),
      ),
    );
  }
}
```

**Benefits**:
- ✅ Single unified filter method
- ✅ Reduces 3 methods to 1 core method
- ✅ Backward compatible (deprecated old methods)
- ✅ More flexible - can filter by any combination

**Code reduction**: 3 methods → 1 method = **66% reduction**

---

### Phase 4: Create Generic Repository Method

#### 4.1 Add helper typedef and generic method to `HomePlanRepositoryV2`

```dart
/// Type definition for model factory function
typedef PlanModelFactory<T> = T Function(Map<String, dynamic> map);

/// Type definition for cache setter function
typedef CacheSetter<T> = void Function(List<T> plans);

/// Generic method to fetch, filter, parse, and cache plans
///
/// This eliminates duplication across all fetchXxxPlansFromApi methods.
///
/// Type parameter T: The plan model type (e.g., DailyPlanModel)
///
/// Parameters:
/// - criteria: Filter criteria (PlanType, Frequency, PlanGroup, PaymentOption)
/// - modelFactory: Function to create model from Map (e.g., DailyPlanModel.fromApiMap)
/// - cacheSetter: Function to cache the results (e.g., _cache.setDailyPlans)
Future<List<T>> _fetchPlansGeneric<T>({
  required PlanFilterCriteria criteria,
  required PlanModelFactory<T> modelFactory,
  required CacheSetter<T> cacheSetter,
}) async {
  // Step 1: Ensure raw plans are loaded
  final plans = await _ensureCacheLoaded();

  // Step 2: Filter by criteria
  final filtered = _filterService.filterByCriteria(
    plans: plans,
    criteria: criteria,
  );

  // Step 3: Map to typed models
  final models = filtered
      .map(modelFactory)
      .toList(growable: false);

  // Step 4: Cache the results
  cacheSetter(models);

  // Step 5: Return models
  return models;
}
```

#### 4.2 Refactor all fetch methods to use generic method

**Before** (Daily plans - 17 lines):
```dart
@override
Future<List<DailyPlanModel>> fetchDailyPlansFromApi({
  bool printRawResponse = false,
  bool printFilteredDailyPlans = false,
}) async {
  final plans = await _ensureCacheLoaded();
  final filtered = _filterService.filterByTypeAndFrequency(
    plans: plans,
    planType: 'P',
    frequency: 'D',
  );

  final models = filtered
      .map((map) => DailyPlanModel.fromApiMap(map, includeRawPayload: false))
      .toList(growable: false);

  _cache.setDailyPlans(models);
  return models;
}
```

**After** (Daily plans - 8 lines):
```dart
@override
Future<List<DailyPlanModel>> fetchDailyPlansFromApi({
  bool printRawResponse = false,
  bool printFilteredDailyPlans = false,
}) async {
  return _fetchPlansGeneric<DailyPlanModel>(
    criteria: PlanFilterCriteria.daily(),
    modelFactory: (map) => DailyPlanModel.fromApiMap(map, includeRawPayload: false),
    cacheSetter: _cache.setDailyPlans,
  );
}
```

**Apply same pattern to all 8 fetch methods**:

```dart
// Weekly Plans
@override
Future<List<WeeklyPlanModel>> fetchWeeklyPlansFromApi({
  bool printRawResponse = false,
  bool printFilteredWeeklyPlans = false,
}) async {
  return _fetchPlansGeneric<WeeklyPlanModel>(
    criteria: PlanFilterCriteria.weekly(),
    modelFactory: (map) => WeeklyPlanModel.fromApiMap(map, includeRawPayload: false),
    cacheSetter: _cache.setWeeklyPlans,
  );
}

// Monthly Plans
@override
Future<List<MonthlyPlanModel>> fetchMonthlyPlansFromApi({
  bool printRawResponse = false,
  bool printFilteredMonthlyPlans = false,
}) async {
  return _fetchPlansGeneric<MonthlyPlanModel>(
    criteria: PlanFilterCriteria.monthly(),
    modelFactory: (map) => MonthlyPlanModel.fromApiMap(map, includeRawPayload: false),
    cacheSetter: _cache.setMonthlyPlans,
  );
}

// Roaming Plans
@override
Future<List<RoamingPlanModel>> fetchRoamingPlansFromApi({
  bool printRawResponse = false,
  bool printFilteredRoamingPlans = false,
}) async {
  return _fetchPlansGeneric<RoamingPlanModel>(
    criteria: PlanFilterCriteria.roaming(),
    modelFactory: (map) => RoamingPlanModel.fromApiMap(map, includeRawPayload: false),
    cacheSetter: _cache.setRoamingPlans,
  );
}

// RoamEasy Plans
@override
Future<List<RoamEasyPlanModel>> fetchRoamEasyPlansFromApi({
  bool printRawResponse = false,
  bool printFilteredRoamEasyPlans = false,
}) async {
  return _fetchPlansGeneric<RoamEasyPlanModel>(
    criteria: PlanFilterCriteria.roameasy(),
    modelFactory: (map) => RoamEasyPlanModel.fromApiMap(map, includeRawPayload: false),
    cacheSetter: _cache.setRoamEasyPlans,
  );
}

// MiFi Plans
@override
Future<List<MifiPlanModel>> fetchMifiPlansFromApi({
  bool printRawResponse = false,
  bool printFilteredMifiPlans = false,
}) async {
  return _fetchPlansGeneric<MifiPlanModel>(
    criteria: PlanFilterCriteria.mifi(),
    modelFactory: (map) => MifiPlanModel.fromApiMap(map, includeRawPayload: false),
    cacheSetter: _cache.setMifiPlans,
  );
}

// Liberty Global Plans
@override
Future<List<LibertyGlobalPlanModel>> fetchLibertyGlobalPlansFromApi({
  bool printRawResponse = false,
  bool printFilteredLibertyGlobalPlans = false,
}) async {
  return _fetchPlansGeneric<LibertyGlobalPlanModel>(
    criteria: PlanFilterCriteria.libertyGlobal(),
    modelFactory: (map) => LibertyGlobalPlanModel.fromApiMap(map, includeRawPayload: false),
    cacheSetter: _cache.setLibertyGlobalPlans,
  );
}

// Postpaid Roaming Plans
@override
Future<List<HomePlansPostPaidPlanModel>> fetchPostpaidRoamingPlansFromApi({
  bool printRawResponse = false,
}) async {
  return _fetchPlansGeneric<HomePlansPostPaidPlanModel>(
    criteria: PlanFilterCriteria.postpaidRoaming(),
    modelFactory: (map) => HomePlansPostPaidPlanModel.fromApiMap(map, includeRawPayload: false),
    cacheSetter: _cache.setPostpaidRoamingPlans,
  );
}
```

**Benefits**:
- ✅ Reduces each fetch method from ~17 lines to ~8 lines
- ✅ 8 methods × 9 lines saved = **72 lines removed**
- ✅ All business logic centralized in one place
- ✅ Type-safe with generics
- ✅ Easy to add new plan types - just add criteria and call generic method

**Code reduction**: 136 lines → 64 lines = **53% reduction**

---

## Summary of Changes

### Files to Create
1. `lib/app/Plans/PlanScreen/repository/plan_enums.dart` - Enums for type safety
2. `lib/app/Plans/PlanScreen/repository/plan_filter_criteria.dart` - Filter criteria class

### Files to Modify
1. `lib/app/Plans/PlanScreen/repository/services/plan_filter_service.dart` - Add unified filter method
2. `lib/app/Plans/PlanScreen/repository/home_plan_repository_v2.dart` - Add generic method, refactor all fetch methods

### Backward Compatibility
- ✅ All existing public APIs remain unchanged
- ✅ Old filter methods marked as deprecated but still work
- ✅ No changes required in calling code
- ✅ Can be tested incrementally

---

## Expected Improvements

### Code Metrics
| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| Filter service methods | 3 | 1 (+3 deprecated) | 66% |
| Repository fetch logic | 136 lines | 64 lines | 53% |
| Hardcoded strings | 16 | 0 | 100% |
| **Total reduction** | - | - | **~60%** |

### Quality Improvements
- ✅ **Type Safety**: All string values replaced with enums
- ✅ **Maintainability**: Single source of truth for filter logic
- ✅ **Extensibility**: Adding new plan types is trivial
- ✅ **Readability**: Intent is clear from named constructors
- ✅ **Testability**: Easy to test generic method once vs 8 methods
- ✅ **Discoverability**: IDE autocomplete shows all valid options

---

## Migration Path

### Phase 1: Add New Infrastructure (Non-Breaking)
1. Create `plan_enums.dart`
2. Create `plan_filter_criteria.dart`
3. Add `filterByCriteria()` to `PlanFilterService`
4. Add `_fetchPlansGeneric()` to `HomePlanRepositoryV2`

**At this point**: All old code still works, new infrastructure available

### Phase 2: Migrate Repository Methods (Non-Breaking)
1. Refactor `fetchDailyPlansFromApi()` to use `_fetchPlansGeneric()`
2. Refactor `fetchWeeklyPlansFromApi()` to use `_fetchPlansGeneric()`
3. Refactor remaining 6 fetch methods
4. Test each method after refactoring

**At this point**: All code uses new infrastructure, public API unchanged

### Phase 3: Cleanup (Optional, Future)
1. Mark old filter methods as `@Deprecated`
2. In future versions, remove deprecated methods
3. Update any code that still uses old filter methods

---

## Testing Strategy

### Unit Tests
1. Test each enum's `fromString()` method
2. Test `PlanFilterCriteria` factory constructors
3. Test `PlanFilterService.filterByCriteria()` with various criteria combinations
4. Test `_fetchPlansGeneric()` with mock data

### Integration Tests
1. Test each `fetchXxxPlansFromApi()` method returns correct results
2. Test caching works correctly
3. Test filter criteria match expected plans

### Regression Tests
1. Compare results before/after refactoring
2. Ensure cached data structure unchanged
3. Verify no performance degradation

---

## Implementation Checklist

- [ ] Create `plan_enums.dart` with all 4 enums
- [ ] Create `plan_filter_criteria.dart` with criteria class and factories
- [ ] Update `PlanFilterService` with unified `filterByCriteria()` method
- [ ] Add `_fetchPlansGeneric()` method to `HomePlanRepositoryV2`
- [ ] Refactor 8 fetch methods to use generic approach
- [ ] Write unit tests for new enums and criteria
- [ ] Write unit tests for unified filter method
- [ ] Write integration tests for refactored fetch methods
- [ ] Run full test suite to ensure no regressions
- [ ] Update documentation and code comments
- [ ] Mark old filter methods as deprecated
- [ ] Code review and approval
- [ ] Merge and deploy

---

## Future Enhancements (Beyond This Refactor)

### Possible Next Steps
1. **Generic Cache**: Create a generic cache system to eliminate cache method duplication
2. **Plan Configuration Registry**: Map `HomePlanTab` → criteria + factory in a configuration object
3. **Lazy Loading**: Only fetch plans when tab is first accessed
4. **Cache TTL**: Add time-to-live for cached plans
5. **Reactive Updates**: Use streams to notify UI of cache updates

These can be tackled in future iterations after this refactor stabilizes.

---

## Conclusion

This refactoring will:
- **Reduce code by ~60%** (from ~136 lines to ~64 lines for fetch methods)
- **Eliminate all hardcoded strings** (16 → 0)
- **Improve type safety** with enums
- **Maintain backward compatibility** (zero breaking changes)
- **Make future changes easier** (add new plan type in 3 lines instead of 17)

The approach is **incremental**, **testable**, and **low-risk**.
