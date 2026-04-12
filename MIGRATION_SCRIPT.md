# Plan Models Migration Script

## Overview
This script details all changes needed to migrate from 8 separate plan models to the unified `BasePlanModel`.

**Impact:** 21 files need updates
**Effort:** ~2-3 days for full migration + testing
**Risk:** Low (field names unchanged, only type references change)

---

## Quick Stats

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Model files | 10 | 3 | -7 files |
| Total lines (models) | 3,896 | 539 | -86.2% |
| Files to update | - | 21 | Migration work |
| Dead code removed | - | ~160 lines | Cleanup |

---

## Migration Checklist

### Phase 1: Repository Layer ✅
- [ ] 1.1 `services/plan_model_factory.dart` - Simplify factory logic
- [ ] 1.2 `services/plan_cache.dart` - Update cache types
- [ ] 1.3 `models/plan_categorization_result.dart` - Update cast types
- [ ] 1.4 `base_plan_repository.dart` - Update return types
- [ ] 1.5 `home_plan_repository_v2.dart` - Update return types + factory calls
- [ ] 1.6 `mock_plan_repository.dart` - Update return types

### Phase 2: BLoC/State Layer ✅
- [ ] 2.1 `cubit/home_plan_state.dart` - Update field types
- [ ] 2.2 `cubit/home_plan_cubit.dart` - Update type references
- [ ] 2.3 `cubit/plans_state.dart` - Update type references

### Phase 3: UI Layer - Widgets ✅
- [ ] 3.1 `widgets/daily_plan_card.dart`
- [ ] 3.2 `widgets/weekly_plan_card.dart`
- [ ] 3.3 `widgets/monthly_plan_card.dart`
- [ ] 3.4 `widgets/roaming_plan_card.dart`
- [ ] 3.5 `widgets/roameasy_plan_card.dart`
- [ ] 3.6 `widgets/mifi_plan_card.dart`
- [ ] 3.7 `widgets/liberty_global_plan_card.dart`
- [ ] 3.8 `widgets/home_plan_add_ons_tab_content.dart`
- [ ] 3.9 `widgets/home_plan_plans_list.dart`

### Phase 4: UI Layer - Views ✅
- [ ] 4.1 `view/home_plan_screen.dart`

### Phase 5: Cleanup ✅
- [ ] 5.1 Delete `models/daily_plan_model.dart`
- [ ] 5.2 Delete `models/weekly_plan_model.dart`
- [ ] 5.3 Delete `models/monthly_plan_model.dart`
- [ ] 5.4 Delete `models/roaming_plan_model.dart`
- [ ] 5.5 Delete `models/roameasy_plan_model.dart`
- [ ] 5.6 Delete `models/mifi_plan_model.dart`
- [ ] 5.7 Delete `models/liberty_global_plan_model.dart`
- [ ] 5.8 Delete `models/add_ons_primary_plan_model.dart`

### Phase 6: Verification ✅
- [ ] 6.1 Run `flutter analyze` - No errors
- [ ] 6.2 Run `flutter test` - All tests pass
- [ ] 6.3 Manual QA - Test all plan types
- [ ] 6.4 Verify date formatting works correctly
- [ ] 6.5 Final commit

---

## Detailed Changes by File

---

## PHASE 1: Repository Layer

### 1.1 `services/plan_model_factory.dart`

**Impact:** MAJOR SIMPLIFICATION (150 lines → 20 lines)

#### Before:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

class PlanModelFactory {
  dynamic createModel({
    required Map<String, dynamic> rawPlan,
    required PlanCategory category,
    bool includeRawPayload = false,
  }) {
    switch (category) {
      case PlanCategory.daily:
        return _createDailyPlan(rawPlan, includeRawPayload);
      case PlanCategory.weekly:
        return _createWeeklyPlan(rawPlan, includeRawPayload);
      case PlanCategory.monthly:
        return _createMonthlyPlan(rawPlan, includeRawPayload);
      case PlanCategory.roaming:
        return _createRoamingPlan(rawPlan, includeRawPayload);
      case PlanCategory.roameasy:
        return _createRoamEasyPlan(rawPlan, includeRawPayload);
      case PlanCategory.mifi:
        return _createMifiPlan(rawPlan, includeRawPayload);
      case PlanCategory.libertyGlobal:
        return _createLibertyGlobalPlan(rawPlan, includeRawPayload);
      case PlanCategory.postpaidRoaming:
        return _createPostpaidRoamingPlan(rawPlan, includeRawPayload);
      case PlanCategory.unknown:
        return null;
    }
  }

  DailyPlanModel _createDailyPlan(Map<String, dynamic> raw, bool includePayload) {
    try {
      return DailyPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse daily plan: $e');
    }
  }

