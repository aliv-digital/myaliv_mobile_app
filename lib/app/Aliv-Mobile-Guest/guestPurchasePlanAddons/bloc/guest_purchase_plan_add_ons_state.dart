// import 'package:equatable/equatable.dart';
//
// import '../model/add_on_models.dart';
//
//
// enum GuestPurchasePlanAddOnsStatus { initial, loading, ready, error }
//
// class GuestPurchasePlanAddOnsState extends Equatable {
//   final GuestPurchasePlanAddOnsStatus status;
//
//   final ActivePlanSummary? activePlan;
//   final FairUsePolicy? fairUsePolicy;
//   final List<AddOnItem> addOns;
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
//   const GuestPurchasePlanAddOnsState({
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
//   factory GuestPurchasePlanAddOnsState.initial() {
//     return const GuestPurchasePlanAddOnsState(
//       status: GuestPurchasePlanAddOnsStatus.initial,
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
//   GuestPurchasePlanAddOnsState copyWith({
//     GuestPurchasePlanAddOnsStatus? status,
//     ActivePlanSummary? activePlan,
//     FairUsePolicy? fairUsePolicy,
//     List<AddOnItem>? addOns,
//     Set<String>? selectedAddOnIds,
//     int? skipRequestId,
//     int? proceedRequestId,
//     String? errorMessage,
//   }) {
//     return GuestPurchasePlanAddOnsState(
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
import '../model/add_on_models.dart';

enum GuestPurchasePlanAddOnsStatus { initial, loading, ready, error }

class GuestPurchasePlanAddOnsState extends Equatable {
  final GuestPurchasePlanAddOnsStatus status;

  final ActivePlanSummary? activePlan;
  final FairUsePolicy? fairUsePolicy;
  final List<AddOnItem> addOns;

  final Set<String> selectedAddOnIds;

  /// IMPORTANT:
  /// autoRenew state আলাদা করে রাখা হচ্ছে যাতে future API integration এ
  /// selected add-ons + autoRenew একসাথে payload বানানো সহজ হয়।
  final bool autoRenew;

  final int skipRequestId;
  final int proceedRequestId;

  final String? errorMessage;

  const GuestPurchasePlanAddOnsState({
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

  factory GuestPurchasePlanAddOnsState.initial() {
    return const GuestPurchasePlanAddOnsState(
      status: GuestPurchasePlanAddOnsStatus.initial,
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

  GuestPurchasePlanAddOnsState copyWith({
    GuestPurchasePlanAddOnsStatus? status,
    ActivePlanSummary? activePlan,
    FairUsePolicy? fairUsePolicy,
    List<AddOnItem>? addOns,
    Set<String>? selectedAddOnIds,
    bool? autoRenew,
    int? skipRequestId,
    int? proceedRequestId,
    String? errorMessage,
  }) {
    return GuestPurchasePlanAddOnsState(
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
