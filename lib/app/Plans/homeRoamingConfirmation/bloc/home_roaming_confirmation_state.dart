import 'package:equatable/equatable.dart';
import '../models/home_roaming_confirmation_models.dart';

enum HomeRoamingConfirmationStatus { initial, loading, ready, error }

class HomeRoamingConfirmationState extends Equatable {
  final HomeRoamingConfirmationStatus status;
  final HomeRoamingConfirmationRouteArgs? routeArgs;
  final HomeRoamingConfirmationData? data;
  final String? errorMessage;

  /// Navigation signals (UI listens)
  final int openTermsRequestId;
  final int payNowRequestId;

  /// Stores whether the user checked the terms checkbox.
  final bool isTermsChecked;

  const HomeRoamingConfirmationState({
    required this.status,
    required this.routeArgs,
    required this.data,
    required this.errorMessage,
    required this.openTermsRequestId,
    required this.payNowRequestId,
    required this.isTermsChecked,
  });

  factory HomeRoamingConfirmationState.initial() {
    return const HomeRoamingConfirmationState(
      status: HomeRoamingConfirmationStatus.initial,
      routeArgs: null,
      data: null,
      errorMessage: null,
      openTermsRequestId: 0,
      payNowRequestId: 0,
      isTermsChecked: false,
    );
  }

  HomeRoamingConfirmationState copyWith({
    HomeRoamingConfirmationStatus? status,
    HomeRoamingConfirmationRouteArgs? routeArgs,
    HomeRoamingConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
    bool? isTermsChecked,
  }) {
    return HomeRoamingConfirmationState(
      status: status ?? this.status,
      routeArgs: routeArgs ?? this.routeArgs,
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
        routeArgs,
        data,
        errorMessage,
        openTermsRequestId,
        payNowRequestId,
        isTermsChecked,
      ];
}