  WeeklyPlanModel _createWeeklyPlan(Map<String, dynamic> raw, bool includePayload) {
    try {
      return WeeklyPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse weekly plan: $e');
    }
  }

  MonthlyPlanModel _createMonthlyPlan(Map<String, dynamic> raw, bool includePayload) {
    try {
      return MonthlyPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse monthly plan: $e');
    }
  }

  RoamingPlanModel _createRoamingPlan(Map<String, dynamic> raw, bool includePayload) {
    try {
      return RoamingPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse roaming plan: $e');
    }
  }

  RoamEasyPlanModel _createRoamEasyPlan(Map<String, dynamic> raw, bool includePayload) {
    try {
      return RoamEasyPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse RoamEasy plan: $e');
    }
  }

  MifiPlanModel _createMifiPlan(Map<String, dynamic> raw, bool includePayload) {
    try {
      return MifiPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse MiFi plan: $e');
    }
  }

  LibertyGlobalPlanModel _createLibertyGlobalPlan(Map<String, dynamic> raw, bool includePayload) {
    try {
      return LibertyGlobalPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse Liberty Global plan: $e');
    }
  }

  HomePlansPostPaidPlanModel _createPostpaidRoamingPlan(Map<String, dynamic> raw, bool includePayload) {
    try {
      return HomePlansPostPaidPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse Postpaid Roaming plan: $e');
    }
  }
}
```

#### After:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Factory for creating typed plan models from raw maps
class PlanModelFactory {
  /// Create a typed model based on plan category
  dynamic createModel({
    required Map<String, dynamic> rawPlan,
    required PlanCategory category,
    bool includeRawPayload = false,
  }) {
    // All prepaid plan types use the same BasePlanModel now
    switch (category) {
      case PlanCategory.daily:
      case PlanCategory.weekly:
      case PlanCategory.monthly:
      case PlanCategory.roaming:
      case PlanCategory.roameasy:
      case PlanCategory.mifi:
      case PlanCategory.libertyGlobal:
        return _createBasePlan(rawPlan, includeRawPayload);

      case PlanCategory.postpaidRoaming:
        return _createPostpaidRoamingPlan(rawPlan, includeRawPayload);

      case PlanCategory.unknown:
        return null; // Don't parse unknown plans
    }
  }

  /// Create base plan model (used for all prepaid plan types)
  BasePlanModel _createBasePlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return BasePlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse plan: $e');
    }
  }

  /// Create Postpaid Roaming plan model (different structure)
  HomePlansPostPaidPlanModel _createPostpaidRoamingPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return HomePlansPostPaidPlanModel.fromApiMap(
        raw,
        includeRawPayload: includePayload,
      );
    } catch (e) {
      throw FormatException('Failed to parse Postpaid Roaming plan: $e');
    }
  }
}
```

**Changes:**
- ❌ Remove 7 model imports (daily, weekly, monthly, roaming, roameasy, mifi, liberty_global)
- ✅ Add 1 import: `base_plan_model.dart`
- ❌ Delete 7 `_create*Plan` methods (130 lines)
- ✅ Add 1 unified `_createBasePlan` method
- ✅ Simplify switch statement (7 cases → 1 unified case)

**Line reduction:** 150 lines → 45 lines (70% reduction)

---

### 1.2 `services/plan_cache.dart`

**Impact:** MODERATE (Type changes only)

