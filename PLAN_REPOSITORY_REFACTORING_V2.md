# Plan Repository Refactoring Plan v2 - Single-Pass Categorization

## Overview
This refactoring eliminates the inefficiency of filtering the entire plan list multiple times. Instead, we **categorize plans once** during initial fetch, then retrieve pre-categorized plans instantly when needed.

---

## Current Problem (Inefficient Multi-Pass Filtering)

### Current Flow (8 Passes Through Data)
```
API Response → Raw Plans List (100 items)
                    ↓
    ┌───────────────┼───────────────┐
    ↓               ↓               ↓
Filter Daily    Filter Weekly   Filter Monthly  ... (8 times)
(Loop 100)      (Loop 100)      (Loop 100)
    ↓               ↓               ↓
 10 items        5 items         15 items
```

**Problem**: We loop through the same 100 items **8 times** to extract different plan types.
- **Time Complexity**: O(n × m) where n = plans, m = plan types (8)
- **Wasted CPU**: Same data scanned 8 times
- **Unnecessary Work**: Especially bad when users switch tabs frequently

---

## Proposed Solution (Single-Pass Categorization)

### New Flow (1 Pass Through Data)
```
API Response → Raw Plans List (100 items)
                    ↓
         ┌──────────┴──────────┐
         ↓                     ↓
   Categorize ONCE        Parse ONCE
   (Loop 100, Group)      (Loop 100, Map to Models)
         ↓                     ↓
    Categorized Map       Categorized Map
    {                     {
      daily: [raw1, raw2],     daily: [model1, model2],
      weekly: [raw3],          weekly: [model3],
      roaming: [raw4],         roaming: [model4],
      ...                      ...
    }                     }
         ↓                     ↓
    Fetch Daily Plans → Just retrieve map['daily'] → Instant!
    Fetch Weekly Plans → Just retrieve map['weekly'] → Instant!
```

**Benefits**:
- ✅ **Single loop**: Parse all plans once
- ✅ **O(n) complexity**: Linear time, not O(n × m)
- ✅ **Instant retrieval**: No filtering when fetching for tabs
- ✅ **Cache-friendly**: Store pre-categorized results

---

## Architecture Design

### 1. Plan Category Key (Enum-Based)

Create a type-safe key system for categorizing plans:

```dart
// lib/app/Plans/PlanScreen/repository/plan_category.dart

/// Category key for grouping plans
enum PlanCategory {
  daily,
  weekly,
  monthly,
  roaming,
  roameasy,
  mifi,
  libertyGlobal,
  postpaidRoaming,
  unknown; // For plans that don't match any criteria

  /// Get category from HomePlanTab
  static PlanCategory fromTab(HomePlanTab tab) {
    switch (tab) {
      case HomePlanTab.daily:
        return PlanCategory.daily;
      case HomePlanTab.weekly:
        return PlanCategory.weekly;
      case HomePlanTab.monthly:
        return PlanCategory.monthly;
      case HomePlanTab.roaming:
        return PlanCategory.roaming;
      case HomePlanTab.roameasy:
        return PlanCategory.roameasy;
      case HomePlanTab.mifi:
        return PlanCategory.mifi;
      case HomePlanTab.libertyGlobal:
        return PlanCategory.libertyGlobal;
      case HomePlanTab.postpaidRoaming:
        return PlanCategory.postpaidRoaming;
      case HomePlanTab.addOns:
        throw ArgumentError('Add-ons use different mechanism');
    }
  }
}
```

---

### 2. Plan Categorizer Service (Single Responsibility)

Create a service that knows how to categorize a single plan:

