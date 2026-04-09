import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localStorage/localStorage.dart';
import '../../loginOtp/model/account_info_model.dart';
import '../repository/account_info_repository.dart';
import 'account_info_state.dart';

/// Cubit for managing account information with persistence
///
/// This cubit:
/// - Fetches account information from the repository
/// - Persists state using LocalStorage
/// - Provides global access to account info throughout the app
/// - Manages cache with TTL (time-to-live)
/// - Handles refresh logic
///
/// Usage:
/// ```dart
/// // Fetch account info
/// await context.read<AccountInfoCubit>().fetchAccountInfo(
///   username: 'user',
///   password: 'ticket',
/// );
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
class AccountInfoCubit extends Cubit<AccountInfoState> {
  AccountInfoCubit({required AccountInfoRepository repository})
    : _repository = repository,
      super(const AccountInfoState()) {
    _loadFromStorage();
  }

  final AccountInfoRepository _repository;

  /// Load persisted account info from local storage
  Future<void> _loadFromStorage() async {
    try {
      final accountInfoMap = await LocalStorage.getAccountInfoMap();
      if (accountInfoMap.isNotEmpty) {
        final accountInfo = AccountInfoModel.fromJson(accountInfoMap);
        emit(
          state.copyWith(
            status: AccountInfoStatus.success,
            accountInfo: accountInfo,
            lastFetchedAt: DateTime.now(),
            errorMessage: null,
          ),
        );

        if (kDebugMode) {
          debugPrint('AccountInfoCubit: Loaded account info from storage');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AccountInfoCubit: Error loading from storage - $e');
      }
    }
  }

  /// Fetch account information from the server
  ///
  /// Credentials are automatically retrieved from AuthManager.
  /// Parameters:
  /// - [forceRefresh]: Force fetch even if cache is valid
  Future<void> fetchAccountInfo({bool forceRefresh = false}) async {
    // Check if we need to fetch
    if (!forceRefresh && state.hasAccount && !state.isCacheStale()) {
      if (kDebugMode) {
        debugPrint('AccountInfoCubit: Using cached account info');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('AccountInfoCubit: Fetching account info from server');
    }

    // Emit loading state
    emit(state.copyWith(status: AccountInfoStatus.loading, errorMessage: null));

    try {
      // Fetch from repository (credentials handled internally)
      final accountInfo = await _repository.fetchAccountInfo();

      // Persist to local storage
      await LocalStorage.storeAccountInfoMap(accountInfo: accountInfo.toJson());

      // Emit success state with data
      emit(
        state.copyWith(
          status: AccountInfoStatus.success,
          accountInfo: accountInfo,
          lastFetchedAt: DateTime.now(),
          errorMessage: null,
        ),
      );

      if (kDebugMode) {
        debugPrint('AccountInfoCubit: Account info fetched successfully');
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);

      if (kDebugMode) {
        debugPrint(
          'AccountInfoCubit: Error fetching account info - $errorMessage',
        );
      }

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

      // Persist to local storage
      await LocalStorage.storeAccountInfoMap(accountInfo: accountInfo.toJson());

      // Emit success state with updated data
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
    if (kDebugMode) {
      debugPrint('AccountInfoCubit: Clearing account info');
    }

    // Clear from local storage by storing empty map
    await LocalStorage.storeAccountInfoMap(accountInfo: {});

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
}
