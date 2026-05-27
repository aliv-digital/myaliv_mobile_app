import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/bucket_usage_summary_exception.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/bucket_usage_summary_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

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
  ///
  /// Pass [activePlans] (primary + secondary, from
  /// `PlansCubit.state.activePlansForBucketUsage`) for the home screen's
  /// usage cards, and [standAlonePlans] (from
  /// `PlansCubit.state.standAlonePlansForBucketUsage`) so the cubit can
  /// expose `roamingPlanBucketUsage` for future surfaces. When either list
  /// changes independently of this fetch, call [updateActivePlans] instead
  /// of reloading.
  Future<void> loadBucketUsageSummary({
    required int deviceAccountId,
    List<BasePlanModel> activePlans = const <BasePlanModel>[],
    List<BasePlanModel> standAlonePlans = const <BasePlanModel>[],
    bool forceRefresh = false,
  }) async {
    if (deviceAccountId <= 0) {
      return;
    }

    if (state.isLoading) {
      // Still adopt the latest plan references even when a fetch is in flight.
      if (!_plansEqual(activePlans, state.activePlans) ||
          !_plansEqual(standAlonePlans, state.standAlonePlans)) {
        emit(state.copyWith(
          activePlans: activePlans,
          standAlonePlans: standAlonePlans,
        ));
      }
      return;
    }

    if (!forceRefresh &&
        state.hasSummary &&
        state.isCacheValidFor(deviceAccountId)) {
      if (!_plansEqual(activePlans, state.activePlans) ||
          !_plansEqual(standAlonePlans, state.standAlonePlans)) {
        emit(state.copyWith(
          activePlans: activePlans,
          standAlonePlans: standAlonePlans,
        ));
      }
      return;
    }

    emit(
      state.copyWith(
        status: BucketUsageSummaryStatus.loading,
        deviceAccountId: deviceAccountId,
        activePlans: activePlans,
        standAlonePlans: standAlonePlans,
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
          activePlans: activePlans,
          standAlonePlans: standAlonePlans,
          clearError: true,
        ),
      );
    } on BucketUsageSummaryException catch (e) {
      final friendlyMessage = _friendlyErrorMessage(e);

      emit(
        state.copyWith(
          status: BucketUsageSummaryStatus.failure,
          errorMessage: friendlyMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BucketUsageSummaryStatus.failure,
          errorMessage: 'Failed to load bucket usage summary.',
        ),
      );
    }
  }

  /// Sync the plan sets into this cubit without re-fetching usage. Pass empty
  /// lists to clear (e.g. when the user has no active plan).
  void updateActivePlans(
    List<BasePlanModel> activePlans, {
    List<BasePlanModel> standAlonePlans = const <BasePlanModel>[],
  }) {
    final activeUnchanged = _plansEqual(activePlans, state.activePlans);
    final standAloneUnchanged =
        _plansEqual(standAlonePlans, state.standAlonePlans);
    if (activeUnchanged && standAloneUnchanged) {
      return;
    }

    if (activePlans.isEmpty && standAlonePlans.isEmpty) {
      emit(state.copyWith(clearActivePlans: true));
    } else {
      emit(state.copyWith(
        activePlans: activePlans,
        standAlonePlans: standAlonePlans,
      ));
    }
  }

  void reset() {
    emit(BucketUsageSummaryState.initial());
  }

  /// Compares two plan lists by `planId` to avoid spurious emits when
  /// PlansCubit rebuilds the same plans into fresh `BasePlanModel` instances
  /// (the model doesn't implement value equality).
  bool _plansEqual(List<BasePlanModel> a, List<BasePlanModel> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].planId != b[i].planId) return false;
    }
    return true;
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
