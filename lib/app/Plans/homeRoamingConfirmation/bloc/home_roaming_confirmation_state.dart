import 'package:equatable/equatable.dart';
import '../models/home_roaming_confirmation_models.dart';

enum HomeRoamingConfirmationStatus { initial, loading, ready, error }

class HomeRoamingConfirmationState extends Equatable {
  final HomeRoamingConfirmationStatus status;
  final HomeRoamingConfirmationData? data;
  final String? errorMessage;

  /// Navigation signals (UI listens)
  final int openTermsRequestId;
  final int payNowRequestId;

  /// Stores whether the user checked the terms checkbox.
  final bool isTermsChecked;

  const HomeRoamingConfirmationState({
    required this.status,
    required this.data,
    required this.errorMessage,
    required this.openTermsRequestId,
    required this.payNowRequestId,
    required this.isTermsChecked,
  });

  factory HomeRoamingConfirmationState.initial() {
    return const HomeRoamingConfirmationState(
      status: HomeRoamingConfirmationStatus.initial,
      data: null,
      errorMessage: null,
      openTermsRequestId: 0,
      payNowRequestId: 0,
      isTermsChecked: false,
    );
  }

  HomeRoamingConfirmationState copyWith({
    HomeRoamingConfirmationStatus? status,
    HomeRoamingConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
    bool? isTermsChecked,
  }) {
    return HomeRoamingConfirmationState(
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
