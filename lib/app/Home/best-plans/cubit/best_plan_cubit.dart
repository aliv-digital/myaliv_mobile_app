import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_state.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository_exception.dart';

/// Cubit for managing Best Plan state and business logic
///
/// Features:
/// - Fetches plans from API via repository
/// - Caches data with 5-minute TTL
/// - Filters by user type (prepaid/postpaid)
class BestPlanCubit extends Cubit<BestPlanState> {
  final BestPlanRepository _repository;

  BestPlanCubit(this._repository) : super(BestPlanState.initial());

  /// Load best plans from API
  ///
  /// [userType] - 'prepaid' or 'postpaid' (default: 'prepaid')
  /// [forceRefresh] - bypass cache and fetch fresh data
  Future<void> loadPlans({
    String userType = 'prepaid',
    bool forceRefresh = false,
  }) async {
    // Prevent duplicate loading
    if (state.isLoading) {
      return;
    }

    // Use cache if valid and not forcing refresh
    if (!forceRefresh && state.isCacheValid && state.hasPlans) {
      return;
    }

    emit(state.copyWith(status: BestPlanStatus.loading, clearError: true));

    try {
      // Fetch plans from repository
      final plans = await _repository.fetchActivePlans(userType: userType);

      // Handle empty result
      if (plans.isEmpty) {
        emit(
          state.copyWith(
            status: BestPlanStatus.empty,
            lastFetchedAt: DateTime.now(),
            clearPlans: true,
          ),
        );
        return;
      }

      final newState = state.copyWith(
        status: BestPlanStatus.loaded,
        plans: plans,
        lastFetchedAt: DateTime.now(),
        clearError: true,
      );

      emit(newState);
    } on BestPlanRepositoryException catch (e) {
      final friendlyMessage = _getFriendlyErrorMessage(e);
      emit(
        state.copyWith(
          status: BestPlanStatus.failure,
          errorMessage: friendlyMessage,
          clearPlans: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BestPlanStatus.failure,
          errorMessage: 'Failed to load plans',
          clearPlans: true,
        ),
      );
    }
  }

  /// Map repository exceptions to user-friendly messages
  String _getFriendlyErrorMessage(BestPlanRepositoryException e) {
    switch (e.type) {
      case BestPlanErrorType.network:
        return 'No internet connection. Please check and try again.';
      case BestPlanErrorType.timeout:
        return 'Request timed out. Please try again.';
      case BestPlanErrorType.notFound:
        return 'No plans available right now.';
      case BestPlanErrorType.server:
        return 'Server error. Please try again later.';
      case BestPlanErrorType.parsing:
        return 'Failed to load plans. Please try again.';
      case BestPlanErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Reset cubit to initial state
  ///
  /// Call this on logout or when clearing data
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 BestPlanCubit: Resetting to initial state');
    }
    emit(BestPlanState.initial());
  }
}
