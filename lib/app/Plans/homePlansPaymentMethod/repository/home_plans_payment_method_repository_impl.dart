import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/home_plans_payment_method_models.dart';
import 'home_plans_payment_method_repository.dart';

class HomePlansPaymentMethodRepositoryImpl
    implements HomePlansPaymentMethodRepository {
  HomePlansPaymentMethodRepositoryImpl({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

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

  @override
  Future<void> payFromWallet({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
  }) async {
    final requestBody = _walletPaymentRequestBody(
      amount: amount,
      selectedItems: selectedItems,
    );

    if (kDebugMode) {
      debugPrint('Pay from wallet request: $requestBody');
    }

    try {
      final response = await _networkService.request<dynamic>(
        Api.payFromWalletUrl,
        method: HttpMethod.post,
        data: requestBody,
      );

      if (kDebugMode) {
        debugPrint('Pay from wallet status: ${response.statusCode}');
        debugPrint('Pay from wallet response: ${response.data}');
        //): Pay from wallet response: {OrderId: 314894}
      }
    } on NetworkException catch (error) {
      throw Exception(_walletPaymentErrorMessage(error));
    } catch (error) {
      throw Exception('Wallet payment failed: $error');
    }
  }

  Map<String, dynamic> _walletPaymentRequestBody({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
  }) {
    final primaryPlans = <int>[];
    final secondaryPlans = <int>[];
    final standalonePlans = <int>[];

    for (final item in selectedItems) {
      final planId = int.tryParse(item.id.trim());
      if (planId == null) {
        throw Exception('Invalid plan id for ${item.title}.');
      }

      switch (item.planType) {
        case HomePlansPaymentPlanType.primary:
          primaryPlans.add(planId);
          break;
        case HomePlansPaymentPlanType.secondary:
          secondaryPlans.add(planId);
          break;
        case HomePlansPaymentPlanType.standalone:
          standalonePlans.add(planId);
          break;
      }
    }

    if (primaryPlans.isEmpty &&
        secondaryPlans.isEmpty &&
        standalonePlans.isEmpty) {
      throw Exception('No selected plan found for wallet payment.');
    }

    return <String, dynamic>{
      'CardPayment': <String, dynamic>{
        'Amount': amount,
        'KountSessionId': '9c61063f-283d-4cdb-80e4-dc36ed57d179',
        'PaymentInstrument': 'Wallet',
        'CardNumber': 'Wallet',
        'CardExpiration': '2027-12',
        'CardSecurityCode': '042',
        'CardHolderName': 'Credit Card Holder',
      },
      'Bundle': <String, dynamic>{
        'PrimaryPlans': primaryPlans,
        'SecondaryPlans': secondaryPlans,
        'StandalonePlans': standalonePlans,
      },
      'ForceNow': false,
      'SaveCard': false,
      'UseAsRenewalCard': false,
      'Bonuses': <Map<String, dynamic>>[],
      'PromoCodes': <Map<String, dynamic>>[],
      'Note': 'Payment',
    };
  }

  String _walletPaymentErrorMessage(NetworkException error) {
    if (error is NoInternetException || error is HostUnreachableException) {
      return error.message;
    }

    if (error is TimeoutException) {
      return 'Request timeout. Please try again.';
    }

    if (error is SessionExpiredException || error.statusCode == 401) {
      return 'Session expired. Please log in again.';
    }

    final message = error.message.trim();
    if (message.isNotEmpty && message != 'An error occurred') {
      return message;
    }

    return 'Wallet payment failed. Try again.';
  }
}
