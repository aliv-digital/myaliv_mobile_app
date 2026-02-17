import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/guest_payment_method_prepaid_models.dart';
import 'guest_payment_method_prepaid_repository.dart';

class GuestPaymentMethodPrepaidRepositoryImpl
    implements GuestPaymentMethodPrepaidRepository {
  @override
  Future<List<GuestSavedPaymentMethod>> fetchPaymentMethods() async {
    // TODO: replace with real API
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return const [
      GuestSavedPaymentMethod(
        id: 'visa-1234',
        brand: GuestCardBrand.visa,
        ending: '1234',
        expiry: '06/2024',
        logoSvgAsset: AssetConstant.visaCardSVG, // ✅ তুমি পরে set করবে
      ),
      GuestSavedPaymentMethod(
        id: 'mc-1234',
        brand: GuestCardBrand.mastercard,
        ending: '1234',
        expiry: '06/2024',
        logoSvgAsset: AssetConstant.masterCardSVG, // ✅ তুমি পরে set করবে
      ),
      GuestSavedPaymentMethod(
        id: 'charge-account',
        brand: GuestCardBrand.unknown,
        ending: '',
        expiry: '',
        logoSvgAsset: '',
        isChargeToMyAccount: true,
      ),
    ];
  }

  @override
  Future<void> payNow({required String methodId}) async {
    // TODO: replace with real API
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
