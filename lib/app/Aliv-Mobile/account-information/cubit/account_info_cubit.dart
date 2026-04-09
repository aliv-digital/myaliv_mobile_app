import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../loginOtp/model/account_info_model.dart';
import '../repository/account_info_repository.dart';
import 'account_info_state.dart';

/// Cubit for managing account information with automatic persistence
///
/// This cubit uses HydratedBloc for automatic state persistence:
/// - Fetches account information from the repository
/// - Automatically persists state on every emit
/// - Automatically restores state on app start
/// - Provides global access to account info throughout the app
/// - Manages cache with TTL (time-to-live)
/// - Handles refresh logic
///
/// Usage:
/// ```dart
/// // Fetch account info (credentials from AuthManager)
/// await context.read<AccountInfoCubit>().fetchAccountInfo();
///
/// // Access in UI
/// BlocBuilder<AccountInfoCubit, AccountInfoState>(
///   builder: (context, state) {
///     if (state.hasAccount) {
///       return Text('Email: ${state.email}');
///     }
///     return Text('No account');
///   },
/// )
/// ```
class AccountInfoCubit extends HydratedCubit<AccountInfoState> {
  AccountInfoCubit({required AccountInfoRepository repository})
    : _repository = repository,
      super(const AccountInfoState());

  final AccountInfoRepository _repository;

  /// Fetch account information from the server
  ///
  /// Credentials are automatically retrieved from AuthManager.
  /// Parameters:
  /// - [forceRefresh]: Force fetch even if cache is valid
  Future<void> fetchAccountInfo({bool forceRefresh = false}) async {
    // Check if we need to fetch
    if (!forceRefresh && state.hasAccount && !state.isCacheStale()) {
      debugPrint('AccountInfoCubit: Using cached account info');
      return;
    }

    debugPrint('AccountInfoCubit: Fetching account info from server');

    // Emit loading state
    emit(state.copyWith(status: AccountInfoStatus.loading, errorMessage: null));

    try {
      // Fetch from repository (credentials handled internally)
      final accountInfo = await _repository.fetchAccountInfo();

      // Emit success state with data
      // HydratedCubit automatically persists state on emit
      emit(
        state.copyWith(
          status: AccountInfoStatus.success,
          accountInfo: accountInfo,
          lastFetchedAt: DateTime.now(),
          errorMessage: null,
        ),
      );

      debugPrint('AccountInfoCubit: Account info fetched successfully');
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);

      debugPrint(
        'AccountInfoCubit: Error fetching account info - $errorMessage',
      );

      // Emit failure state (keep existing account info if any)
      emit(
        state.copyWith(
          status: AccountInfoStatus.failure,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  /// Refresh account information
  ///
  /// Credentials are automatically retrieved from AuthManager.
  /// This is a convenience method for force refreshing.
  /// Shows refreshing status instead of loading.
  Future<void> refreshAccountInfo() async {
    if (kDebugMode) {
      debugPrint('AccountInfoCubit: Refreshing account info');
    }

    // Emit refreshing state
    emit(
      state.copyWith(status: AccountInfoStatus.refreshing, errorMessage: null),
    );

    try {
      // Fetch from repository (credentials handled internally)
      final accountInfo = await _repository.fetchAccountInfo();

      // Emit success state with updated data
      // HydratedCubit automatically persists state on emit
      emit(
        state.copyWith(
          status: AccountInfoStatus.success,
          accountInfo: accountInfo,
          lastFetchedAt: DateTime.now(),
          errorMessage: null,
        ),
      );

      if (kDebugMode) {
        debugPrint('AccountInfoCubit: Account info refreshed successfully');
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);

      if (kDebugMode) {
        debugPrint(
          'AccountInfoCubit: Error refreshing account info - $errorMessage',
        );
      }

      // Emit failure state (keep existing account info)
      emit(
        state.copyWith(
          status: AccountInfoStatus.failure,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  /// Get cached account information (if available)
  ///
  /// Returns null if no account info is cached.
  AccountInfoModel? getCachedAccountInfo() {
    return state.accountInfo;
  }

  /// Clear all account information
  ///
  /// Call this on logout to clear persisted data.
  Future<void> clearAccountInfo() async {
    debugPrint('AccountInfoCubit: Clearing account info');
    emit(state.cleared());
  }

  /// Check if cached data is stale
  ///
  /// Parameters:
  /// - [ttl]: Time-to-live duration (default: 24 hours)
  bool isCacheStale({Duration ttl = const Duration(hours: 24)}) {
    return state.isCacheStale(ttl: ttl);
  }

  /// Extract user-friendly error message from exception
  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
    final trimmed = raw.trim();
    return trimmed.isEmpty
        ? 'Failed to fetch account information. Please try again.'
        : trimmed;
  }

  // ========== HydratedCubit Implementation ==========

  @override
  AccountInfoState? fromJson(Map<String, dynamic> json) {
    try {
      return AccountInfoState.fromJson(json);
    } catch (e) {
      debugPrint('AccountInfoCubit: Error deserializing state - $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AccountInfoState state) {
    try {
      return state.toJson();
    } catch (e) {
      debugPrint('AccountInfoCubit: Error serializing state - $e');
      return null;
    }
  }
}
