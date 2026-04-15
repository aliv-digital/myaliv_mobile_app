import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/update_limits_request.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/repository/device_limits_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/repository/device_limits_repository.dart';

/// Cubit for managing Device Limits state
///
/// Fetches device limits from API for credit limit update screen.
class DeviceLimitsCubit extends Cubit<DeviceLimitsState> {
  final DeviceLimitsRepository _repository;

  DeviceLimitsCubit(this._repository) : super(DeviceLimitsState.initial());

  /// Load device limits from API
  ///
  /// [forceRefresh] - bypass cache and fetch fresh data
  Future<void> loadDeviceLimits({bool forceRefresh = false}) async {
    if (state.isLoading) return;

    if (!forceRefresh && state.isCacheValid && state.hasDeviceLimits) {
      if (kDebugMode) {
        debugPrint('📊 DeviceLimitsCubit: Using cached device limits data');
      }
      return;
    }

    emit(state.copyWith(status: DeviceLimitsStatus.loading, clearError: true));

    try {
      final deviceLimits = await _repository.getDeviceLimits();

      emit(
        state.copyWith(
          status: DeviceLimitsStatus.loaded,
          deviceLimits: deviceLimits,
          lastFetchedAt: DateTime.now(),
          clearError: true,
        ),
      );
    } on DeviceLimitsException catch (e) {
      final friendlyMessage = _getFriendlyErrorMessage(e);
      emit(
        state.copyWith(
          status: DeviceLimitsStatus.failure,
          errorMessage: friendlyMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DeviceLimitsStatus.failure,
          errorMessage: 'Failed to load device limits',
        ),
      );
    }
  }

  /// Update device credit limits
  ///
  /// [deviceAccountId] - The device account ID
  /// [request] - The update limits request with new values
  /// Returns true if update was successful
  Future<bool> updateLimits({
    required int deviceAccountId,
    required UpdateLimitsRequest request,
  }) async {
    if (state.isUpdating) return false;

    emit(state.copyWith(status: DeviceLimitsStatus.updating, clearError: true));

    try {
      final success = await _repository.updateLimits(
        deviceAccountId: deviceAccountId,
        request: request,
      );

      if (success) {
        emit(state.copyWith(status: DeviceLimitsStatus.updated));

        if (kDebugMode) {
          debugPrint('✅ DeviceLimitsCubit: Limits updated successfully');
          debugPrint('🔄 DeviceLimitsCubit: Refreshing device limits...');
        }

        // Refresh device limits to get updated data
        await loadDeviceLimits(forceRefresh: true);

        return true;
      } else {
        emit(
          state.copyWith(
            status: DeviceLimitsStatus.failure,
            errorMessage: 'Failed to update limits',
          ),
        );
        return false;
      }
    } on DeviceLimitsException catch (e) {
      final friendlyMessage = _getFriendlyErrorMessage(e);
      emit(
        state.copyWith(
          status: DeviceLimitsStatus.failure,
          errorMessage: friendlyMessage,
        ),
      );

      if (kDebugMode) {
        debugPrint('❌ DeviceLimitsCubit: Failed to update limits');
        debugPrint('   Error: $friendlyMessage');
      }

      return false;
    } catch (e) {
      emit(
        state.copyWith(
          status: DeviceLimitsStatus.failure,
          errorMessage: 'Failed to update limits',
        ),
      );

      if (kDebugMode) {
        debugPrint('❌ DeviceLimitsCubit: Unexpected error: $e');
      }

      return false;
    }
  }

  String _getFriendlyErrorMessage(DeviceLimitsException e) {
    switch (e.type) {
      case DeviceLimitsErrorType.network:
        return 'No internet connection. Please check and try again.';
      case DeviceLimitsErrorType.timeout:
        return 'Request timed out. Please try again.';
      case DeviceLimitsErrorType.notFound:
        return 'Device limits not found.';
      case DeviceLimitsErrorType.server:
        return 'Server error. Please try again later.';
      case DeviceLimitsErrorType.sessionExpired:
        return 'Session expired. Please login again.';
      case DeviceLimitsErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Reset to initial state
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 DeviceLimitsCubit: Resetting to initial state');
    }
    emit(DeviceLimitsState.initial());
  }
}
