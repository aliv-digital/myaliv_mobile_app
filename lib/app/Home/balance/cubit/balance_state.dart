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
  /// Bump when the persisted payload shape changes in a non-backward-compatible
  /// way, so we can drop stale caches instead of crashing on rehydrate.
  static const int schemaVersion = 1;

  final BalanceStatus status;
  final BalanceModel? balance;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  /// The device account id the persisted `balance` belongs to. Used to detect
  /// TN switches / re-login-as-different-user so we don't show the wrong
  /// account's number.
  final int? deviceAccountId;

  const BalanceState({
    required this.status,
    this.balance,
    this.errorMessage,
    this.lastFetchedAt,
    this.deviceAccountId,
  });

  /// Initial state factory
  factory BalanceState.initial() {
    return const BalanceState(
      status: BalanceStatus.initial,
      balance: null,
      errorMessage: null,
      lastFetchedAt: null,
      deviceAccountId: null,
    );
  }

  /// Copy state with updated fields
  BalanceState copyWith({
    BalanceStatus? status,
    BalanceModel? balance,
    String? errorMessage,
    DateTime? lastFetchedAt,
    int? deviceAccountId,
    bool clearBalance = false,
    bool clearError = false,
  }) {
    return BalanceState(
      status: status ?? this.status,
      balance: clearBalance ? null : (balance ?? this.balance),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      deviceAccountId: deviceAccountId ?? this.deviceAccountId,
    );
  }

  // ========== Serialization (HydratedBloc) ==========

  /// Serialize for HydratedBloc. Transient statuses (loading/failure) are
  /// coerced when rehydrated in [fromStoredJson] — we still persist them
  /// literally so callers see the raw state during app runtime.
  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'status': status.name,
        'balance': balance?.toJson(),
        'errorMessage': errorMessage,
        'lastFetchedAt': lastFetchedAt?.toIso8601String(),
        'deviceAccountId': deviceAccountId,
      };

  /// Rehydrate from disk. Returns `null` on schema mismatch or corrupt data
  /// so the caller can fall back to [BalanceState.initial].
  ///
  /// Transient statuses are demoted so the UI never rehydrates into a
  /// loading spinner or error banner from a previous session.
  static BalanceState? fromStoredJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    if (version is! int || version != schemaVersion) {
      return null;
    }

    final rawBalance = json['balance'];
    final balance = rawBalance is Map
        ? BalanceModel.fromStoredJson(Map<String, dynamic>.from(rawBalance))
        : null;

    final rawStatus = json['status'] as String?;
    final persistedStatus = BalanceStatus.values.firstWhere(
      (s) => s.name == rawStatus,
      orElse: () => BalanceStatus.initial,
    );

    // Never rehydrate a transient status — coerce to loaded (if we have
    // a balance) or initial (if we don't). Prevents ghost spinners and
    // ghost error banners across sessions.
    final BalanceStatus effectiveStatus;
    switch (persistedStatus) {
      case BalanceStatus.loaded:
        effectiveStatus =
            balance == null ? BalanceStatus.initial : BalanceStatus.loaded;
        break;
      case BalanceStatus.initial:
      case BalanceStatus.loading:
      case BalanceStatus.failure:
        effectiveStatus =
            balance == null ? BalanceStatus.initial : BalanceStatus.loaded;
        break;
    }

    return BalanceState(
      status: effectiveStatus,
      balance: balance,
      errorMessage: null,
      lastFetchedAt:
          DateTime.tryParse(json['lastFetchedAt'] as String? ?? ''),
      deviceAccountId: (json['deviceAccountId'] as num?)?.toInt(),
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
        other.lastFetchedAt == lastFetchedAt &&
        other.deviceAccountId == deviceAccountId;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      balance,
      errorMessage,
      lastFetchedAt,
      deviceAccountId,
    );
  }
}
