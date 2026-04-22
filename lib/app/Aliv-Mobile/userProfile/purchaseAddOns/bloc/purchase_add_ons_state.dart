import 'package:equatable/equatable.dart';

import '../model/purchase_add_ons_models.dart';

enum PurchaseAddOnsStatus { initial, loading, ready, error }

class PurchaseAddOnsState extends Equatable {
  final PurchaseAddOnsStatus status;
  final PurchaseAddOnsPrimaryPlan? activePrimaryPlan;
  final List<PurchaseAddOnsItem> addOns;
  final Set<String> selectedAddOnIds;
  final int skipRequestId;
  final int proceedRequestId;
  final String? errorMessage;

  const PurchaseAddOnsState({
    required this.status,
    required this.activePrimaryPlan,
    required this.addOns,
    required this.selectedAddOnIds,
    required this.skipRequestId,
    required this.proceedRequestId,
    required this.errorMessage,
  });

  factory PurchaseAddOnsState.initial() {
    return const PurchaseAddOnsState(
      status: PurchaseAddOnsStatus.initial,
      activePrimaryPlan: null,
      addOns: <PurchaseAddOnsItem>[],
      selectedAddOnIds: <String>{},
      skipRequestId: 0,
      proceedRequestId: 0,
      errorMessage: null,
    );
  }

  double get selectedAddOnsTotal {
    return addOns
        .where((addOn) => selectedAddOnIds.contains(addOn.id))
        .fold<double>(0, (sum, addOn) => sum + addOn.totalPrice);
  }

  PurchaseAddOnsState copyWith({
    PurchaseAddOnsStatus? status,
    PurchaseAddOnsPrimaryPlan? activePrimaryPlan,
    bool clearActivePrimaryPlan = false,
    List<PurchaseAddOnsItem>? addOns,
    Set<String>? selectedAddOnIds,
    int? skipRequestId,
    int? proceedRequestId,
    String? errorMessage,
  }) {
    return PurchaseAddOnsState(
      status: status ?? this.status,
      activePrimaryPlan: clearActivePrimaryPlan
          ? null
          : activePrimaryPlan ?? this.activePrimaryPlan,
      addOns: addOns ?? this.addOns,
      selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,
      skipRequestId: skipRequestId ?? this.skipRequestId,
      proceedRequestId: proceedRequestId ?? this.proceedRequestId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activePrimaryPlan,
        addOns,
        selectedAddOnIds,
        skipRequestId,
        proceedRequestId,
        errorMessage,
      ];
}
