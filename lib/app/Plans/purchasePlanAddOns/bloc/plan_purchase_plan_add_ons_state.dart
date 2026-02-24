// import 'package:equatable/equatable.dart';
//
// import '../model/plan_purchase_add_on_models.dart';
//
//
// enum PlanPurchasePlanAddOnsStatus { initial, loading, ready, error }
//
// class PlanPurchasePlanAddOnsState extends Equatable {
//   final PlanPurchasePlanAddOnsStatus status;
//
//   final PlanPurchaseActivePlanSummary? activePlan;
//   final PlanPurchaseFairUsePolicy? fairUsePolicy;
//   final List<PlanPurchaseAddOnItem> addOns;
//
//   /// Using Set keeps it flexible: later you can allow multi-select without redesign.
//   final Set<String> selectedAddOnIds;
//
//   /// Navigation signals (same style as your receipt screen)
//   final int skipRequestId;
//   final int proceedRequestId;
//
//   final String? errorMessage;
//
//   const PlanPurchasePlanAddOnsState({
//     required this.status,
//     required this.activePlan,
//     required this.fairUsePolicy,
//     required this.addOns,
//     required this.selectedAddOnIds,
//     required this.skipRequestId,
//     required this.proceedRequestId,
//     required this.errorMessage,
//   });
//
//   factory PlanPurchasePlanAddOnsState.initial() {
//     return const PlanPurchasePlanAddOnsState(
//       status: PlanPurchasePlanAddOnsStatus.initial,
//       activePlan: null,
//       fairUsePolicy: null,
//       addOns: [],
//       selectedAddOnIds: {},
//       skipRequestId: 0,
//       proceedRequestId: 0,
//       errorMessage: null,
//     );
//   }
//
//   PlanPurchasePlanAddOnsState copyWith({
//     PlanPurchasePlanAddOnsStatus? status,
//     PlanPurchaseActivePlanSummary? activePlan,
//     PlanPurchaseFairUsePolicy? fairUsePolicy,
//     List<PlanPurchaseAddOnItem>? addOns,
//     Set<String>? selectedAddOnIds,
//     int? skipRequestId,
//     int? proceedRequestId,
//     String? errorMessage,
//   }) {
//     return PlanPurchasePlanAddOnsState(
//       status: status ?? this.status,
//       activePlan: activePlan ?? this.activePlan,
//       fairUsePolicy: fairUsePolicy ?? this.fairUsePolicy,
//       addOns: addOns ?? this.addOns,
//       selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,
//       skipRequestId: skipRequestId ?? this.skipRequestId,
//       proceedRequestId: proceedRequestId ?? this.proceedRequestId,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
//
//   double get totalPrice {
//     double sum = 0;
//     for (final item in addOns) {
//       if (selectedAddOnIds.contains(item.id)) sum += item.price;
//     }
//     return sum;
//   }
//
//   @override
//   List<Object?> get props => [
//     status,
//     activePlan,
//     fairUsePolicy,
//     addOns,
//     selectedAddOnIds,
//     skipRequestId,
//     proceedRequestId,
//     errorMessage,
//   ];
// }
// ...same imports
import 'package:equatable/equatable.dart';
import '../model/plan_purchase_add_on_models.dart';

enum PlanPurchasePlanAddOnsStatus { initial, loading, ready, error }

class PlanPurchasePlanAddOnsState extends Equatable {
  final PlanPurchasePlanAddOnsStatus status;

  final PlanPurchaseActivePlanSummary? activePlan;
  final PlanPurchaseFairUsePolicy? fairUsePolicy;
  final List<PlanPurchaseAddOnItem> addOns;

  final Set<String> selectedAddOnIds;

  /// IMPORTANT:
  /// autoRenew state আলাদা করে রাখা হচ্ছে যাতে future API integration এ
  /// selected add-ons + autoRenew একসাথে payload বানানো সহজ হয়।
  final bool autoRenew;

  final int skipRequestId;
  final int proceedRequestId;

  final String? errorMessage;

  const PlanPurchasePlanAddOnsState({
    required this.status,
    required this.activePlan,
    required this.fairUsePolicy,
    required this.addOns,
    required this.selectedAddOnIds,
    required this.autoRenew,
    required this.skipRequestId,
    required this.proceedRequestId,
    required this.errorMessage,
  });

  factory PlanPurchasePlanAddOnsState.initial() {
    return const PlanPurchasePlanAddOnsState(
      status: PlanPurchasePlanAddOnsStatus.initial,
      activePlan: null,
      fairUsePolicy: null,
      addOns: [],
      selectedAddOnIds: {},
      autoRenew: false,
      skipRequestId: 0,
      proceedRequestId: 0,
      errorMessage: null,
    );
  }

  PlanPurchasePlanAddOnsState copyWith({
    PlanPurchasePlanAddOnsStatus? status,
    PlanPurchaseActivePlanSummary? activePlan,
    PlanPurchaseFairUsePolicy? fairUsePolicy,
    List<PlanPurchaseAddOnItem>? addOns,
    Set<String>? selectedAddOnIds,
    bool? autoRenew,
    int? skipRequestId,
    int? proceedRequestId,
    String? errorMessage,
  }) {
    return PlanPurchasePlanAddOnsState(
      status: status ?? this.status,
      activePlan: activePlan ?? this.activePlan,
      fairUsePolicy: fairUsePolicy ?? this.fairUsePolicy,
      addOns: addOns ?? this.addOns,
      selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,
      autoRenew: autoRenew ?? this.autoRenew,
      skipRequestId: skipRequestId ?? this.skipRequestId,
      proceedRequestId: proceedRequestId ?? this.proceedRequestId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get totalPrice {
    double sum = 0;
    for (final item in addOns) {
      if (selectedAddOnIds.contains(item.id)) sum += item.price;
    }
    return sum;
  }

  @override
  List<Object?> get props => [
    status,
    activePlan,
    fairUsePolicy,
    addOns,
    selectedAddOnIds,
    autoRenew,
    skipRequestId,
    proceedRequestId,
    errorMessage,
  ];
}
