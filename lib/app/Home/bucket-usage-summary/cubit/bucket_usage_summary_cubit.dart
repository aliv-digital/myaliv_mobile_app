import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/bucket_usage_summary_exception.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/bucket_usage_summary_repository.dart';

/// Global Cubit for the bucket usage summary API.
///
/// This follows the same app-wide pattern as BalanceCubit and PlansCubit:
/// it is registered as a GetIt singleton and exposed from MultiBlocProvider.
class BucketUsageSummaryCubit extends Cubit<BucketUsageSummaryState> {
  final BucketUsageSummaryRepository _repository;

  BucketUsageSummaryCubit(this._repository)
    : super(BucketUsageSummaryState.initial());

  /// Load the bucket usage summary for the current device account.
  ///
  /// The Cubit keeps a short cache so calling it from both login success and
  /// HomeScreen does not create duplicate API requests for the same user.
  Future<void> loadBucketUsageSummary({
    required int deviceAccountId,
    bool forceRefresh = false,
  }) async {
    if (deviceAccountId <= 0) {
      if (kDebugMode) {
        debugPrint(
          'BucketUsageSummaryCubit: skipped because deviceAccountId is invalid',
        );
      }
      return;
    }

    if (state.isLoading) {
      if (kDebugMode) {
        debugPrint('BucketUsageSummaryCubit: request already in progress');
      }
      return;
    }

    if (!forceRefresh &&
        state.hasSummary &&
        state.isCacheValidFor(deviceAccountId)) {
      if (kDebugMode) {
        debugPrint('BucketUsageSummaryCubit: using cached summary');
      }
      return;
    }

    emit(
      state.copyWith(
        status: BucketUsageSummaryStatus.loading,
        deviceAccountId: deviceAccountId,
        clearError: true,
      ),
    );

    try {
      final summary = await _repository.fetchBucketUsageSummary(
        deviceAccountId: deviceAccountId,
      );

      emit(
        state.copyWith(
          status: BucketUsageSummaryStatus.loaded,
          summary: summary,
          lastFetchedAt: DateTime.now(),
          deviceAccountId: deviceAccountId,
          clearError: true,
        ),
      );

      if (kDebugMode) {
        debugPrint(
          'BucketUsageSummaryCubit: loaded ${summary.itemCount} bucket items',
        );
      }
    } on BucketUsageSummaryException catch (e) {
      final friendlyMessage = _friendlyErrorMessage(e);

      emit(
        state.copyWith(
          status: BucketUsageSummaryStatus.failure,
          errorMessage: friendlyMessage,
        ),
      );

      if (kDebugMode) {
        debugPrint('BucketUsageSummaryCubit: failed - $friendlyMessage');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BucketUsageSummaryStatus.failure,
          errorMessage: 'Failed to load bucket usage summary.',
        ),
      );

      if (kDebugMode) {
        debugPrint('BucketUsageSummaryCubit: unexpected error - $e');
      }
    }
  }

  void reset() {
    if (kDebugMode) {
      debugPrint('BucketUsageSummaryCubit: resetting state');
    }

    emit(BucketUsageSummaryState.initial());
  }

  String _friendlyErrorMessage(BucketUsageSummaryException exception) {
    switch (exception.type) {
      case BucketUsageSummaryErrorType.network:
        return 'No internet connection. Please check and try again.';
      case BucketUsageSummaryErrorType.parsing:
        return 'Failed to read bucket usage summary.';
      case BucketUsageSummaryErrorType.timeout:
        return 'Request timed out. Please try again.';
      case BucketUsageSummaryErrorType.notFound:
        return 'Bucket usage summary not found.';
      case BucketUsageSummaryErrorType.server:
        return 'Server error. Please try again later.';
      case BucketUsageSummaryErrorType.sessionExpired:
        return 'Session expired. Please login again.';
      case BucketUsageSummaryErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
}
