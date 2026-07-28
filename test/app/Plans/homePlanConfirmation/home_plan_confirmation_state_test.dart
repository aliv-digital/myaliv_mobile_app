import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_promo_response_model.dart';

void main() {
  group('HomePlanConfirmationState promo totals', () {
    test('deducts UnitQty as an amount before calculating 10 percent VAT', () {
      final state = _stateWithPromo(
        subTotal: 48.91,
        originalVat: 4.89,
        unitType: 'percentage',
        unitQty: 10,
      );

      expect(state.promoDiscount, 10);
      expect(state.displayTotals.subTotal, 38.91);
      expect(state.displayTotals.vat, 3.89);
      expect(state.displayTotals.total, 42.80);
      expect(state.canApplyPromo, isFalse);
    });

    test('deducts fixed promo before calculating 10 percent VAT', () {
      final state = _stateWithPromo(
        subTotal: 40.91,
        originalVat: 4.09,
        unitType: 'amount',
        unitQty: 5,
      );

      expect(state.promoDiscount, 5);
      expect(state.displayTotals.subTotal, 35.91);
      expect(state.displayTotals.vat, 3.59);
      expect(state.displayTotals.total, 39.50);
    });

    test('keeps original totals until a promo is successfully applied', () {
      final data = _confirmationData(subTotal: 96.36, vat: 9.64);
      final state = HomePlanConfirmationState.initial().copyWith(
        status: HomePlanConfirmationStatus.ready,
        data: data,
      );

      expect(state.hasAppliedPromo, isFalse);
      expect(state.promoDiscount, 0);
      expect(state.displayTotals, data.totals);
    });
  });
}

HomePlanConfirmationState _stateWithPromo({
  required double subTotal,
  required double originalVat,
  required String unitType,
  required double unitQty,
}) {
  return HomePlanConfirmationState.initial().copyWith(
    status: HomePlanConfirmationStatus.ready,
    data: _confirmationData(subTotal: subTotal, vat: originalVat),
    promoCode: 'TESTCODE',
    promoStatus: HomePlanConfirmationPromoStatus.applied,
    promoResponse: _promoResponse(unitType: unitType, unitQty: unitQty),
  );
}

HomePlanConfirmationData _confirmationData({
  required double subTotal,
  required double vat,
}) {
  return HomePlanConfirmationData(
    phoneNumber: '2428997091',
    headerTitle: 'Test User',
    beginsOnDateText: '',
    items: const <PurchaseLineItem>[],
    totals: PurchaseTotals(subTotal: subTotal, vat: vat),
  );
}

HomePlanPromoResponse _promoResponse({
  required String unitType,
  required double unitQty,
}) {
  return HomePlanPromoResponse(
    promoCodeId: 2063,
    definition: PromoCodeDefinition(
      promoCodeDefId: 7,
      promoCodePrefix: 'TEST',
      promoCodeName: 'Test promo',
      promoCodeDesc: 'Test discount',
      unitType: unitType,
      unitQty: unitQty,
      startDate: null,
      endDate: null,
      createdDate: null,
      agentCreatable: true,
      isActive: true,
      days: 30,
    ),
    value: 'TESTCODE',
    deviceId: 580468973,
    addedDate: null,
    addedBy: 0,
    usedDate: null,
    usedBy: 0,
    orderId: 0,
    endDate: null,
  );
}