#### Before:
```dart
import '../../models/daily_plan_model.dart';
import '../../models/weekly_plan_model.dart';
import '../../models/monthly_plan_model.dart';
import '../../models/roaming_plan_model.dart';
import '../../models/roameasy_plan_model.dart';
import '../../models/mifi_plan_model.dart';
import '../../models/liberty_global_plan_model.dart';
import '../../models/add_ons_primary_plan_model.dart';

class PlanCache {
  final CacheEntry<List<DailyPlanModel>> _dailyPlansCache = CacheEntry();
  final CacheEntry<List<WeeklyPlanModel>> _weeklyPlansCache = CacheEntry();
  final CacheEntry<List<MonthlyPlanModel>> _monthlyPlansCache = CacheEntry();
  final CacheEntry<List<RoamingPlanModel>> _roamingPlansCache = CacheEntry();
  final CacheEntry<List<RoamEasyPlanModel>> _roamEasyPlansCache = CacheEntry();
  final CacheEntry<List<MifiPlanModel>> _mifiPlansCache = CacheEntry();
  final CacheEntry<List<LibertyGlobalPlanModel>> _libertyGlobalPlansCache = CacheEntry();
  final CacheEntry<List<AddOnsPrimaryPlanModel>> _addOnsPrimaryPlansCache = CacheEntry();

  // Getters/Setters for each type
  void setDailyPlans(List<DailyPlanModel> plans) => _dailyPlansCache.set(plans);
  List<DailyPlanModel> getDailyPlans() => _dailyPlansCache.get() ?? [];

  void setWeeklyPlans(List<WeeklyPlanModel> plans) => _weeklyPlansCache.set(plans);
  List<WeeklyPlanModel> getWeeklyPlans() => _weeklyPlansCache.get() ?? [];

  void setMonthlyPlans(List<MonthlyPlanModel> plans) => _monthlyPlansCache.set(plans);
  List<MonthlyPlanModel> getMonthlyPlans() => _monthlyPlansCache.get() ?? [];

  void setRoamingPlans(List<RoamingPlanModel> plans) => _roamingPlansCache.set(plans);
  List<RoamingPlanModel> getRoamingPlans() => _roamingPlansCache.get() ?? [];

  void setRoamEasyPlans(List<RoamEasyPlanModel> plans) => _roamEasyPlansCache.set(plans);
  List<RoamEasyPlanModel> getRoamEasyPlans() => _roamEasyPlansCache.get() ?? [];

  void setMifiPlans(List<MifiPlanModel> plans) => _mifiPlansCache.set(plans);
  List<MifiPlanModel> getMifiPlans() => _mifiPlansCache.get() ?? [];

  void setLibertyGlobalPlans(List<LibertyGlobalPlanModel> plans) => _libertyGlobalPlansCache.set(plans);
  List<LibertyGlobalPlanModel> getLibertyGlobalPlans() => _libertyGlobalPlansCache.get() ?? [];

  void setAddOnsPrimaryPlans(List<AddOnsPrimaryPlanModel> plans) => _addOnsPrimaryPlansCache.set(plans);
  List<AddOnsPrimaryPlanModel> getAddOnsPrimaryPlans() => _addOnsPrimaryPlansCache.get() ?? [];

  // ... rest of the class
}
```

#### After:
```dart
import '../../models/base_plan_model.dart';

class PlanCache {
  final CacheEntry<List<BasePlanModel>> _dailyPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _weeklyPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _monthlyPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _roamingPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _roamEasyPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _mifiPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _libertyGlobalPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _addOnsPrimaryPlansCache = CacheEntry();

  // Getters/Setters for each type
  void setDailyPlans(List<BasePlanModel> plans) => _dailyPlansCache.set(plans);
  List<BasePlanModel> getDailyPlans() => _dailyPlansCache.get() ?? [];

  void setWeeklyPlans(List<BasePlanModel> plans) => _weeklyPlansCache.set(plans);
  List<BasePlanModel> getWeeklyPlans() => _weeklyPlansCache.get() ?? [];

  void setMonthlyPlans(List<BasePlanModel> plans) => _monthlyPlansCache.set(plans);
  List<BasePlanModel> getMonthlyPlans() => _monthlyPlansCache.get() ?? [];

  void setRoamingPlans(List<BasePlanModel> plans) => _roamingPlansCache.set(plans);
  List<BasePlanModel> getRoamingPlans() => _roamingPlansCache.get() ?? [];

  void setRoamEasyPlans(List<BasePlanModel> plans) => _roamEasyPlansCache.set(plans);
  List<BasePlanModel> getRoamEasyPlans() => _roamEasyPlansCache.get() ?? [];

  void setMifiPlans(List<BasePlanModel> plans) => _mifiPlansCache.set(plans);
  List<BasePlanModel> getMifiPlans() => _mifiPlansCache.get() ?? [];

  void setLibertyGlobalPlans(List<BasePlanModel> plans) => _libertyGlobalPlansCache.set(plans);
  List<BasePlanModel> getLibertyGlobalPlans() => _libertyGlobalPlansCache.get() ?? [];

  void setAddOnsPrimaryPlans(List<BasePlanModel> plans) => _addOnsPrimaryPlansCache.set(plans);
  List<BasePlanModel> getAddOnsPrimaryPlans() => _addOnsPrimaryPlansCache.get() ?? [];

  // ... rest of the class (unchanged)
}
```

**Changes:**
- ❌ Remove 8 model imports
- ✅ Add 1 import: `base_plan_model.dart`
- 🔄 Replace all type references: `*PlanModel` → `BasePlanModel`

**Search & Replace:**
```bash
# In plan_cache.dart:
DailyPlanModel → BasePlanModel
WeeklyPlanModel → BasePlanModel
MonthlyPlanModel → BasePlanModel
RoamingPlanModel → BasePlanModel
RoamEasyPlanModel → BasePlanModel
MifiPlanModel → BasePlanModel
LibertyGlobalPlanModel → BasePlanModel
AddOnsPrimaryPlanModel → BasePlanModel
```

---

### 1.3 `models/plan_categorization_result.dart`