```dart
// lib/app/Plans/PlanScreen/repository/services/plan_categorizer.dart

import '../plan_enums.dart';
import '../plan_category.dart';

/// Service to categorize a single plan based on its attributes
class PlanCategorizer {
  /// Determine which category a plan belongs to
  ///
  /// Logic:
  /// - Daily: PlanType=P, Frequency=D
  /// - Weekly: PlanType=P, Frequency=W
  /// - Monthly: PlanType=P, Frequency=M
  /// - Roaming: PlanType=A, PlanGroup=roaming (prepaid)
  /// - RoamEasy: PlanType=A, PlanGroup=roameasy
  /// - MiFi: PlanType=P, PlanGroup=mifi (30 day)
  /// - LibertyGlobal: PlanType=A, PlanGroup=liberty global
  /// - PostpaidRoaming: PlanType=A, PlanGroup=roaming, PaymentOption=postpay
  /// - Unknown: Doesn't match any criteria
  PlanCategory categorize(Map<String, dynamic> plan) {
    final planType = _normalize(plan['PlanType']);
    final frequency = _normalize(plan['Frequency']);
    final planGroup = _normalizeGroup(plan['PlanGroup']);
    final paymentOption = _normalizeGroup(plan['PaymentOption']);

    // Primary Plans (PlanType = P)
    if (planType == 'P') {
      // Check frequency-based categories
      if (frequency == 'D') return PlanCategory.daily;
      if (frequency == 'W') return PlanCategory.weekly;
      if (frequency == 'M') {
        // Check if it's MiFi or regular monthly
        if (planGroup == 'MIFI (30 DAY)') {
          return PlanCategory.mifi;
        }
        return PlanCategory.monthly;
      }
    }

    // Add-on Plans (PlanType = A)
    if (planType == 'A') {
      // Check group-based categories
      if (planGroup == 'ROAMING') {
        // Distinguish between prepaid and postpaid roaming
        if (paymentOption == 'POSTPAY') {
          return PlanCategory.postpaidRoaming;
        }
        return PlanCategory.roaming;
      }
      if (planGroup == 'ROAMEASY') return PlanCategory.roameasy;
      if (planGroup == 'LIBERTY GLOBAL') return PlanCategory.libertyGlobal;
    }

    // Doesn't match any known category
    return PlanCategory.unknown;
  }

  /// Categorize a plan and return all matching categories
  /// (Some plans might belong to multiple categories)
  List<PlanCategory> categorizeMulti(Map<String, dynamic> plan) {
    final categories = <PlanCategory>[];
    final primary = categorize(plan);

    categories.add(primary);

    // Example: A monthly MiFi plan might belong to both 'monthly' and 'mifi'
    // Add multi-category logic here if needed

    return categories;
  }

  String _normalize(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }

  String _normalizeGroup(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }
}
```

---

### 3. Categorized Plans Container

Store categorized plans in a type-safe container:

```dart
// lib/app/Plans/PlanScreen/repository/services/categorized_plans.dart

import '../plan_category.dart';
import '../../models/daily_plan_model.dart';
import '../../models/weekly_plan_model.dart';
import '../../models/monthly_plan_model.dart';
import '../../models/roaming_plan_model.dart';
import '../../models/roameasy_plan_model.dart';
import '../../models/mifi_plan_model.dart';
import '../../models/liberty_global_plan_model.dart';
import '../../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Container for categorized plan data
///
/// Stores both raw maps and typed models for each category
class CategorizedPlans {
  CategorizedPlans({
    required this.rawPlans,
    required this.typedPlans,
    required this.timestamp,
  });

  /// Raw plan maps grouped by category
  final Map<PlanCategory, List<Map<String, dynamic>>> rawPlans;

  /// Typed plan models grouped by category
  final Map<PlanCategory, List<dynamic>> typedPlans;

  /// When this categorization was created
  final DateTime timestamp;

  /// Factory to create empty categorized plans
  factory CategorizedPlans.empty() {
    return CategorizedPlans(
      rawPlans: {
        for (final category in PlanCategory.values) category: [],
      },
      typedPlans: {
        for (final category in PlanCategory.values) category: [],
      },
      timestamp: DateTime.now(),
    );
  }

  /// Get daily plans (typed)
  List<DailyPlanModel> getDailyPlans() {
    return (typedPlans[PlanCategory.daily] ?? [])
        .cast<DailyPlanModel>();
  }

  /// Get weekly plans (typed)
  List<WeeklyPlanModel> getWeeklyPlans() {
    return (typedPlans[PlanCategory.weekly] ?? [])
        .cast<WeeklyPlanModel>();
  }

  /// Get monthly plans (typed)
  List<MonthlyPlanModel> getMonthlyPlans() {
    return (typedPlans[PlanCategory.monthly] ?? [])
        .cast<MonthlyPlanModel>();
  }

  /// Get roaming plans (typed)
  List<RoamingPlanModel> getRoamingPlans() {
    return (typedPlans[PlanCategory.roaming] ?? [])
        .cast<RoamingPlanModel>();
  }

  /// Get RoamEasy plans (typed)
  List<RoamEasyPlanModel> getRoamEasyPlans() {
    return (typedPlans[PlanCategory.roameasy] ?? [])
        .cast<RoamEasyPlanModel>();
  }

  /// Get MiFi plans (typed)
  List<MifiPlanModel> getMifiPlans() {
    return (typedPlans[PlanCategory.mifi] ?? [])
        .cast<MifiPlanModel>();
  }

  /// Get Liberty Global plans (typed)
  List<LibertyGlobalPlanModel> getLibertyGlobalPlans() {
    return (typedPlans[PlanCategory.libertyGlobal] ?? [])
        .cast<LibertyGlobalPlanModel>();
  }

  /// Get Postpaid Roaming plans (typed)
  List<HomePlansPostPaidPlanModel> getPostpaidRoamingPlans() {
    return (typedPlans[PlanCategory.postpaidRoaming] ?? [])
        .cast<HomePlansPostPaidPlanModel>();
  }

  /// Get raw plans for a category
  List<Map<String, dynamic>> getRawPlansForCategory(PlanCategory category) {
    return rawPlans[category] ?? [];
  }
}
```

