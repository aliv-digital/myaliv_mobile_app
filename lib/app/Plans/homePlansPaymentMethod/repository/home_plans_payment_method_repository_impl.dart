import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/home_plans_payment_method_models.dart';
import 'home_plans_payment_method_repository.dart';

class HomePlansPaymentMethodRepositoryImpl
    implements HomePlansPaymentMethodRepository {
  @override
  Future<List<HomePlansSavedPaymentMethod>> fetchPaymentMethods({
    required HomePlansSubscriberType subscriberType,
  }) async {
    // This is mock data for now. Replace with API integration later.
    await Future<void>.delayed(const Duration(milliseconds: 250));

    const List<HomePlansSavedPaymentMethod> commonMethods =
        <HomePlansSavedPaymentMethod>[
      HomePlansSavedPaymentMethod(
        id: 'visa-1234',
        brand: HomePlansCardBrand.visa,
        ending: '1234',
        expiry: '06/2024',
        logoSvgAsset: AssetConstant.visaCardSVG,
      ),
      HomePlansSavedPaymentMethod(
        id: 'mc-1234',
        brand: HomePlansCardBrand.mastercard,
        ending: '1234',
        expiry: '06/2024',
        logoSvgAsset: AssetConstant.masterCardSVG,
      ),
    ];

    if (subscriberType == HomePlansSubscriberType.prepaid) {
      // Prepaid UI should not show "charge to my account".
      return commonMethods;
    }

    // Postpaid keeps the current options.
    return <HomePlansSavedPaymentMethod>[
      ...commonMethods,
      const HomePlansSavedPaymentMethod(
        id: 'charge-account',
        brand: HomePlansCardBrand.unknown,
        ending: '',
        expiry: '',
        logoSvgAsset: '',
        isChargeToMyAccount: true,
      ),
    ];
  }

  @override
  Future<void> payNow({required String methodId}) async {
    // This is mock behavior for now. Replace with API integration later.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
