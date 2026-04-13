import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_state.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/limited_offer_repository.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/limited_offer_repository_exception.dart';

/// Cubit for managing Limited Time Offer state and business logic
///
/// Features:
/// - Fetches offers from API via repository
/// - Caches data with 5-minute TTL
/// - Live countdown timer (updates every second)
/// - Auto-reload when offer expires
/// - Filters by user type (prepaid/postpaid)
class LimitedOfferCubit extends Cubit<LimitedOfferState> {
  final LimitedOfferRepository _repository;
  Timer? _countdownTimer;

  LimitedOfferCubit(this._repository) : super(LimitedOfferState.initial());

  /// Load limited time offers from API
  ///
  /// [userType] - 'prepaid' or 'postpaid' (default: 'prepaid')
  /// [forceRefresh] - bypass cache and fetch fresh data
  Future<void> loadOffers({
    String userType = 'prepaid',
    bool forceRefresh = false,
  }) async {
    // Prevent duplicate loading
    if (state.isLoading) {
      return;
    }

    // Use cache if valid and not forcing refresh
    if (!forceRefresh && state.isCacheValid && state.hasOffer) {
      return;
    }


    emit(state.copyWith(status: LimitedOfferStatus.loading, clearError: true));

    try {
      // Fetch offers from repository
      final offers = await _repository.fetchActiveOffers(userType: userType);

      // Handle empty result
      if (offers.isEmpty) {
        emit(
          state.copyWith(
            status: LimitedOfferStatus.empty,
            lastFetchedAt: DateTime.now(),
            clearOffer: true,
          ),
        );
        _stopCountdownTimer();
        return;
      }

      // Take first offer (UI shows one at a time)
      final firstOffer = offers.first;

      final newState = state.copyWith(
        status: LimitedOfferStatus.loaded,
        currentOffer: firstOffer,
        lastFetchedAt: DateTime.now(),
        clearError: true,
      );

      emit(newState);


      // Start countdown timer for live updates
      _startCountdownTimer(userType: userType);
    } on LimitedOfferRepositoryException catch (e) {
      final friendlyMessage = _getFriendlyErrorMessage(e);
      emit(
        state.copyWith(
          status: LimitedOfferStatus.failure,
          errorMessage: friendlyMessage,
          clearOffer: true,
        ),
      );
      _stopCountdownTimer();
    } catch (e) {
      emit(
        state.copyWith(
          status: LimitedOfferStatus.failure,
          errorMessage: 'Failed to load offers',
          clearOffer: true,
        ),
      );
      _stopCountdownTimer();
    }
  }

  /// Start countdown timer for live UI updates
  ///
  /// Updates state every second to refresh the countdown display.
  /// Auto-reloads when offer expires.
  void _startCountdownTimer({required String userType}) {
    _stopCountdownTimer(); // Clear existing timer

    if (kDebugMode) {
      debugPrint('⏱️ LimitedOfferCubit: Starting countdown timer');
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final offer = state.currentOffer;

      // Check if offer expired
      if (offer == null || offer.isExpired) {
        if (kDebugMode) {
          debugPrint('⏰ LimitedOfferCubit: Offer expired, reloading...');
        }
        // Reload offers when expired
        loadOffers(userType: userType, forceRefresh: true);
        return;
      }

      // Emit state with updated timestamp to trigger UI rebuild (countdown update)
      // The lastTickAt timestamp changes every second, forcing BlocBuilder to rebuild
      final now = DateTime.now();
      emit(state.copyWith(lastTickAt: now));
    });
  }

  /// Stop countdown timer
  void _stopCountdownTimer() {
    if (_countdownTimer != null) {
      if (kDebugMode) {
        debugPrint('⏹️ LimitedOfferCubit: Stopping countdown timer');
      }
      _countdownTimer?.cancel();
      _countdownTimer = null;
    }
  }

  /// Map repository exceptions to user-friendly messages
  String _getFriendlyErrorMessage(LimitedOfferRepositoryException e) {
    switch (e.type) {
      case LimitedOfferErrorType.network:
        return 'No internet connection. Please check and try again.';
      case LimitedOfferErrorType.timeout:
        return 'Request timed out. Please try again.';
      case LimitedOfferErrorType.notFound:
        return 'No offers available right now.';
      case LimitedOfferErrorType.server:
        return 'Server error. Please try again later.';
      case LimitedOfferErrorType.parsing:
        return 'Failed to load offers. Please try again.';
      case LimitedOfferErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Reset cubit to initial state
  ///
  /// Call this on logout or when clearing data
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 LimitedOfferCubit: Resetting to initial state');
    }
    _stopCountdownTimer();
    emit(LimitedOfferState.initial());
  }

  @override
  Future<void> close() {
    _stopCountdownTimer();
    return super.close();
  }
}
