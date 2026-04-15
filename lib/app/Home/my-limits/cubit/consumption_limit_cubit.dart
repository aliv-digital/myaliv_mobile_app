import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/consumption_limit_repository.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/consumption_limit_repository_exception.dart';

/// Cubit for managing Consumption Limit state and business logic
///
/// Features:
/// - Fetches consumption limits from API via repository
/// - Caches data with 5-minute TTL
/// - Provides access to individual limit types
class ConsumptionLimitCubit extends Cubit<ConsumptionLimitState> {
  final ConsumptionLimitRepository _repository;

  ConsumptionLimitCubit(this._repository)
      : super(ConsumptionLimitState.initial());

  /// Load consumption limits from API
  ///
  /// [deviceAccountId] - The account ID for the device
  /// [forceRefresh] - bypass cache and fetch fresh data
  Future<void> loadLimits({
    required int deviceAccountId,
    bool forceRefresh = false,
  }) async {
    // Prevent duplicate loading
    if (state.isLoading) {
      return;
    }

    // Use cache if valid and not forcing refresh
    if (!forceRefresh && state.isCacheValid && state.hasLimits) {
      if (kDebugMode) {
        debugPrint('📊 ConsumptionLimitCubit: Using cached limits data');
      }
      return;
    }

    emit(state.copyWith(status: ConsumptionLimitStatus.loading, clearError: true));

    try {
      // Fetch limits from repository
      final limits = await _repository.fetchLimits(
        deviceAccountId: deviceAccountId,
      );

      final newState = state.copyWith(
        status: ConsumptionLimitStatus.loaded,
        limits: limits,
        lastFetchedAt: DateTime.now(),
        clearError: true,
      );

      emit(newState);

      if (kDebugMode) {
        debugPrint('✅ ConsumptionLimitCubit: Limits loaded successfully');
        debugPrint('   Total limits: ${limits.length}');
        for (final limit in limits) {
          debugPrint(
              '   - ${limit.displayName}: \$${limit.remainingAmount.toStringAsFixed(2)} / \$${limit.initialAmount.toStringAsFixed(2)} (${limit.percentUsed}% used)');
        }
      }
    } on ConsumptionLimitRepositoryException catch (e) {
      final friendlyMessage = _getFriendlyErrorMessage(e);
      emit(
        state.copyWith(
          status: ConsumptionLimitStatus.failure,
          errorMessage: friendlyMessage,
        ),
      );

      if (kDebugMode) {
        debugPrint('❌ ConsumptionLimitCubit: Failed to load limits');
        debugPrint('   Error: $friendlyMessage');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsumptionLimitStatus.failure,
          errorMessage: 'Failed to load consumption limits',
        ),
      );

      if (kDebugMode) {
        debugPrint('❌ ConsumptionLimitCubit: Unexpected error: $e');
      }
    }
  }

  /// Map repository exceptions to user-friendly messages
  String _getFriendlyErrorMessage(ConsumptionLimitRepositoryException e) {
    switch (e.type) {
      case ConsumptionLimitErrorType.network:
        return 'No internet connection. Please check and try again.';
      case ConsumptionLimitErrorType.timeout:
        return 'Request timed out. Please try again.';
      case ConsumptionLimitErrorType.notFound:
        return 'Consumption limits not found.';
      case ConsumptionLimitErrorType.server:
        return 'Server error. Please try again later.';
      case ConsumptionLimitErrorType.sessionExpired:
        return 'Session expired. Please login again.';
      case ConsumptionLimitErrorType.parsing:
        return 'Failed to load limits. Please try again.';
      case ConsumptionLimitErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Reset cubit to initial state
  ///
  /// Call this on logout or when clearing data
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 ConsumptionLimitCubit: Resetting to initial state');
    }
    emit(ConsumptionLimitState.initial());
  }
}
