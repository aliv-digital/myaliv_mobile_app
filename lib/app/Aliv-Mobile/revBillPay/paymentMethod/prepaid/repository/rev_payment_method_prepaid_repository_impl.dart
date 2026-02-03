import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/rev_payment_method_prepaid_models.dart';
import 'rev_payment_method_prepaid_repository.dart';

class RevPaymentMethodPrepaidRepositoryImpl implements RevPaymentMethodPrepaidRepository {
  @override
  Future<List<RevSavedPaymentMethod>> fetchPaymentMethods() async {
    // TODO: replace with real API
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return const [
      RevSavedPaymentMethod(
        id: 'visa-1234',
        brand: RevCardBrand.visa,
        ending: '1234',
        expiry: '06/2024',
        logoSvgAsset: AssetConstant.visaCardSVG, // ✅ তুমি পরে set করবে
      ),
      RevSavedPaymentMethod(
        id: 'mc-1234',
        brand: RevCardBrand.mastercard,
        ending: '1234',
        expiry: '06/2024',
        logoSvgAsset: AssetConstant.masterCardSVG, // ✅ তুমি পরে set করবে
      ),
    ];
  }

  @override
  Future<void> payNow({required String methodId}) async {
    // TODO: replace with real API
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
