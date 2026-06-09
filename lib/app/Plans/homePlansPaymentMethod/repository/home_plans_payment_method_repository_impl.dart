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
    // This is mock behavior for now. Replace with API integration later.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<dynamic> payFromWallet({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) async {
    final requestBody = _walletPaymentRequestBody(
      amount: amount,
      selectedItems: selectedItems,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
    );

    if (kDebugMode) {
      debugPrint('Pay from wallet request: $requestBody');
      if (!forceNow) {
        debugPrint(
          'Pay from wallet selected begin date: '
          '${_formatSelectedBeginDate(selectedBeginDate) ?? 'not provided'}',
        );
      }
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
      if (response.statusCode == 200) {
        return true;
      }
    } on NetworkException catch (error) {
      throw Exception(_walletPaymentErrorMessage(error));
    } catch (error) {
      throw Exception('Wallet payment failed: $error');
    }
    return false;
  }

  String? _formatSelectedBeginDate(DateTime? date) {
    if (date == null) return null;

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  Map<String, dynamic> _walletPaymentRequestBody({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
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

    final bundle = <String, dynamic>{
      'PrimaryPlans': primaryPlans,
      'SecondaryPlans': secondaryPlans,
      'StandalonePlans': standalonePlans,
    };

    if (!forceNow) {
      // will pass future date only if force now = false, means we selected a date
      final startDate = _formatSelectedBeginDate(selectedBeginDate);
      if (startDate == null) {
        throw Exception('Selected start date is required for future plan.');
      }
      bundle['StartDate'] = startDate;
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
      'Bundle': bundle,
      'ForceNow': forceNow,
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
