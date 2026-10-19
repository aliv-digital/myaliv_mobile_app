import 'package:equatable/equatable.dart';
import '../models/guest_purchase_plan_confirmation_models.dart';

enum GuestPurchasePlanConfirmationStatus { initial, loading, ready, error }

class GuestPurchasePlanConfirmationState extends Equatable {
  final GuestPurchasePlanConfirmationStatus status;
  final GuestPurchasePlanConfirmationData? data;
  final String? errorMessage;

  /// Navigation signals (UI listens)
  final int openTermsRequestId;
  final int payNowRequestId;
  final int planRemovedRequestId;

  /// Stores whether the user checked the terms checkbox.
  final bool isTermsChecked;

  const GuestPurchasePlanConfirmationState({
    required this.status,
    required this.data,
    required this.errorMessage,
    required this.openTermsRequestId,
    required this.payNowRequestId,
    required this.planRemovedRequestId,
    required this.isTermsChecked,
  });

  factory GuestPurchasePlanConfirmationState.initial() {
    return const GuestPurchasePlanConfirmationState(
      status: GuestPurchasePlanConfirmationStatus.initial,
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

  GuestPurchasePlanConfirmationState copyWith({
    GuestPurchasePlanConfirmationStatus? status,
    GuestPurchasePlanConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
    int? planRemovedRequestId,
    bool? isTermsChecked,
  }) {
    return GuestPurchasePlanConfirmationState(
      status: status ?? this.status,
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
    data,
    errorMessage,
    openTermsRequestId,
    payNowRequestId,
    planRemovedRequestId,
    isTermsChecked,
  ];
}