---

### 4. Plan Parser Service (Single-Pass Parsing & Categorization)

Update the parser to categorize AND parse in a single pass:

```dart
// lib/app/Plans/PlanScreen/repository/services/plan_parser_v2.dart

import '../plan_category.dart';
import 'plan_categorizer.dart';
import 'categorized_plans.dart';
import '../../models/daily_plan_model.dart';
import '../../models/weekly_plan_model.dart';
// ... other imports

/// Parses and categorizes plans in a single pass
class PlanParserV2 {
  PlanParserV2({
    PlanCategorizer? categorizer,
  }) : _categorizer = categorizer ?? PlanCategorizer();

  final PlanCategorizer _categorizer;

  /// Parse and categorize all plans in a single pass
  ///
  /// This is the KEY optimization:
  /// - Loop through raw plans ONCE
  /// - Categorize each plan
  /// - Parse to appropriate model type
  /// - Store in categorized container
  ///
  /// Returns: CategorizedPlans with all plans organized by category
  Future<CategorizedPlans> parseAndCategorize(
    List<Map<String, dynamic>> rawPlans,
  ) async {
    // Initialize empty categorized container
    final categorized = CategorizedPlans.empty();

    // SINGLE PASS: Loop through all plans once
    for (final rawPlan in rawPlans) {
      // Step 1: Determine category
      final category = _categorizer.categorize(rawPlan);

      // Step 2: Add raw plan to appropriate category
      categorized.rawPlans[category]?.add(rawPlan);

      // Step 3: Parse to typed model based on category
      final typedModel = _parseToTypedModel(rawPlan, category);

      // Step 4: Add typed model to appropriate category
      if (typedModel != null) {
        categorized.typedPlans[category]?.add(typedModel);
      }
    }

    return categorized;
  }

  /// Parse a raw plan to its appropriate typed model
  dynamic _parseToTypedModel(
    Map<String, dynamic> rawPlan,
    PlanCategory category,
  ) {
    switch (category) {
      case PlanCategory.daily:
        return DailyPlanModel.fromApiMap(rawPlan, includeRawPayload: false);

      case PlanCategory.weekly:
        return WeeklyPlanModel.fromApiMap(rawPlan, includeRawPayload: false);

      case PlanCategory.monthly:
        return MonthlyPlanModel.fromApiMap(rawPlan, includeRawPayload: false);

      case PlanCategory.roaming:
        return RoamingPlanModel.fromApiMap(rawPlan, includeRawPayload: false);

      case PlanCategory.roameasy:
        return RoamEasyPlanModel.fromApiMap(rawPlan, includeRawPayload: false);

      case PlanCategory.mifi:
        return MifiPlanModel.fromApiMap(rawPlan, includeRawPayload: false);

      case PlanCategory.libertyGlobal:
        return LibertyGlobalPlanModel.fromApiMap(rawPlan, includeRawPayload: false);

      case PlanCategory.postpaidRoaming:
        return HomePlansPostPaidPlanModel.fromApiMap(rawPlan, includeRawPayload: false);

      case PlanCategory.unknown:
        return null; // Don't parse unknown plans
    }
  }
}
```

---

### 5. Updated Cache (Store Categorized Plans)