**Impact:** MODERATE (Type changes + casts)

#### Before:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

class PlanCategorizationResult {
  // ... constructor ...

  /// Get daily plans (typed)
  List<DailyPlanModel> get dailyPlans =>
      (categorizedPlans[PlanCategory.daily] ?? []).cast<DailyPlanModel>();

  /// Get weekly plans (typed)
  List<WeeklyPlanModel> get weeklyPlans =>
      (categorizedPlans[PlanCategory.weekly] ?? []).cast<WeeklyPlanModel>();

  /// Get monthly plans (typed)
  List<MonthlyPlanModel> get monthlyPlans =>
      (categorizedPlans[PlanCategory.monthly] ?? []).cast<MonthlyPlanModel>();

  /// Get roaming plans (typed)
  List<RoamingPlanModel> get roamingPlans =>
      (categorizedPlans[PlanCategory.roaming] ?? []).cast<RoamingPlanModel>();

  /// Get RoamEasy plans (typed)
  List<RoamEasyPlanModel> get roamEasyPlans =>
      (categorizedPlans[PlanCategory.roameasy] ?? []).cast<RoamEasyPlanModel>();

  /// Get MiFi plans (typed)
  List<MifiPlanModel> get mifiPlans =>
      (categorizedPlans[PlanCategory.mifi] ?? []).cast<MifiPlanModel>();

  /// Get Liberty Global plans (typed)
  List<LibertyGlobalPlanModel> get libertyGlobalPlans =>
      (categorizedPlans[PlanCategory.libertyGlobal] ?? []).cast<LibertyGlobalPlanModel>();

  /// Get Postpaid Roaming plans (typed)
  List<HomePlansPostPaidPlanModel> get postpaidRoamingPlans =>
      (categorizedPlans[PlanCategory.postpaidRoaming] ?? []).cast<HomePlansPostPaidPlanModel>();

  // ... rest of methods ...
}
```

#### After:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

class PlanCategorizationResult {
  // ... constructor (unchanged) ...

  /// Get daily plans (typed)
  List<BasePlanModel> get dailyPlans =>
      (categorizedPlans[PlanCategory.daily] ?? []).cast<BasePlanModel>();

  /// Get weekly plans (typed)
  List<BasePlanModel> get weeklyPlans =>
      (categorizedPlans[PlanCategory.weekly] ?? []).cast<BasePlanModel>();

  /// Get monthly plans (typed)
  List<BasePlanModel> get monthlyPlans =>
      (categorizedPlans[PlanCategory.monthly] ?? []).cast<BasePlanModel>();

  /// Get roaming plans (typed)
  List<BasePlanModel> get roamingPlans =>
      (categorizedPlans[PlanCategory.roaming] ?? []).cast<BasePlanModel>();

  /// Get RoamEasy plans (typed)
  List<BasePlanModel> get roamEasyPlans =>
      (categorizedPlans[PlanCategory.roameasy] ?? []).cast<BasePlanModel>();

  /// Get MiFi plans (typed)
  List<BasePlanModel> get mifiPlans =>
      (categorizedPlans[PlanCategory.mifi] ?? []).cast<BasePlanModel>();

  /// Get Liberty Global plans (typed)
  List<BasePlanModel> get libertyGlobalPlans =>
      (categorizedPlans[PlanCategory.libertyGlobal] ?? []).cast<BasePlanModel>();

  /// Get Postpaid Roaming plans (typed)
  List<HomePlansPostPaidPlanModel> get postpaidRoamingPlans =>
      (categorizedPlans[PlanCategory.postpaidRoaming] ?? []).cast<HomePlansPostPaidPlanModel>();

  // ... rest of methods (unchanged) ...
}
```

**Changes:**
- ❌ Remove 7 model imports
- ✅ Add 1 import: `base_plan_model.dart`
- 🔄 Replace all cast types (7 occurrences)

**Search & Replace:**
```bash
cast<DailyPlanModel>() → cast<BasePlanModel>()
cast<WeeklyPlanModel>() → cast<BasePlanModel>()
cast<MonthlyPlanModel>() → cast<BasePlanModel>()
cast<RoamingPlanModel>() → cast<BasePlanModel>()
cast<RoamEasyPlanModel>() → cast<BasePlanModel>()
cast<MifiPlanModel>() → cast<BasePlanModel>()
cast<LibertyGlobalPlanModel>() → cast<BasePlanModel>()
```

---

### 1.4 `base_plan_repository.dart`

**Impact:** LOW (Interface changes only)

