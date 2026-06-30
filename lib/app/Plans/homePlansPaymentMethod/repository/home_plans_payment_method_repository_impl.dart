import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/home_plans_payment_method_models.dart';
import 'change_bundle_request_factory.dart';
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
    // This is mock behavior for now. Replace with API integration later.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<bool> payFromWallet({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    return _changeBundle(
      cardPayment: ChangeBundleRequestFactory.walletCardPayment(amount: amount),
      selectedItems: selectedItems,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
      logTag: 'wallet',
    );
  }

  @override
  Future<bool> payWithSavedCard({
    required double amount,
    required String cardToken,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    return _changeBundle(
      cardPayment: ChangeBundleRequestFactory.tokenCardPayment(
        amount: amount,
        cardToken: cardToken,
      ),
      selectedItems: selectedItems,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
      logTag: 'saved-card',
    );
  }

  Future<bool> _changeBundle({
    required Map<String, dynamic> cardPayment,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
    required String logTag,
  }) async {
    final body = ChangeBundleRequestFactory.body(
      cardPayment: cardPayment,
      selectedItems: selectedItems,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
    );

    if (kDebugMode) {
      debugPrint('change-bundle [$logTag] request: $body');
    }

    try {
      final response = await _networkService.request<dynamic>(
        Api.payFromWalletUrl,
        method: HttpMethod.post,
        data: body,
      );

      if (kDebugMode) {
        debugPrint(
          'change-bundle [$logTag] status: ${response.statusCode} '
          'body: ${response.data}',
        );
      }

      final code = response.statusCode ?? 0;
      return code >= 200 && code < 300;
    } on NetworkException catch (error) {
      throw Exception(_errorMessage(error));
    } catch (error) {
      throw Exception('Payment failed: $error');
    }
  }

  String _errorMessage(NetworkException error) {
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
    return 'Payment failed. Try again.';
  }
}
