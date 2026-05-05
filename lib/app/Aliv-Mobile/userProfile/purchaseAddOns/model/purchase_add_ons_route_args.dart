// __PARKED_PURCHASE_ADD_ONS__
// Parked: superseded by PlanScreen widgets reused via PurchaseAddOnsScreen.
// Kept (commented-out) for reversibility; safe to delete after QA.
/*
import 'package:equatable/equatable.dart';

enum PurchaseAddOnsEntryFlow { proceed, skip }

class PurchaseAddOnsSelectedAddOn extends Equatable {
  final String id;
  final String title;
  final double price;

  const PurchaseAddOnsSelectedAddOn({
    required this.id,
    required this.title,
    required this.price,
  });

  @override
  List<Object?> get props => [id, title, price];
}

class PurchaseAddOnsRouteArgs extends Equatable {
  final String phoneNumber;
  final String accountHolderName;
  final String primaryPlanName;
  final double primaryPlanPrice;
  final PurchaseAddOnsEntryFlow flow;
  final List<PurchaseAddOnsSelectedAddOn> selectedAddOns;

  const PurchaseAddOnsRouteArgs({
    required this.phoneNumber,
    required this.accountHolderName,
    required this.primaryPlanName,
    required this.primaryPlanPrice,
    required this.flow,
    this.selectedAddOns = const <PurchaseAddOnsSelectedAddOn>[],
  });

  bool get defaultTermsChecked => flow == PurchaseAddOnsEntryFlow.skip;

  @override
  List<Object?> get props => [
    phoneNumber,
    accountHolderName,
    primaryPlanName,
    primaryPlanPrice,
    flow,
    selectedAddOns,
  ];
}

*/