#### Before:
```dart
import '../models/daily_plan_model.dart';
import '../models/weekly_plan_model.dart';
import '../models/monthly_plan_model.dart';
import '../models/roaming_plan_model.dart';
import '../models/roameasy_plan_model.dart';
import '../models/mifi_plan_model.dart';
import '../models/liberty_global_plan_model.dart';
import '../models/add_ons_primary_plan_model.dart';

abstract class BasePlanRepository {
  Future<List<DailyPlanModel>> fetchDailyPlansFromApi();
  Future<List<WeeklyPlanModel>> fetchWeeklyPlansFromApi();
  Future<List<MonthlyPlanModel>> fetchMonthlyPlansFromApi();
  Future<List<RoamingPlanModel>> fetchRoamingPlansFromApi();
  Future<List<RoamEasyPlanModel>> fetchRoamEasyPlansFromApi();
  Future<List<MifiPlanModel>> fetchMifiPlansFromApi();
  Future<List<LibertyGlobalPlanModel>> fetchLibertyGlobalPlansFromApi();
  Future<List<AddOnsPrimaryPlanModel>> fetchAddOnsPrimaryPlansFromApi({...});

  AddOnsPrimaryPlanModel? selectEarliestAddOnsPrimaryPlan(List<AddOnsPrimaryPlanModel> primaryPlans);

  List<HomePlanAddOnModel> buildAddOnList({required AddOnsPrimaryPlanModel primaryPlan});

  List<DailyPlanModel> get lastFetchedDailyPlans;
  List<WeeklyPlanModel> get lastFetchedWeeklyPlans;
  List<MonthlyPlanModel> get lastFetchedMonthlyPlans;
  List<RoamingPlanModel> get lastFetchedRoamingPlans;
  List<RoamEasyPlanModel> get lastFetchedRoamEasyPlans;
  List<MifiPlanModel> get lastFetchedMifiPlans;
  List<LibertyGlobalPlanModel> get lastFetchedLibertyGlobalPlans;
  List<AddOnsPrimaryPlanModel> get lastFetchedAddOnsPrimaryPlans;
}
```

#### After:
```dart
import '../models/base_plan_model.dart';

abstract class BasePlanRepository {
  Future<List<BasePlanModel>> fetchDailyPlansFromApi();
  Future<List<BasePlanModel>> fetchWeeklyPlansFromApi();
  Future<List<BasePlanModel>> fetchMonthlyPlansFromApi();
  Future<List<BasePlanModel>> fetchRoamingPlansFromApi();
  Future<List<BasePlanModel>> fetchRoamEasyPlansFromApi();
  Future<List<BasePlanModel>> fetchMifiPlansFromApi();
  Future<List<BasePlanModel>> fetchLibertyGlobalPlansFromApi();
  Future<List<BasePlanModel>> fetchAddOnsPrimaryPlansFromApi({...});

  BasePlanModel? selectEarliestAddOnsPrimaryPlan(List<BasePlanModel> primaryPlans);

  List<HomePlanAddOnModel> buildAddOnList({required BasePlanModel primaryPlan});

  List<BasePlanModel> get lastFetchedDailyPlans;
  List<BasePlanModel> get lastFetchedWeeklyPlans;
  List<BasePlanModel> get lastFetchedMonthlyPlans;
  List<BasePlanModel> get lastFetchedRoamingPlans;
  List<BasePlanModel> get lastFetchedRoamEasyPlans;
  List<BasePlanModel> get lastFetchedMifiPlans;
  List<BasePlanModel> get lastFetchedLibertyGlobalPlans;
  List<BasePlanModel> get lastFetchedAddOnsPrimaryPlans;
}
```

**Changes:**
- ❌ Remove 8 model imports
- ✅ Add 1 import: `base_plan_model.dart`
- 🔄 Replace all type references

---

### 1.5 `home_plan_repository_v2.dart`

**Impact:** MODERATE (Many method signatures)

**Changes needed:**
1. Update imports (8 → 1)
2. Update all method return types
3. Update internal type references
4. Update factory method calls

**Example changes:**

```dart
// Before
Future<List<DailyPlanModel>> fetchDailyPlansFromApi({bool forceRefresh = false}) async {
  // ...
  return result.dailyPlans.map((item) => DailyPlanModel.fromApiMap(item)).toList();
}

// After
Future<List<BasePlanModel>> fetchDailyPlansFromApi({bool forceRefresh = false}) async {
  // ...
  return result.dailyPlans.map((item) => BasePlanModel.fromApiMap(item)).toList();
}
```

Apply this pattern to all 8 `fetch*PlansFromApi` methods.

---

### 1.6 `mock_plan_repository.dart`

**Impact:** MODERATE (Test data creation)

Similar to `home_plan_repository_v2.dart`, update:
- Imports
- Return types
- Mock data factory methods

---

## PHASE 2: BLoC/State Layer

### 2.1 `cubit/home_plan_state.dart`

**Impact:** HIGH (Core state model)

