import 'package:equatable/equatable.dart';
import '../models/roaming_plan_confirmation_models.dart';

enum RoamingPlanConfirmationStatus { initial, loading, ready, error }

class RoamingPlanConfirmationState extends Equatable {
  final RoamingPlanConfirmationStatus status;
  final RoamingPlanConfirmationRouteArgs? routeArgs;
  final RoamingPlanConfirmationData? data;
  final String? errorMessage;

  /// Navigation signals (UI listens)
  final int openTermsRequestId;
  final int payNowRequestId;
  final int planRemovedRequestId;

  /// Stores whether the user checked the terms checkbox.
  final bool isTermsChecked;

  const RoamingPlanConfirmationState({
    required this.status,
    required this.routeArgs,
    required this.data,
    required this.errorMessage,
    required this.openTermsRequestId,
    required this.payNowRequestId,
    required this.planRemovedRequestId,
    required this.isTermsChecked,
  });

  factory RoamingPlanConfirmationState.initial() {
    return const RoamingPlanConfirmationState(
      status: RoamingPlanConfirmationStatus.initial,
      routeArgs: null,
      data: null,
      errorMessage: null,
      openTermsRequestId: 0,
      payNowRequestId: 0,
      planRemovedRequestId: 0,
      isTermsChecked: false,
    );
  }

  bool get hasPrimaryPlan =>
      data?.items.any((item) => item.type == PurchaseLineType.primaryPlan) ??
      false;

  RoamingPlanConfirmationState copyWith({
    RoamingPlanConfirmationStatus? status,
    RoamingPlanConfirmationRouteArgs? routeArgs,
    RoamingPlanConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
    int? planRemovedRequestId,
    bool? isTermsChecked,
  }) {
    return RoamingPlanConfirmationState(
      status: status ?? this.status,
      routeArgs: routeArgs ?? this.routeArgs,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      openTermsRequestId: openTermsRequestId ?? this.openTermsRequestId,
      payNowRequestId: payNowRequestId ?? this.payNowRequestId,
      planRemovedRequestId: planRemovedRequestId ?? this.planRemovedRequestId,
      isTermsChecked: isTermsChecked ?? this.isTermsChecked,
    );
  }

  @override
  List<Object?> get props => [
    status,
    routeArgs,
    data,
    errorMessage,
    openTermsRequestId,
    payNowRequestId,
    planRemovedRequestId,
    isTermsChecked,
  ];
}
