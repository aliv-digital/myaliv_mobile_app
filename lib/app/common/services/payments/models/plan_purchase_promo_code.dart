import 'package:equatable/equatable.dart';

/// Promo information that must be included with a plan purchase.
///
/// This model uses the exact field names expected inside the purchase
/// request's `PromoCodes` list.
class PlanPurchasePromoCode extends Equatable {
  final int promoCodeId;
  final double discountAmount;
  final int planId;

  const PlanPurchasePromoCode({
    required this.promoCodeId,
    required this.discountAmount,
    required this.planId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'PromoCodeId': promoCodeId,
      'DiscountAmount': discountAmount,
      'PlanId': planId,
    };
  }

  @override
  List<Object?> get props => [
    promoCodeId,
    discountAmount,
    planId,
  ];
}
