import 'package:equatable/equatable.dart';
import '../models/home_plan_confirmation_models.dart';
import '../models/home_plan_promo_response_model.dart';

enum HomePlanConfirmationStatus { initial, loading, ready, error }

enum HomePlanConfirmationPromoStatus { idle, applying, applied, failure }

enum HomePlanConfirmationToastType { success, error }

const Object _noChange = Object();

class HomePlanConfirmationState extends Equatable {
  final HomePlanConfirmationStatus status;
  final HomePlanConfirmationData? data;
  final String? errorMessage;

  /// Navigation signals (UI listens)
  final int openTermsRequestId;
  final int payNowRequestId;

  /// Stores whether the user checked the terms checkbox.
  final bool isTermsChecked;

  final String promoCode;
  final HomePlanConfirmationPromoStatus promoStatus;
  final String promoErrorMessage;
  final HomePlanPromoResponse? promoResponse;
  final int promoToastRequestId;
  final String promoToastMessage;
  final HomePlanConfirmationToastType promoToastType;

  const HomePlanConfirmationState({
    required this.status,
    required this.data,
    required this.errorMessage,
    required this.openTermsRequestId,
    required this.payNowRequestId,
    required this.isTermsChecked,
    required this.promoCode,
    required this.promoStatus,
    required this.promoErrorMessage,
    required this.promoResponse,
    required this.promoToastRequestId,
    required this.promoToastMessage,
    required this.promoToastType,
  });

  factory HomePlanConfirmationState.initial() {
    return const HomePlanConfirmationState(
      status: HomePlanConfirmationStatus.initial,
      data: null,
      errorMessage: null,
      openTermsRequestId: 0,
      payNowRequestId: 0,
      isTermsChecked: false,
      promoCode: '',
      promoStatus: HomePlanConfirmationPromoStatus.idle,
      promoErrorMessage: '',
      promoResponse: null,
      promoToastRequestId: 0,
      promoToastMessage: '',
      promoToastType: HomePlanConfirmationToastType.success,
    );
  }

  bool get canApplyPromo =>
      promoCode.trim().isNotEmpty &&
      promoStatus != HomePlanConfirmationPromoStatus.applying;

  HomePlanConfirmationState copyWith({
    HomePlanConfirmationStatus? status,
    HomePlanConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
    bool? isTermsChecked,
    String? promoCode,
    HomePlanConfirmationPromoStatus? promoStatus,
    String? promoErrorMessage,
    Object? promoResponse = _noChange,
    int? promoToastRequestId,
    String? promoToastMessage,
    HomePlanConfirmationToastType? promoToastType,
  }) {
    return HomePlanConfirmationState(
      status: status ?? this.status,
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
          : promoResponse as HomePlanPromoResponse?,
      promoToastRequestId: promoToastRequestId ?? this.promoToastRequestId,
      promoToastMessage: promoToastMessage ?? this.promoToastMessage,
      promoToastType: promoToastType ?? this.promoToastType,
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
    promoCode,
    promoStatus,
    promoErrorMessage,
    promoResponse,
    promoToastRequestId,
    promoToastMessage,
    promoToastType,
  ];
}
