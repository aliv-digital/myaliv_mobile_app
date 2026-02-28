import 'package:equatable/equatable.dart';
import '../models/home_plan_confirmation_models.dart';

enum HomePlanConfirmationStatus { initial, loading, ready, error }

class HomePlanConfirmationState extends Equatable {
  final HomePlanConfirmationStatus status;
  final HomePlanConfirmationData? data;
  final String? errorMessage;

  /// Navigation signals (UI listens)
  final int openTermsRequestId;
  final int payNowRequestId;

  /// Stores whether the user checked the terms checkbox.
  final bool isTermsChecked;

  const HomePlanConfirmationState({
    required this.status,
    required this.data,
    required this.errorMessage,
    required this.openTermsRequestId,
    required this.payNowRequestId,
    required this.isTermsChecked,
  });

  factory HomePlanConfirmationState.initial() {
    return const HomePlanConfirmationState(
      status: HomePlanConfirmationStatus.initial,
      data: null,
      errorMessage: null,
      openTermsRequestId: 0,
      payNowRequestId: 0,
      isTermsChecked: false,
    );
  }

  HomePlanConfirmationState copyWith({
    HomePlanConfirmationStatus? status,
    HomePlanConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
    bool? isTermsChecked,
  }) {
    return HomePlanConfirmationState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      openTermsRequestId: openTermsRequestId ?? this.openTermsRequestId,
      payNowRequestId: payNowRequestId ?? this.payNowRequestId,
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
        isTermsChecked,
      ];
}
