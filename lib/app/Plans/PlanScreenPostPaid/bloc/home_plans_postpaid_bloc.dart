import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/home_plans_postpaid_plan_model.dart';
import '../repository/base_home_plans_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/shared/repository/base_plan_repository_exception.dart';
import 'home_plans_postpaid_event.dart';
import 'home_plans_postpaid_state.dart';

class HomePlansPostPaidBloc
    extends Bloc<HomePlansPostPaidEvent, HomePlansPostPaidState> {
  HomePlansPostPaidBloc({required this.repository})
    : super(HomePlansPostPaidState.initial()) {
    on<HomePlansPostPaidStarted>(_onStarted);
    on<HomePlansPostPaidToggleExpanded>(_onToggleExpanded);
    on<HomePlansPostPaidApiSyncRequested>(_onApiSyncRequested);
    on<HomePlansPostPaidToastConsumed>(_onToastConsumed);
  }

  final BaseHomePlansPostPaidRepository repository;
  bool _isApiSyncInProgress = false;

  Future<void> _onStarted(
    HomePlansPostPaidStarted event,
    Emitter<HomePlansPostPaidState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HomePlansPostPaidStatus.loading,
        plans: const <HomePlansPostPaidPlanModel>[],
        expandedPlanIds: <String>{},
        clearError: true,
      ),
    );

    _scheduleApiSyncIfIdle();
  }

  void _onToggleExpanded(
    HomePlansPostPaidToggleExpanded event,
    Emitter<HomePlansPostPaidState> emit,
  ) {
    final next = Set<String>.from(state.expandedPlanIds);

    if (next.contains(event.planId)) {
      next.remove(event.planId);
    } else {
      next.add(event.planId);
    }

    emit(state.copyWith(expandedPlanIds: next));
  }

  Future<void> _onApiSyncRequested(
    HomePlansPostPaidApiSyncRequested event,
    Emitter<HomePlansPostPaidState> emit,
  ) async {
    if (_isApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint(
          'home-plans-postpaid-api-sync: skipped, sync already in progress',
        );
      }
      return;
    }

    _isApiSyncInProgress = true;

    try {
      final plans = await repository.fetchPlansFromApi(
        printRawResponse: event.printRawResponse,
      );

      emit(
        state.copyWith(
          status: HomePlansPostPaidStatus.loaded,
          plans: plans,
          apiLastSyncedAt: DateTime.now(),
          clearError: true,
        ),
      );
    } on BasePlanRepositoryException catch (error) {
      _emitFailureWithToast(emit, _buildFriendlyMessage(error));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('home-plans-postpaid-api-sync: failed with error: $error');
      }
      _emitFailureWithToast(emit, 'Failed to load roaming data add-ons');
    } finally {
      _isApiSyncInProgress = false;
    }
  }

  void _onToastConsumed(
    HomePlansPostPaidToastConsumed event,
    Emitter<HomePlansPostPaidState> emit,
  ) {
    emit(state.copyWith(clearPendingToast: true));
  }

  void _scheduleApiSyncIfIdle() {
    if (_isApiSyncInProgress) {
      if (kDebugMode) {
        debugPrint(
          'home-plans-postpaid-api-sync: skipped, sync already in progress',
        );
      }
      return;
    }

    add(const HomePlansPostPaidApiSyncRequested());
  }

  void _emitFailureWithToast(
    Emitter<HomePlansPostPaidState> emit,
    String errorMessage,
  ) {
    final nextToastId = state.toastSequence + 1;
    final toast = HomePlansPostPaidToastMessage(
      id: nextToastId,
      message: errorMessage,
    );

    emit(
      state.copyWith(
        status: HomePlansPostPaidStatus.failure,
        errorMessage: errorMessage,
        pendingToast: toast,
        toastSequence: nextToastId,
      ),
    );
  }

  String _buildFriendlyMessage(BasePlanRepositoryException error) {
    switch (error.type) {
      case BasePlanRepositoryErrorType.noInternet:
        return 'No internet connection. Please check and try again.';
      case BasePlanRepositoryErrorType.timeout:
        return 'Roaming data add-ons are taking too long. Please try again.';
      case BasePlanRepositoryErrorType.unauthorized:
        return 'Your session expired. Please login again.';
      case BasePlanRepositoryErrorType.forbidden:
        return 'You do not have access to roaming data add-ons right now.';
      case BasePlanRepositoryErrorType.notFound:
        return 'Roaming data add-ons are not available right now.';
      case BasePlanRepositoryErrorType.server:
        return 'Roaming data add-ons are temporarily unavailable. Please try again shortly.';
      case BasePlanRepositoryErrorType.badResponse:
      case BasePlanRepositoryErrorType.parsing:
        return 'We could not read the roaming data add-ons response. Please try again.';
      case BasePlanRepositoryErrorType.unknown:
        return 'Something went wrong while loading roaming data add-ons.';
    }
  }
}
