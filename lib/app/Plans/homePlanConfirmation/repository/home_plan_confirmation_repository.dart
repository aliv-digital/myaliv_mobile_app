import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

import '../models/home_plan_confirmation_models.dart';
import '../models/home_plan_promo_response_model.dart';

class HomePlanConfirmationRepository {
  HomePlanConfirmationRepository({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Future: call API, build the same data shape, return it.
  Future<HomePlanConfirmationData> load({
    required HomePlanConfirmationRouteArgs args,
  }) async {
    final List<PurchaseLineItem> items = <PurchaseLineItem>[];

    // Skip the primary plan line entirely when it's already active —
    // the user is only being charged for the selected add-ons.
    if (!args.isPrimaryPlanActive) {
      items.add(
        PurchaseLineItem(
          id: 'primary',
          type: PurchaseLineType.primaryPlan,
          // The label comes from the API plan type, not a hardcoded
          // "primary plan" string. This matches purchase_confirmation_screen.
          label: _primaryPlanTypeLabel(args.primaryPlanTypeCode),
          title: args.primaryPlanName,
          subtitle: _primaryPlanBeginsText(args),
          price: args.primaryPlanPrice,
        ),
      );
    }

    if (args.flow == HomePlanConfirmationEntryFlow.proceed) {
      items.addAll(
        args.selectedAddOns.map(
          (addOn) => PurchaseLineItem(
            id: addOn.id,
            type: PurchaseLineType.addOn,
            label: 'add-on',
            title: addOn.title,
            subtitle: 'begins immediately',
            price: addOn.price,
          ),
        ),
      );
    }

    final double primaryVat = args.isPrimaryPlanActive
        ? 0
        : args.primaryPlanVatAmount;
    final double addOnsVat = args.selectedAddOns.fold<double>(
      0,
      (sum, addOn) => sum + addOn.vatAmount,
    );

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: primaryVat + addOnsVat,
    );

    return HomePlanConfirmationData(
      phoneNumber: args.phoneNumber,
      headerTitle: args.accountHolderName,
      beginsOnDateText: '',
      items: items,
      totals: totals,
    );
  }

  Future<HomePlanPromoResponse> applyPromo({
    required String code,
    required int deviceAcId,
  }) async {
    final promoCode = code.trim();

    if (promoCode.isEmpty) {
      throw Exception('Promo code is required.');
    }

    if (deviceAcId <= 0) {
      throw Exception('Device account ID not found.');
    }

    final url = Api.applyPromoCodeUrl(
      deviceAccountId: deviceAcId,
      promoCode: promoCode,
    );

    if (kDebugMode) {
      debugPrint('HomePlanConfirmationRepository: applying promo from $url');
    }

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint(
          'HomePlanConfirmationRepository: apply promo status=${response.statusCode}',
        );
      }

      return HomePlanPromoResponse.fromDynamic(response.data);
    } on NetworkException catch (error) {
      throw Exception(_promoErrorMessage(error));
    } catch (error) {
      throw Exception('Failed to apply promo code: $error');
    }
  }

  String _promoErrorMessage(NetworkException error) {
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

    return 'Failed to apply promo code.';
  }

  String _primaryPlanTypeLabel(String planTypeCode) {
    switch (planTypeCode.trim().toUpperCase()) {
      case 'A':
        return 'standalone';
      case 'S':
        return 'secondary plan';
      case 'P':
        return 'primary plan';
      default:
        return 'plan';
    }
  }

  String _primaryPlanBeginsText(HomePlanConfirmationRouteArgs args) {
    if (args.flow != HomePlanConfirmationEntryFlow.skip) {
      return 'begins immediately';
    }

    final startDate = _formatPlanDate(args.futurePlanStartDate);
    if (startDate != null) {
      return 'begins $startDate';
    }

    return 'begins immediately';
  }

  String? _formatPlanDate(String rawDate) {
    final trimmed = rawDate.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parsedDate = DateTime.tryParse(trimmed);
    if (parsedDate != null) {
      return _formatDayMonthYear(parsedDate);
    }

    final datePart = trimmed.split(' ').first;
    final parts = datePart.split(RegExp(r'[-/]'));
    if (parts.length >= 3 && parts.first.length == 4) {
      return '${parts[2].padLeft(2, '0')}-'
          '${parts[1].padLeft(2, '0')}-'
          '${parts[0].substring(2)}';
    }

    return datePart;
  }

  String _formatDayMonthYear(DateTime date) {
    return '${_twoDigits(date.day)}-'
        '${_twoDigits(date.month)}-'
        '${_twoDigits(date.year % 100)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