#### Before:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_ons_primary_plan_model.dart';

class HomePlanState {
  // ... other fields ...

  final List<AddOnsPrimaryPlanModel> addOnsApiPrimaryPlans;
  final List<DailyPlanModel> dailyApiPlans;
  final List<WeeklyPlanModel> weeklyApiPlans;
  final List<MonthlyPlanModel> monthlyApiPlans;
  final List<RoamingPlanModel> roamingApiPlans;
  final List<RoamEasyPlanModel> roameasyApiPlans;
  final List<MifiPlanModel> mifiApiPlans;
  final List<LibertyGlobalPlanModel> libertyGlobalApiPlans;

  // ... methods ...

  AddOnsPrimaryPlanModel? get earliestAddOnsPrimaryPlan {
    if (addOnsApiPrimaryPlans.isEmpty) return null;
    return addOnsApiPrimaryPlans.first;
  }
}
```

#### After:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

class HomePlanState {
  // ... other fields (unchanged) ...

  final List<BasePlanModel> addOnsApiPrimaryPlans;
  final List<BasePlanModel> dailyApiPlans;
  final List<BasePlanModel> weeklyApiPlans;
  final List<BasePlanModel> monthlyApiPlans;
  final List<BasePlanModel> roamingApiPlans;
  final List<BasePlanModel> roameasyApiPlans;
  final List<BasePlanModel> mifiApiPlans;
  final List<BasePlanModel> libertyGlobalApiPlans;

  // ... methods (unchanged logic) ...

  BasePlanModel? get earliestAddOnsPrimaryPlan {
    if (addOnsApiPrimaryPlans.isEmpty) return null;
    return addOnsApiPrimaryPlans.first;
  }
}
```

**Changes:**
- ❌ Remove 8 model imports
- ✅ Add 1 import: `base_plan_model.dart`
- 🔄 Replace 8 field types
- 🔄 Update getter return type

---

### 2.2 `cubit/home_plan_cubit.dart`

**Impact:** MODERATE (Type references)

#### Before:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_ons_primary_plan_model.dart';

class HomePlanCubit extends Cubit<HomePlanState> {
  Future<void> _loadAddOnsTab() async {
    try {
      final List<AddOnsPrimaryPlanModel> primaryPlans = await repository.fetchAddOnsPrimaryPlansFromApi();
      final AddOnsPrimaryPlanModel? selectedPrimaryPlan = repository.selectEarliestAddOnsPrimaryPlan(primaryPlans);
      // ...
    } catch (e) {
      // ...
    }
  }

  // Similar patterns for other methods
}
```

#### After:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

class HomePlanCubit extends Cubit<HomePlanState> {
  Future<void> _loadAddOnsTab() async {
    try {
      final List<BasePlanModel> primaryPlans = await repository.fetchAddOnsPrimaryPlansFromApi();
      final BasePlanModel? selectedPrimaryPlan = repository.selectEarliestAddOnsPrimaryPlan(primaryPlans);
      // ... (rest unchanged)
    } catch (e) {
      // ...
    }
  }

  // Similar patterns for other methods
}
```

**Changes:**
- ❌ Remove 8 model imports
- ✅ Add 1 import: `base_plan_model.dart`
- 🔄 Replace local variable types throughout methods

---

### 2.3 `cubit/plans_state.dart`

**Impact:** LOW (Similar to home_plan_state.dart)

Apply same pattern as 2.1 - update imports and field types.

---

## PHASE 3: UI Layer - Widgets

### 3.1-3.7 Widget Card Files (Pattern for all 7 cards)

All card widgets follow the same pattern. Here's the template:

#### Before (Example: `daily_plan_card.dart`):
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';

class DailyPlanCard extends StatelessWidget {
  const DailyPlanCard({
    super.key,
    required this.plan,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  final DailyPlanModel plan;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(plan.planName),
        Text('\$${plan.planAmount}'),
        if (plan.startDateTime != null)
          Text(formatDate(plan.startDateTime!)),
        // ... rest of UI
      ],
    );
  }
}
```

#### After:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

class DailyPlanCard extends StatelessWidget {
  const DailyPlanCard({
    super.key,
    required this.plan,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  final BasePlanModel plan;  // ← Only this line changes
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(plan.planName),  // ← Field access unchanged
        Text('\$${plan.planAmount}'),  // ← Field access unchanged
        if (plan.startDateTime != null)  // ← Getter access unchanged
          Text(formatDate(plan.startDateTime!)),
        // ... rest of UI (unchanged)
      ],
    );
  }
}
```

