/// Pure promo calculations using the existing home-plan unit interpretation.
class PromoSubtotalValidation {
  PromoSubtotalValidation._();

  static const errorMessage = 'promo code exceeds subtotal';

  static double monetaryDiscount({
    required String? unitType,
    required double unitQty,
    required double subtotal,
  }) {
    if (unitQty <= 0) {
      return 0;
    }
    return unitType?.trim().toLowerCase() == 'percentage'
        ? subtotal * unitQty / 100
        : unitQty;
  }

  static bool exceedsSubtotal({
    required double discount,
    required double subtotal,
  }) => discount > subtotal;
}
