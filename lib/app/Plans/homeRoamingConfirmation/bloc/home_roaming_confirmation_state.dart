import 'package:equatable/equatable.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../models/home_roaming_promo_response_model.dart';

enum HomeRoamingConfirmationStatus { initial, loading, ready, error }

enum HomeRoamingConfirmationPromoStatus { idle, applying, applied, failure }

const Object _noChange = Object();

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

  final String promoCode;
  final HomeRoamingConfirmationPromoStatus promoStatus;
  final String promoErrorMessage;
  final HomeRoamingPromoResponse? promoResponse;

  const HomeRoamingConfirmationState({
    required this.status,
    required this.routeArgs,
    required this.data,
    required this.errorMessage,
    required this.openTermsRequestId,
    required this.payNowRequestId,
    required this.isTermsChecked,
    required this.promoCode,
    required this.promoStatus,
    required this.promoErrorMessage,
    required this.promoResponse,
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
      promoCode: '',
      promoStatus: HomeRoamingConfirmationPromoStatus.idle,
      promoErrorMessage: '',
      promoResponse: null,
    );
  }

  bool get canApplyPromo =>
      promoCode.trim().isNotEmpty &&
      promoStatus != HomeRoamingConfirmationPromoStatus.applying;

  HomeRoamingConfirmationState copyWith({
    HomeRoamingConfirmationStatus? status,
    HomeRoamingConfirmationRouteArgs? routeArgs,
    HomeRoamingConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
    bool? isTermsChecked,
    String? promoCode,
    HomeRoamingConfirmationPromoStatus? promoStatus,
    String? promoErrorMessage,
    Object? promoResponse = _noChange,
  }) {
    return HomeRoamingConfirmationState(
      status: status ?? this.status,
      routeArgs: routeArgs ?? this.routeArgs,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      openTermsRequestId: openTermsRequestId ?? this.openTermsRequestId,
      payNowRequestId: payNowRequestId ?? this.payNowRequestId,
      isTermsChecked: isTermsChecked ?? this.isTermsChecked,
      promoCode: promoCode ?? this.promoCode,
      promoStatus: promoStatus ?? this.promoStatus,
      promoErrorMessage: promoErrorMessage ?? this.promoErrorMessage,
      promoResponse: identical(promoResponse, _noChange)
          ? this.promoResponse
          : promoResponse as HomeRoamingPromoResponse?,
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
    promoCode,
    promoStatus,
    promoErrorMessage,
    promoResponse,
  ];
}