**Apply this pattern to all 7 card files:**
1. `daily_plan_card.dart` - `DailyPlanModel` → `BasePlanModel`
2. `weekly_plan_card.dart` - `WeeklyPlanModel` → `BasePlanModel`
3. `monthly_plan_card.dart` - `MonthlyPlanModel` → `BasePlanModel`
4. `roaming_plan_card.dart` - `RoamingPlanModel` → `BasePlanModel`
5. `roameasy_plan_card.dart` - `RoamEasyPlanModel` → `BasePlanModel`
6. `mifi_plan_card.dart` - `MifiPlanModel` → `BasePlanModel`
7. `liberty_global_plan_card.dart` - `LibertyGlobalPlanModel` → `BasePlanModel`

**Changes per file:**
- ❌ Remove old model import
- ✅ Add base_plan_model import
- 🔄 Change parameter type (1 line)
- ✅ UI code unchanged (field names identical)

---

### 3.8 `widgets/home_plan_add_ons_tab_content.dart`

#### Before:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_ons_primary_plan_model.dart';

class HomePlanAddOnsTabContent extends StatelessWidget {
  final AddOnsPrimaryPlanModel? activePrimaryPlan;
  // ...
}
```

#### After:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

class HomePlanAddOnsTabContent extends StatelessWidget {
  final BasePlanModel? activePrimaryPlan;
  // ...
}
```

---

### 3.9 `widgets/home_plan_plans_list.dart`

**Impact:** MODERATE (Multiple imports)

#### Before:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';

class HomePlanPlansList extends StatelessWidget {
  // ... uses all 7 plan types
}
```

#### After:
```dart
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

class HomePlanPlansList extends StatelessWidget {
  // ... (no other changes needed)
}
```

---

## PHASE 4: UI Layer - Views

### 4.1 `view/home_plan_screen.dart`

#### Before:
```dart
import '../models/liberty_global_plan_model.dart';
import '../models/mifi_plan_model.dart';
import '../models/roameasy_plan_model.dart';
import '../models/roaming_plan_model.dart';

class HomePlanScreen extends StatelessWidget {
  // ... uses some plan types
}
```

#### After:
```dart
import '../models/base_plan_model.dart';

class HomePlanScreen extends StatelessWidget {
  // ... (no other changes needed)
}
```

---

## PHASE 5: Cleanup (Delete Old Models)

**IMPORTANT:** Only delete these files AFTER all tests pass!

```bash
# Delete old model files
rm lib/app/Plans/PlanScreen/models/daily_plan_model.dart
rm lib/app/Plans/PlanScreen/models/weekly_plan_model.dart
rm lib/app/Plans/PlanScreen/models/monthly_plan_model.dart
rm lib/app/Plans/PlanScreen/models/roaming_plan_model.dart
rm lib/app/Plans/PlanScreen/models/roameasy_plan_model.dart
rm lib/app/Plans/PlanScreen/models/mifi_plan_model.dart
rm lib/app/Plans/PlanScreen/models/liberty_global_plan_model.dart
rm lib/app/Plans/PlanScreen/models/add_ons_primary_plan_model.dart
```

---

## PHASE 6: Verification

### 6.1 Run Flutter Analyze
```bash
flutter analyze
# Expected: "No issues found!"
```

### 6.2 Run Tests
```bash
flutter test
# Expected: All tests pass
```

### 6.3 Manual QA Checklist
- [ ] Daily plans tab loads and displays correctly
- [ ] Weekly plans tab loads and displays correctly
- [ ] Monthly plans tab loads and displays correctly
- [ ] Roaming plans tab loads and displays correctly
- [ ] RoamEasy plans tab loads and displays correctly
- [ ] MiFi plans tab loads and displays correctly
- [ ] Liberty Global plans tab loads and displays correctly
- [ ] Add-ons tab loads and displays correctly
- [ ] Date formatting works (startDateTime, endDateTime)
- [ ] Plan expansion/collapse works
- [ ] Plan selection works
- [ ] No console errors

### 6.4 Performance Check
- [ ] App starts without delay
- [ ] Plan switching is smooth
- [ ] Memory usage is similar or lower

---

## Automation Script

### Automated Search & Replace

Create a bash script to automate the changes:

```bash
#!/bin/bash

# migration_script.sh - Automated model migration

echo "🚀 Starting Plan Model Migration..."

# Phase 1: Update imports in all files
echo "📝 Phase 1: Updating imports..."

