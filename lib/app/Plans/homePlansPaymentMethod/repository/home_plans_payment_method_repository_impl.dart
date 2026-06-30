import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/repository/plan_bundle_mapper.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/home_plans_payment_method_models.dart';
import 'home_plans_payment_method_repository.dart';

/// Thin adapter that delegates every payment call to [ChangeBundleService].
/// Keeps the bloc/cubit talking through this feature's repository interface
/// while the actual API + body building lives in the shared service.
class HomePlansPaymentMethodRepositoryImpl
    implements HomePlansPaymentMethodRepository {
  HomePlansPaymentMethodRepositoryImpl({ChangeBundleService? service})
    : _service = service ?? instance<ChangeBundleService>();

  final ChangeBundleService _service;

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
      return commonMethods;
    }

    return <HomePlansSavedPaymentMethod>[
      const HomePlansSavedPaymentMethod(
        id: 'charge-account',
        brand: HomePlansCardBrand.unknown,
        ending: '',
        expiry: '',
        logoSvgAsset: '',
        isChargeToMyAccount: true,
      ),
      ...commonMethods,
    ];
  }

  @override
  Future<void> payNow({required String methodId}) async {
    // Mock placeholder for the unused saved-card "pay now" path.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<bool> payFromWallet({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) async {
    final result = await _service.payFromWallet(
      amount: amount,
      bundle: PlanBundleMapper.fromSelectedItems(selectedItems),
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
    );
    return _unwrap(result);
  }

  @override
  Future<bool> payWithSavedCard({
    required double amount,
    required String cardToken,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) async {
    final result = await _service.payWithSavedCard(
      amount: amount,
      cardToken: cardToken,
      bundle: PlanBundleMapper.fromSelectedItems(selectedItems),
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
    );
    return _unwrap(result);
  }

  @override
  Future<bool> payWithCardDetails({
    required double amount,
    required NewCardDetails details,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) async {
    final result = await _service.payWithNewCard(
      amount: amount,
      details: details,
      bundle: PlanBundleMapper.fromSelectedItems(selectedItems),
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
    );
    return _unwrap(result);
  }

  /// Converts the typed service result into the `Future<bool>` the existing
  /// bloc expects. Failure messages bubble up as exceptions so the bloc's
  /// `try/catch` continues to surface them on toasts.
  bool _unwrap(ChangeBundleResult result) {
    switch (result) {
      case ChangeBundleSuccess():
        return true;
      case ChangeBundleFailure(:final message):
        throw Exception(message);
    }
  }
}
