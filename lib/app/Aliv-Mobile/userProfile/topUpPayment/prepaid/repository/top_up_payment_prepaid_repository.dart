import 'dart:async';


import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/models/payment_method.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/models/payment_summary.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

abstract class TopUpPaymentPrepaidRepository {
  Future<List<PaymentMethod>> fetchPaymentMethods();
  Future<PaymentSummary> fetchSummary();
  Future<void> payNow({required String paymentMethodId});
}

/// Demo repository (replace with real API/local store)
class TopUpPaymentPrepaidRepositoryImpl implements TopUpPaymentPrepaidRepository {
  @override
  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return const [
      PaymentMethod(
        id: 'pm_visa_1',
        brand: CardBrand.visa,
        last4: '1234',
        expiry: '06/2024',
        // ✅ Change these to your real asset paths
        logoAsset: AssetConstant.visaCardSVG,
      ),
      PaymentMethod(
        id: 'pm_mc_1',
        brand: CardBrand.mastercard,
        last4: '1234',
        expiry: '06/2024',
        // ✅ Change these to your real asset paths
        logoAsset: AssetConstant.masterCardSVG,
      ),
    ];
  }

  @override
  Future<PaymentSummary> fetchSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const PaymentSummary(total: 5.00, vatInclusive: true);
  }

  @override
  Future<void> payNow({required String paymentMethodId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Throw if payment fails:
    // throw Exception('Payment failed');
  }
}