# Files to update
FILES=(
  "lib/app/Plans/PlanScreen/repository/services/plan_model_factory.dart"
  "lib/app/Plans/PlanScreen/repository/services/plan_cache.dart"
  "lib/app/Plans/PlanScreen/repository/models/plan_categorization_result.dart"
  "lib/app/Plans/PlanScreen/repository/base_plan_repository.dart"
  "lib/app/Plans/PlanScreen/repository/home_plan_repository_v2.dart"
  "lib/app/Plans/PlanScreen/repository/mock_plan_repository.dart"
  "lib/app/Plans/PlanScreen/cubit/home_plan_state.dart"
  "lib/app/Plans/PlanScreen/cubit/home_plan_cubit.dart"
  "lib/app/Plans/PlanScreen/cubit/plans_state.dart"
  "lib/app/Plans/PlanScreen/widgets/daily_plan_card.dart"
  "lib/app/Plans/PlanScreen/widgets/weekly_plan_card.dart"
  "lib/app/Plans/PlanScreen/widgets/monthly_plan_card.dart"
  "lib/app/Plans/PlanScreen/widgets/roaming_plan_card.dart"
  "lib/app/Plans/PlanScreen/widgets/roameasy_plan_card.dart"
  "lib/app/Plans/PlanScreen/widgets/mifi_plan_card.dart"
  "lib/app/Plans/PlanScreen/widgets/liberty_global_plan_card.dart"
  "lib/app/Plans/PlanScreen/widgets/home_plan_add_ons_tab_content.dart"
  "lib/app/Plans/PlanScreen/widgets/home_plan_plans_list.dart"
  "lib/app/Plans/PlanScreen/view/home_plan_screen.dart"
)

# Type replacements
declare -A TYPE_REPLACEMENTS=(
  ["DailyPlanModel"]="BasePlanModel"
  ["WeeklyPlanModel"]="BasePlanModel"
  ["MonthlyPlanModel"]="BasePlanModel"
  ["RoamingPlanModel"]="BasePlanModel"
  ["RoamEasyPlanModel"]="BasePlanModel"
  ["MifiPlanModel"]="BasePlanModel"
  ["LibertyGlobalPlanModel"]="BasePlanModel"
  ["AddOnsPrimaryPlanModel"]="BasePlanModel"
)

# Apply type replacements
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  Updating $file..."
    for old_type in "${!TYPE_REPLACEMENTS[@]}"; do
      new_type="${TYPE_REPLACEMENTS[$old_type]}"
      sed -i '' "s/$old_type/$new_type/g" "$file"
    done
  fi
done

echo "✅ Phase 1 complete!"

# Phase 2: Remove old imports
echo "📝 Phase 2: Cleaning up imports..."

OLD_IMPORTS=(
  "import.*daily_plan_model.dart"
  "import.*weekly_plan_model.dart"
  "import.*monthly_plan_model.dart"
  "import.*roaming_plan_model.dart"
  "import.*roameasy_plan_model.dart"
  "import.*mifi_plan_model.dart"
  "import.*liberty_global_plan_model.dart"
  "import.*add_ons_primary_plan_model.dart"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    for pattern in "${OLD_IMPORTS[@]}"; do
      sed -i '' "/$pattern/d" "$file"
    done
  fi
done

echo "✅ Phase 2 complete!"

# Phase 3: Run flutter format
echo "📝 Phase 3: Formatting code..."
flutter format lib/app/Plans/PlanScreen/

echo "✅ Phase 3 complete!"

# Phase 4: Run flutter analyze
echo "📝 Phase 4: Running analysis..."
flutter analyze lib/app/Plans/PlanScreen/

echo "✅ Migration complete!"
echo ""
echo "⚠️  NEXT STEPS:"
echo "1. Manually review changes"
echo "2. Add base_plan_model.dart imports where needed"
echo "3. Run flutter test"
echo "4. Delete old model files (after tests pass)"
```

---

## Rollback Plan

If issues occur, rollback steps:

1. **Restore from Git:**
   ```bash
   git checkout lib/app/Plans/PlanScreen/
   ```

2. **Delete base_plan_model.dart:**
   ```bash
   rm lib/app/Plans/PlanScreen/models/base_plan_model.dart
   ```

3. **Run tests to verify:**
   ```bash
   flutter test
   ```

---

## Summary

**Total Files to Update:** 21
**Estimated Time:** 2-3 days
**Risk Level:** Low (field names unchanged)
**Code Reduction:** 3,357 lines (86.2%)

**Key Points:**
- ✅ All field names remain identical
- ✅ All getter names remain identical
- ✅ UI code requires no logic changes
- ✅ Only type references change
- ✅ Dead code removed automatically

**Success Criteria:**
- [ ] `flutter analyze` shows no errors
- [ ] All tests pass
- [ ] Manual QA passes for all plan types
- [ ] No regression in date formatting
- [ ] App performance is maintained

---

## Need Help?

If you encounter issues during migration:

1. Check the specific error message
2. Verify import statements are correct
3. Ensure all old model references are replaced
4. Check for typos in type names
5. Review git diff to see what changed

For each phase, commit after completion:
```bash
git add .
git commit -m "Phase N: [description]"
```

This allows easy rollback if needed.
