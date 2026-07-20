import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository_exception.dart';

typedef DeviceAccountIdProvider = String? Function();

/// Cubit for managing Balance state and business logic
///
/// Features:
/// - Fetches balances from API via repository
/// - Caches data with 5-minute TTL
/// - Provides wallet balance (top-up) and bonus balance (rewards)
class BalanceCubit extends Cubit<BalanceState> {
  final BalanceRepository _repository;
  final DeviceAccountIdProvider _deviceAccountIdProvider;
  int? _cachedDeviceAccountId;

  BalanceCubit(
    this._repository, {
    DeviceAccountIdProvider? deviceAccountIdProvider,
  }) : _deviceAccountIdProvider =
           deviceAccountIdProvider ?? (() => globalState.deviceAccountID),
       super(BalanceState.initial());

  /// Load balances from API
  ///
  /// The device account ID comes from the authenticated login context.
  /// [forceRefresh] - bypass cache and fetch fresh data
  Future<void> loadBalances({bool forceRefresh = false}) async {
    final deviceAccountId = _authenticatedDeviceAccountId;
    if (deviceAccountId == null) {
      emit(
        state.copyWith(
          status: BalanceStatus.failure,
          errorMessage: 'Unable to identify the authenticated account.',
        ),
      );
      return;
    }

    // Prevent duplicate loading
    if (state.isLoading) {
      return;
    }

    // Use cache only when it belongs to the currently authenticated account.
    if (!forceRefresh &&
        _cachedDeviceAccountId == deviceAccountId &&
        state.isCacheValid &&
        state.hasBalance) {
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

      _cachedDeviceAccountId = deviceAccountId;
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

  int? get _authenticatedDeviceAccountId {
    final rawId = _deviceAccountIdProvider()?.trim();
    if (rawId == null || rawId.isEmpty) return null;

    final parsedId = int.tryParse(rawId);
    return parsedId != null && parsedId > 0 ? parsedId : null;
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

  /// Reset cubit to initial state
  ///
  /// Call this on logout or when clearing data
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 BalanceCubit: Resetting to initial state');
    }
    _cachedDeviceAccountId = null;
    emit(BalanceState.initial());
  }
}
