import '../models/home_plans_postpaid_plan_model.dart';

enum HomePlansPostPaidStatus { initial, loading, loaded, failure }

class HomePlansPostPaidToastMessage {
  const HomePlansPostPaidToastMessage({
    required this.id,
    required this.message,
  });

  final int id;
  final String message;
}

class HomePlansPostPaidState {
  final HomePlansPostPaidStatus status;
  final List<HomePlansPostPaidPlanModel> plans;
  final Set<String> expandedPlanIds;
  final String? errorMessage;
  final DateTime? apiLastSyncedAt;
  final HomePlansPostPaidToastMessage? pendingToast;
  final int toastSequence;

  const HomePlansPostPaidState({
    required this.status,
    required this.plans,
    required this.expandedPlanIds,
    required this.toastSequence,
    this.errorMessage,
    this.apiLastSyncedAt,
    this.pendingToast,
  });

  factory HomePlansPostPaidState.initial() {
    return const HomePlansPostPaidState(
      status: HomePlansPostPaidStatus.initial,
      plans: <HomePlansPostPaidPlanModel>[],
      expandedPlanIds: <String>{},
      toastSequence: 0,
      errorMessage: null,
      apiLastSyncedAt: null,
      pendingToast: null,
    );
  }

  HomePlansPostPaidState copyWith({
    HomePlansPostPaidStatus? status,
    List<HomePlansPostPaidPlanModel>? plans,
    Set<String>? expandedPlanIds,
    String? errorMessage,
    DateTime? apiLastSyncedAt,
    HomePlansPostPaidToastMessage? pendingToast,
    int? toastSequence,
    bool clearError = false,
    bool clearPendingToast = false,
  }) {
    return HomePlansPostPaidState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      expandedPlanIds: expandedPlanIds ?? this.expandedPlanIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      apiLastSyncedAt: apiLastSyncedAt ?? this.apiLastSyncedAt,
      pendingToast:
          clearPendingToast ? null : (pendingToast ?? this.pendingToast),
      toastSequence: toastSequence ?? this.toastSequence,
    );
  }

  bool isExpanded(String planId) => expandedPlanIds.contains(planId);
}