```dart
// lib/app/Plans/PlanScreen/repository/services/plan_cache_v2.dart

import 'categorized_plans.dart';
import '../plan_category.dart';

/// Cache for categorized plans
class PlanCacheV2 {
  CategorizedPlans? _categorizedPlans;

  /// Check if we have cached categorized plans
  bool hasCategorizedPlans() => _categorizedPlans != null;

  /// Get cached categorized plans
  CategorizedPlans? getCategorizedPlans() => _categorizedPlans;

  /// Set categorized plans
  void setCategorizedPlans(CategorizedPlans plans) {
    _categorizedPlans = plans;
  }

  /// Get plans for a specific category (convenience method)
  List<dynamic> getPlansForCategory(PlanCategory category) {
    return _categorizedPlans?.typedPlans[category] ?? [];
  }

  /// Clear cache
  void clear() {
    _categorizedPlans = null;
  }
}
```

---

### 6. Refactored Repository (Ultra-Simple Fetch Methods)

```dart
// lib/app/Plans/PlanScreen/repository/home_plan_repository_v3.dart

class HomePlanRepositoryV3 implements BasePlanRepository {
  HomePlanRepositoryV3({
    NetworkService? networkService,
    AuthManager? authManager,
    PlanCacheV2? cache,
    PlanApiClient? apiClient,
    PlanParserV2? parser,
  })  : _cache = cache ?? PlanCacheV2(),
        _apiClient = apiClient ?? PlanApiClient(...),
        _parser = parser ?? PlanParserV2();

  final PlanCacheV2 _cache;
  final PlanApiClient _apiClient;
  final PlanParserV2 _parser;

  /// Fetch and categorize ALL plans once
  ///
  /// This is the ONLY method that does heavy lifting
  /// All other fetch methods just retrieve from categorized cache
  Future<CategorizedPlans> _ensureCategorizedPlansLoaded() async {
    // Check cache first
    if (_cache.hasCategorizedPlans()) {
      return _cache.getCategorizedPlans()!;
    }

    // Fetch raw data from API
    final rawJson = await _apiClient.fetchRawPlansJson();
    final rawPlans = await _parser.parseJson(rawJson); // Basic JSON parse

    // SINGLE PASS: Categorize and parse all plans
    final categorized = await _parser.parseAndCategorize(rawPlans);

    // Cache categorized results
    _cache.setCategorizedPlans(categorized);

    return categorized;
  }

  // ========== Ultra-Simple Fetch Methods ==========
  // Each method is now just 2-3 lines - no filtering, no loops!

  @override
  Future<List<DailyPlanModel>> fetchDailyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredDailyPlans = false,
  }) async {
    final categorized = await _ensureCategorizedPlansLoaded();
    return categorized.getDailyPlans();
  }

  @override
  Future<List<WeeklyPlanModel>> fetchWeeklyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredWeeklyPlans = false,
  }) async {
    final categorized = await _ensureCategorizedPlansLoaded();
    return categorized.getWeeklyPlans();
  }

  @override
  Future<List<MonthlyPlanModel>> fetchMonthlyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMonthlyPlans = false,
  }) async {
    final categorized = await _ensureCategorizedPlansLoaded();
    return categorized.getMonthlyPlans();
  }

  @override
  Future<List<RoamingPlanModel>> fetchRoamingPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamingPlans = false,
  }) async {
    final categorized = await _ensureCategorizedPlansLoaded();
    return categorized.getRoamingPlans();
  }

  @override
  Future<List<RoamEasyPlanModel>> fetchRoamEasyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamEasyPlans = false,
  }) async {
    final categorized = await _ensureCategorizedPlansLoaded();
    return categorized.getRoamEasyPlans();
  }

  @override
  Future<List<MifiPlanModel>> fetchMifiPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMifiPlans = false,
  }) async {
    final categorized = await _ensureCategorizedPlansLoaded();
    return categorized.getMifiPlans();
  }

  @override
  Future<List<LibertyGlobalPlanModel>> fetchLibertyGlobalPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredLibertyGlobalPlans = false,
  }) async {
    final categorized = await _ensureCategorizedPlansLoaded();
    return categorized.getLibertyGlobalPlans();
  }

  @override
  Future<List<HomePlansPostPaidPlanModel>> fetchPostpaidRoamingPlansFromApi({
    bool printRawResponse = false,
  }) async {
    final categorized = await _ensureCategorizedPlansLoaded();
    return categorized.getPostpaidRoamingPlans();
  }
}
```

**Look at how simple each fetch method is now!** Just 2 lines:
1. Ensure categorized plans are loaded (from cache or API)
2. Return the pre-categorized list

