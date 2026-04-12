import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'plans_state.dart';

/// Cubit for managing plan data
///
/// Responsibilities:
/// - Control all plan fetching operations
/// - Emit states to UI
/// - Handle errors gracefully
/// - Provide simple API for UI layer
class PlansCubit extends Cubit<PlansState> {
  PlansCubit({
    PlansRepository? repository,
  })  : _repository = repository ?? PlansRepository(),
        super(const PlansState());

  final PlansRepository _repository;

  /// Fetch all plans (categorized in single pass)
  Future<void> fetchAllPlans({bool forceRefresh = false}) async {
    emit(state.copyWith(status: PlansStatus.loading));

    try {
      // Fetch and categorize all plans in one go
      final result = await _repository.fetchCategorizedPlans(
        forceRefresh: forceRefresh,
      );

      // Emit success with all categorized plans
      emit(
        state.copyWith(
          status: PlansStatus.success,
          dailyPlans: result.dailyPlans,
          weeklyPlans: result.weeklyPlans,
          monthlyPlans: result.monthlyPlans,
          roamingPlans: result.roamingPlans,
          roamEasyPlans: result.roamEasyPlans,
          mifiPlans: result.mifiPlans,
          libertyGlobalPlans: result.libertyGlobalPlans,
          postpaidRoamingPlans: result.postpaidRoamingPlans,
          lastFetchedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlansStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Fetch plans for a specific tab
  Future<void> fetchPlansForTab(HomePlanTab tab) async {
    // If we already have data and it's fresh, use it
    if (state.hasData && !_shouldRefresh()) {
      return;
    }

    // Otherwise fetch all plans
    await fetchAllPlans();
  }

  /// Refresh all plans (force refresh)
  Future<void> refreshPlans() async {
    await fetchAllPlans(forceRefresh: true);
  }

  /// Clear cache and refetch
  Future<void> clearAndRefetch() async {
    _repository.clearCache();
    await fetchAllPlans(forceRefresh: true);
  }

  /// Get plans for a specific category (from state)
  List<dynamic> getPlansForCategory(PlanCategory category) {
    switch (category) {
      case PlanCategory.daily:
        return state.dailyPlans;
      case PlanCategory.weekly:
        return state.weeklyPlans;
      case PlanCategory.monthly:
        return state.monthlyPlans;
      case PlanCategory.roaming:
        return state.roamingPlans;
      case PlanCategory.roameasy:
        return state.roamEasyPlans;
      case PlanCategory.mifi:
        return state.mifiPlans;
      case PlanCategory.libertyGlobal:
        return state.libertyGlobalPlans;
      case PlanCategory.postpaidRoaming:
        return state.postpaidRoamingPlans;
      case PlanCategory.unknown:
        return [];
    }
  }

  /// Check if we should refresh data
  bool _shouldRefresh() {
    if (state.lastFetchedAt == null) return true;

    final age = DateTime.now().difference(state.lastFetchedAt!);
    return age > const Duration(hours: 1);
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return _repository.getCacheStats();
  }

  /// Retry after failure
  Future<void> retry() async {
    await fetchAllPlans();
  }
}
