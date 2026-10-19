import 'package:equatable/equatable.dart';

/// A bonus balance applied to a plan purchase.
///
/// Maps to one item in the `Bonuses` array of the change-bundle / 3DS
/// change-bundle request body. Send an empty list when no bonuses apply.
class PlanPurchaseBonus extends Equatable {
  final String balanceType;
  final String chargeCode;
  final double amount;
  final int planId;

  const PlanPurchaseBonus({
    required this.balanceType,
    required this.chargeCode,
    required this.amount,
    required this.planId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'BalanceType': balanceType,
      'ChargeCode': chargeCode,
      'Amount': amount,
      'PlanId': planId,
    };
  }

  @override
  List<Object?> get props => [balanceType, chargeCode, amount, planId];
}
