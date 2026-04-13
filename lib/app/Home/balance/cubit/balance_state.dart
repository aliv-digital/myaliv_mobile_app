import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';

/// Status enum for Balance state
enum BalanceStatus {
  initial, // Initial state, no data loaded
  loading, // Fetching balances from API
  loaded, // Balances loaded successfully
  failure, // Error occurred
}

/// Immutable state for Balance feature
///
/// Contains balance data, loading status, and error information.
class BalanceState {
  final BalanceStatus status;
  final BalanceModel? balance;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  const BalanceState({
    required this.status,
    this.balance,
    this.errorMessage,
    this.lastFetchedAt,
  });

  /// Initial state factory
  factory BalanceState.initial() {
    return const BalanceState(
      status: BalanceStatus.initial,
      balance: null,
      errorMessage: null,
      lastFetchedAt: null,
    );
  }

  /// Copy state with updated fields
  BalanceState copyWith({
    BalanceStatus? status,
    BalanceModel? balance,
    String? errorMessage,
    DateTime? lastFetchedAt,
    bool clearBalance = false,
    bool clearError = false,
  }) {
    return BalanceState(
      status: status ?? this.status,
      balance: clearBalance ? null : (balance ?? this.balance),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  // ========== Convenience Getters ==========

  /// Check if we have balance data
  bool get hasBalance => balance != null;

  /// Check if currently loading
  bool get isLoading => status == BalanceStatus.loading;

  /// Check if there was an error
  bool get hasError => status == BalanceStatus.failure;

  /// Check if data is loaded successfully
  bool get isLoaded => status == BalanceStatus.loaded;

  /// Get wallet balance (top-up balance)
  double get walletBalance => balance?.walletBalance ?? 0.0;

  /// Get bonus balance (reward balance)
  double get bonusBalance => balance?.bonusBalance ?? 0.0;

  /// Get wallet balance as formatted string
  String get walletBalanceFormatted => walletBalance.toStringAsFixed(2);

  /// Get bonus balance as formatted string
  String get bonusBalanceFormatted => bonusBalance.toStringAsFixed(2);

  /// Get number of active bonus items
  int get bonusItemCount => balance?.bonusDetails.length ?? 0;

  /// Check if cache is still valid (5 minutes TTL)
  bool get isCacheValid {
    if (lastFetchedAt == null) return false;
    final age = DateTime.now().difference(lastFetchedAt!);
    return age.inMinutes < 5;
  }

  @override
  String toString() {
    return 'BalanceState(status: $status, '
        'wallet: \$${walletBalanceFormatted}, '
        'bonus: \$${bonusBalanceFormatted}, '
        'errorMessage: $errorMessage, '
        'lastFetchedAt: $lastFetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BalanceState &&
        other.status == status &&
        other.balance == balance &&
        other.errorMessage == errorMessage &&
        other.lastFetchedAt == lastFetchedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      balance,
      errorMessage,
      lastFetchedAt,
    );
  }
}
