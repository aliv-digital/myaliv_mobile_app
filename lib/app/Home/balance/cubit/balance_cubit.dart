import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository_exception.dart';

/// Cubit for managing Balance state and business logic.
///
/// Persistence:
/// - Extends [HydratedCubit] so the last-loaded balance is restored from disk
///   on cold start, giving the UI something to render before the API responds.
/// - Persisted payloads are keyed by `deviceAccountId`. When the current
///   session's device id no longer matches the persisted one (TN switch or
///   re-login as a different user), the cached balance is dropped instead of
///   being shown to the wrong account.
class BalanceCubit extends HydratedCubit<BalanceState> {
  final BalanceRepository _repository;

  BalanceCubit(this._repository) : super(BalanceState.initial());

  /// Load balances from API
  ///
  /// [deviceAccountId] - The account ID for the device
  /// [forceRefresh] - bypass cache and fetch fresh data
  Future<void> loadBalances({
    required int deviceAccountId,
    bool forceRefresh = false,
  }) async {
    // Guests / unauthenticated sessions never fetch. The rehydrated cache
    // (if any) is already gated in `fromJson`.
    if (!globalState.isAuthenticated) {
      return;
    }

    // Prevent duplicate loading
    if (state.isLoading) {
      return;
    }

    // Use cache if valid, still belongs to this device, and not forcing.
    final cacheBelongsToDevice =
        state.deviceAccountId == null || state.deviceAccountId == deviceAccountId;
    if (!forceRefresh &&
        state.isCacheValid &&
        state.hasBalance &&
        cacheBelongsToDevice) {
      if (kDebugMode) {
        debugPrint('💰 BalanceCubit: Using cached balance data');
      }
      return;
    }

    emit(state.copyWith(status: BalanceStatus.loading, clearError: true));

    try {
      // Fetch balances from repository
      final balance = await _repository.fetchBalances(
        deviceAccountId: deviceAccountId,
      );

      final newState = state.copyWith(
        status: BalanceStatus.loaded,
        balance: balance,
        lastFetchedAt: DateTime.now(),
        deviceAccountId: deviceAccountId,
        clearError: true,
      );

      emit(newState);

      if (kDebugMode) {
        debugPrint('✅ BalanceCubit: Balances loaded successfully');
        debugPrint('   Wallet: \$${balance.walletBalance.toStringAsFixed(2)}');
        debugPrint('   Bonus: \$${balance.bonusBalance.toStringAsFixed(2)}');
      }
    } on BalanceRepositoryException catch (e) {
      final friendlyMessage = _getFriendlyErrorMessage(e);
      emit(
        state.copyWith(
          status: BalanceStatus.failure,
          errorMessage: friendlyMessage,
        ),
      );

      if (kDebugMode) {
        debugPrint('❌ BalanceCubit: Failed to load balances');
        debugPrint('   Error: $friendlyMessage');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BalanceStatus.failure,
          errorMessage: 'Failed to load balances',
        ),
      );

      if (kDebugMode) {
        debugPrint('❌ BalanceCubit: Unexpected error: $e');
      }
    }
  }

  /// Map repository exceptions to user-friendly messages
  String _getFriendlyErrorMessage(BalanceRepositoryException e) {
    if (e.originalError is HostUnreachableException) {
      return "Can't reach server. Try again shortly.";
    }
    switch (e.type) {
      case BalanceErrorType.network:
        return 'No internet connection. Please check and try again.';
      case BalanceErrorType.timeout:
        return 'Request timed out. Please try again.';
      case BalanceErrorType.notFound:
        return 'Balance information not found.';
      case BalanceErrorType.server:
        return 'Server error. Please try again later.';
      case BalanceErrorType.sessionExpired:
        return 'Session expired. Please login again.';
      case BalanceErrorType.parsing:
        return 'Failed to load balances. Please try again.';
      case BalanceErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Reset in-memory state to initial. Callers that also want to wipe the
  /// persisted balance from disk (e.g. logout) should use [clearForLogout]
  /// instead, which also empties the HydratedBloc storage entry.
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 BalanceCubit: Resetting to initial state');
    }
    emit(BalanceState.initial());
  }

  /// Reset in-memory state AND wipe the persisted balance from disk. Prevents
  /// a subsequent login (possibly as a different user) from briefly rehydrating
  /// the previous session's balance before the new user's data loads.
  Future<void> clearForLogout() async {
    reset();
    await clear();
    if (kDebugMode) {
      debugPrint('🧹 BalanceCubit: Persisted cache cleared');
    }
  }

  // ========== HydratedCubit hooks ==========

  @override
  Map<String, dynamic>? toJson(BalanceState state) {
    // Never persist a state we can't safely rehydrate later.
    if (!state.hasBalance) return null;
    return state.toJson();
  }

  @override
  BalanceState? fromJson(Map<String, dynamic> json) {
    try {
      return BalanceState.fromStoredJson(json);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('⚠️  BalanceCubit: fromJson failed, dropping cache: $e');
        debugPrint('$stackTrace');
      }
      return null;
    }
  }
}