---

## Comparison: Before vs After

### Before (Current - Multi-Pass Filtering)
```dart
// Called when user opens Daily tab
fetchDailyPlansFromApi() {
  plans = cache.getRawPlans();           // 100 items
  filtered = filterBy(type='P', freq='D'); // Loop 100 items
  models = filtered.map(...);            // Loop X items
  cache.setDailyPlans(models);
  return models;
}

// Called when user opens Weekly tab
fetchWeeklyPlansFromApi() {
  plans = cache.getRawPlans();           // 100 items (SAME DATA)
  filtered = filterBy(type='P', freq='W'); // Loop 100 items AGAIN
  models = filtered.map(...);            // Loop Y items
  cache.setWeeklyPlans(models);
  return models;
}

// ... repeat 6 more times
// Total loops through raw data: 8 times (wasteful!)
```

**Complexity**: O(n × m) where n=plans, m=plan types

### After (New - Single-Pass Categorization)
```dart
// Called ONCE when first tab is opened
_ensureCategorizedPlansLoaded() {
  if (cache.hasCategorized()) return cache.get();

  rawPlans = api.fetch();                    // 100 items
  categorized = parseAndCategorize(rawPlans); // Loop 100 items ONCE
  // ^ This single loop categorizes ALL plan types
  cache.set(categorized);
  return categorized;
}

// Called when user opens Daily tab
fetchDailyPlansFromApi() {
  categorized = _ensureCategorizedPlansLoaded(); // From cache (instant)
  return categorized.getDailyPlans();            // Just map lookup (instant)
}

// Called when user opens Weekly tab
fetchWeeklyPlansFromApi() {
  categorized = _ensureCategorizedPlansLoaded(); // From cache (instant)
  return categorized.getWeeklyPlans();           // Just map lookup (instant)
}

// ... all other tabs are equally fast
// Total loops through raw data: 1 time (efficient!)
```

**Complexity**: O(n) - single pass through data

---

## Performance Improvements

### Time Complexity Analysis

| Scenario | Before | After | Improvement |
|----------|--------|-------|-------------|
| Fetch 1 plan type | O(n) | O(n) | Same |
| Fetch 3 plan types | O(3n) | O(n) | **3x faster** |
| Fetch all 8 types | O(8n) | O(n) | **8x faster** |
| Switch tabs 10 times | O(8n × 10) | O(n) | **80x faster** |

### Real-World Example

Assume 100 plans total:
- **Before**: User opens 3 tabs (Daily, Weekly, Roaming)
  - Loop 1: Scan 100 items for Daily → 10 found
  - Loop 2: Scan 100 items for Weekly → 5 found
  - Loop 3: Scan 100 items for Roaming → 8 found
  - **Total operations**: 300 plan scans

- **After**: User opens 3 tabs
  - Loop 1 (on first tab): Scan 100 items, categorize ALL → All categories filled
  - Tab 2: Map lookup (instant)
  - Tab 3: Map lookup (instant)
  - **Total operations**: 100 plan scans
  - **Savings**: 66% reduction in operations

---

## Additional Improvements

### 1. Use Enums for Type Safety

Instead of hardcoded strings in categorizer, use enums:

```dart
// In categorize() method:
final planType = PlanType.fromString(plan['PlanType']);
final frequency = PlanFrequency.fromString(plan['Frequency']);
final planGroup = PlanGroup.fromString(plan['PlanGroup']);

if (planType == PlanType.primary) {
  if (frequency == PlanFrequency.daily) return PlanCategory.daily;
  if (frequency == PlanFrequency.weekly) return PlanCategory.weekly;
  // ...
}
```

### 2. Add Diagnostic Logging

Track categorization statistics:

```dart
class CategorizedPlans {
  // ... existing code ...

  /// Get diagnostic info
  Map<String, int> getCategoryCounts() {
    return {
      for (final category in PlanCategory.values)
        category.name: typedPlans[category]?.length ?? 0,
    };
  }

  void printDiagnostics() {
    print('=== Categorized Plans ===');
    print('Total raw plans: ${rawPlans.values.fold(0, (sum, list) => sum + list.length)}');
    for (final entry in getCategoryCounts().entries) {
      print('  ${entry.key}: ${entry.value}');
    }
  }
}
```

### 3. Handle Edge Cases

