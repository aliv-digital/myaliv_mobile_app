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

  const GuestPurchasePlanConfirmationState({
    required this.status,
    required this.data,
    required this.errorMessage,
    required this.openTermsRequestId,
    required this.payNowRequestId,
  });

  factory GuestPurchasePlanConfirmationState.initial() {
    return const GuestPurchasePlanConfirmationState(
      status: GuestPurchasePlanConfirmationStatus.initial,
      data: null,
      errorMessage: null,
      openTermsRequestId: 0,
      payNowRequestId: 0,
    );
  }

  GuestPurchasePlanConfirmationState copyWith({
    GuestPurchasePlanConfirmationStatus? status,
    GuestPurchasePlanConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
  }) {
    return GuestPurchasePlanConfirmationState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      openTermsRequestId: openTermsRequestId ?? this.openTermsRequestId,
      payNowRequestId: payNowRequestId ?? this.payNowRequestId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    errorMessage,
    openTermsRequestId,
    payNowRequestId,
  ];
}
