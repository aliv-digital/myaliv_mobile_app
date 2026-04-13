import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository_exception.dart';

/// Cubit for managing Balance state and business logic
///
/// Features:
/// - Fetches balances from API via repository
/// - Caches data with 5-minute TTL
/// - Provides wallet balance (top-up) and bonus balance (rewards)
class BalanceCubit extends Cubit<BalanceState> {
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
    // Prevent duplicate loading
    if (state.isLoading) {
      return;
    }

    // Use cache if valid and not forcing refresh
    if (!forceRefresh && state.isCacheValid && state.hasBalance) {
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

  /// Reset cubit to initial state
  ///
  /// Call this on logout or when clearing data
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 BalanceCubit: Resetting to initial state');
    }
    emit(BalanceState.initial());
  }
}