```dart
class PlanCategorizer {
  // ... existing code ...

  /// Validate that a plan has minimum required fields
  bool isValidPlan(Map<String, dynamic> plan) {
    return plan.containsKey('PlanType') &&
           plan.containsKey('PlanId') &&
           plan['PlanType'] != null;
  }

  /// Get categorization confidence score
  double getConfidence(Map<String, dynamic> plan, PlanCategory category) {
    // Return 1.0 for exact matches, 0.5 for partial matches, 0.0 for no match
    // Useful for debugging categorization issues
  }
}
```

---

## Migration Strategy

### Phase 1: Add New Infrastructure (Non-Breaking)
1. ✅ Create `plan_category.dart` (enum for categories)
2. ✅ Create `plan_categorizer.dart` (categorization logic)
3. ✅ Create `categorized_plans.dart` (container)
4. ✅ Create `plan_parser_v2.dart` (single-pass parser)
5. ✅ Create `plan_cache_v2.dart` (categorized cache)

### Phase 2: Implement New Repository (Parallel)
1. ✅ Create `home_plan_repository_v3.dart`
2. ✅ Implement all fetch methods using categorized approach
3. ✅ Write unit tests

### Phase 3: Switch Over
1. ✅ Update dependency injection to use V3 instead of V2
2. ✅ Run integration tests
3. ✅ Monitor performance

### Phase 4: Cleanup (Future)
1. ✅ Remove old filter service (no longer needed)
2. ✅ Remove old cache implementation
3. ✅ Remove V2 repository

---

## File Structure

```
lib/app/Plans/PlanScreen/repository/
├── plan_enums.dart                    # NEW: Enums for type safety
├── plan_category.dart                 # NEW: Category enum
├── plan_filter_criteria.dart          # NEW: (optional, for manual filtering)
├── services/
│   ├── plan_categorizer.dart         # NEW: Categorization logic
│   ├── plan_parser_v2.dart           # NEW: Single-pass parser
│   ├── categorized_plans.dart        # NEW: Container for categorized data
│   ├── plan_cache_v2.dart            # NEW: Cache for categorized plans
│   ├── plan_filter_service.dart      # DEPRECATED: Keep for backward compat
│   ├── plan_cache.dart               # DEPRECATED: Old cache
│   └── ...
├── home_plan_repository_v2.dart      # OLD: Current implementation
└── home_plan_repository_v3.dart      # NEW: Optimized implementation
```

---

## Benefits Summary

### Performance
- ✅ **8x faster** when fetching all plan types
- ✅ **O(n) instead of O(n×m)** complexity
- ✅ **Instant retrieval** after first categorization
- ✅ **Cache-friendly**: Store pre-categorized results

### Code Quality
- ✅ **Simpler fetch methods**: 17 lines → 2-3 lines each
- ✅ **Single responsibility**: Categorizer handles categorization, Parser handles parsing
- ✅ **Type safety**: Enums instead of hardcoded strings
- ✅ **Maintainable**: Add new category by adding enum value + case in categorizer

### User Experience
- ✅ **Faster tab switching**: No re-filtering on every tab switch
- ✅ **Smoother UI**: Less CPU usage = better battery life
- ✅ **Scalable**: Performance doesn't degrade as plan count grows

---

## Implementation Checklist

- [ ] Create enums (`plan_enums.dart`, `plan_category.dart`)
- [ ] Create categorizer service (`plan_categorizer.dart`)
- [ ] Create categorized container (`categorized_plans.dart`)
- [ ] Create single-pass parser (`plan_parser_v2.dart`)
- [ ] Create new cache (`plan_cache_v2.dart`)
- [ ] Create new repository (`home_plan_repository_v3.dart`)
- [ ] Write unit tests for categorizer
- [ ] Write unit tests for parser
- [ ] Write integration tests for repository
- [ ] Performance benchmark (before vs after)
- [ ] Update dependency injection
- [ ] Test with real data
- [ ] Monitor production performance
- [ ] Deprecate old implementation
- [ ] Clean up deprecated code (future)

---

## Conclusion

This refactoring transforms the plan repository from a **multi-pass filtering approach** to a **single-pass categorization approach**:

**Before**: Filter → Parse → Filter → Parse → Filter → Parse (8 times)
**After**: Categorize + Parse (once) → Retrieve (instant)

**Key Innovation**: "Group while parsing" instead of "parse then filter repeatedly"

This is a classic example of the **"do it once, use many times"** optimization pattern.
