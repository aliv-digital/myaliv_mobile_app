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
  final bool forceNow;
  final DateTime? selectedBeginDate;

  /// Captured from the MiFi alt-contact screen ("yes/no" radio).
  /// Default `false` for non-MiFi flows where this isn't asked.
  final bool marketingOptIn;

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
    required this.forceNow,
    required this.selectedBeginDate,
    required this.promoCode,
    required this.promoStatus,
    required this.promoErrorMessage,
    required this.promoResponse,
    required this.promoToastRequestId,
    required this.promoToastMessage,
    required this.promoToastType,
    this.marketingOptIn = false,
  });

  factory HomePlanConfirmationState.initial() {
    return const HomePlanConfirmationState(
      status: HomePlanConfirmationStatus.initial,
      data: null,
      errorMessage: null,
      openTermsRequestId: 0,
      payNowRequestId: 0,
      isTermsChecked: false,
      forceNow: false,
      selectedBeginDate: null,
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
      promoStatus != HomePlanConfirmationPromoStatus.applying &&
      !hasAppliedPromo;

  bool get hasAppliedPromo =>
      promoStatus == HomePlanConfirmationPromoStatus.applied &&
      promoResponse?.isApplied == true;

  double get promoDiscount {
    final subTotal = data?.totals.subTotal ?? 0;
    final definition = promoResponse?.definition;
    if (!hasAppliedPromo || definition == null || subTotal <= 0) return 0;

    final discountValue = definition.unitQty;
    if (discountValue <= 0) return 0;

    final unitType = definition.unitType?.trim().toLowerCase();
    double discountAmount;

    if (unitType == 'percentage') {
      discountAmount = subTotal * discountValue / 100;
    } else {
      // For "dollar" and other fixed-value promo types.
      discountAmount = discountValue;
    }

    final safeDiscountAmount = discountAmount.clamp(0, subTotal).toDouble();
    return _roundCurrency(safeDiscountAmount);
  }

  PurchaseTotals get displayTotals {
    final originalTotals = data?.totals;
    if (originalTotals == null || !hasAppliedPromo) {
      return originalTotals ?? const PurchaseTotals(subTotal: 0, vat: 0);
    }

    final discountedSubTotal = _roundCurrency(
      originalTotals.subTotal - promoDiscount,
    );
    final vat = _roundCurrency(discountedSubTotal * 0.10);
    return PurchaseTotals(subTotal: discountedSubTotal, vat: vat);
  }

  HomePlanConfirmationState copyWith({
    HomePlanConfirmationStatus? status,
    HomePlanConfirmationData? data,
    String? errorMessage,
    int? openTermsRequestId,
    int? payNowRequestId,
    bool? isTermsChecked,
    bool? forceNow,
    DateTime? selectedBeginDate,
    String? promoCode,
    HomePlanConfirmationPromoStatus? promoStatus,
    String? promoErrorMessage,
    Object? promoResponse = _noChange,
    int? promoToastRequestId,
    String? promoToastMessage,
    HomePlanConfirmationToastType? promoToastType,
    bool? marketingOptIn,
  }) {
    return HomePlanConfirmationState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      openTermsRequestId: openTermsRequestId ?? this.openTermsRequestId,
      payNowRequestId: payNowRequestId ?? this.payNowRequestId,
      isTermsChecked: isTermsChecked ?? this.isTermsChecked,
      forceNow: forceNow ?? this.forceNow,
      selectedBeginDate: selectedBeginDate ?? this.selectedBeginDate,
      promoCode: promoCode ?? this.promoCode,
      promoStatus: promoStatus ?? this.promoStatus,
      promoErrorMessage: promoErrorMessage ?? this.promoErrorMessage,
      promoResponse: identical(promoResponse, _noChange)
          ? this.promoResponse
          : promoResponse as HomePlanPromoResponse?,
      promoToastRequestId: promoToastRequestId ?? this.promoToastRequestId,
      promoToastMessage: promoToastMessage ?? this.promoToastMessage,
      promoToastType: promoToastType ?? this.promoToastType,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
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
    forceNow,
    selectedBeginDate,
    promoCode,
    promoStatus,
    promoErrorMessage,
    promoResponse,
    promoToastRequestId,
    promoToastMessage,
    promoToastType,
    marketingOptIn,
  ];
}

double _roundCurrency(double value) => (value * 100).round() / 100;
