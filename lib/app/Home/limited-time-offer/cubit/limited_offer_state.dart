import 'package:myaliv_mobile_app/app/Home/limited-time-offer/models/limited_offer_model.dart';

/// Status enum for Limited Time Offer state
enum LimitedOfferStatus {
  initial, // Initial state, no data loaded
  loading, // Fetching offers from API
  loaded, // Offers loaded successfully
  empty, // No active offers available
  failure, // Error occurred
}

/// Immutable state for Limited Time Offer feature
///
/// Contains current offer data, loading status, and error information.
/// Designed to hold only the FIRST active offer since UI shows one at a time.
class LimitedOfferState {
  final LimitedOfferStatus status;
  final LimitedOfferModel? currentOffer;
  final String? errorMessage;
  final DateTime? lastFetchedAt;
  final DateTime? lastTickAt; // Updates every second for countdown

  const LimitedOfferState({
    required this.status,
    this.currentOffer,
    this.errorMessage,
    this.lastFetchedAt,
    this.lastTickAt,
  });

  /// Initial state factory
  factory LimitedOfferState.initial() {
    return const LimitedOfferState(
      status: LimitedOfferStatus.initial,
      currentOffer: null,
      errorMessage: null,
      lastFetchedAt: null,
      lastTickAt: null,
    );
  }

  /// Copy state with updated fields
  LimitedOfferState copyWith({
    LimitedOfferStatus? status,
    LimitedOfferModel? currentOffer,
    String? errorMessage,
    DateTime? lastFetchedAt,
    DateTime? lastTickAt,
    bool clearOffer = false,
    bool clearError = false,
  }) {
    return LimitedOfferState(
      status: status ?? this.status,
      currentOffer: clearOffer ? null : (currentOffer ?? this.currentOffer),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      lastTickAt: lastTickAt ?? this.lastTickAt,
    );
  }

  // ========== Convenience Getters ==========

  /// Check if we have an active offer to display
  bool get hasOffer =>
      currentOffer != null && currentOffer!.isActive && !currentOffer!.isExpired;

  /// Check if currently loading
  bool get isLoading => status == LimitedOfferStatus.loading;

  /// Check if there was an error
  bool get hasError => status == LimitedOfferStatus.failure;

  /// Check if state is empty (no offers)
  bool get isEmpty => status == LimitedOfferStatus.empty;

  /// Check if data is loaded successfully
  bool get isLoaded => status == LimitedOfferStatus.loaded;

  /// Get time remaining for current offer
  Duration? get timeRemaining => currentOffer?.timeRemaining;

  /// Check if cache is still valid (5 minutes TTL)
  bool get isCacheValid {
    if (lastFetchedAt == null) return false;
    final age = DateTime.now().difference(lastFetchedAt!);
    return age.inMinutes < 5;
  }

  @override
  String toString() {
    return 'LimitedOfferState(status: $status, hasOffer: $hasOffer, '
        'errorMessage: $errorMessage, lastFetchedAt: $lastFetchedAt, '
        'lastTickAt: $lastTickAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LimitedOfferState &&
        other.status == status &&
        other.currentOffer == currentOffer &&
        other.errorMessage == errorMessage &&
        other.lastFetchedAt == lastFetchedAt &&
        other.lastTickAt == lastTickAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      currentOffer,
      errorMessage,
      lastFetchedAt,
      lastTickAt,
    );
  }
}
