import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

import '../../../../resources/extentions/dateformatter.dart';
import '../../PlanScreen/models/base_plan_model.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../models/home_roaming_promo_response_model.dart';

class HomeRoamingConfirmationRepository {
  HomeRoamingConfirmationRepository({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Future: call API, build the same data shape, return it.
  Future<HomeRoamingConfirmationData> load({
    required HomeRoamingConfirmationRouteArgs args,
  }) async {
    final selectedPlan = args.selectedPlan;
    final beginDate = args.beginDate ?? DateTime.now();

    final items = <HomeRoamingConfirmationPurchaseLineItem>[
      HomeRoamingConfirmationPurchaseLineItem(
        id: selectedPlan?.planId ?? 'roaming-plan',
        type: HomeRoamingConfirmationPurchaseLineType.primaryPlan,
        // Label is derived from the selected API plan type.
        label: _planTypeLabel(selectedPlan?.planType),
        title: _planTitle(selectedPlan),
        subtitle: args.showDateField
            ? 'begins ${_shortDate(beginDate)}'
            : 'begins immediately',
        price: selectedPlan?.planAmount ?? 0,
      ),
    ];

    final totals = HomeRoamingConfirmationPurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: selectedPlan?.vatAmount ?? 0,
    );

    return HomeRoamingConfirmationData(
      phoneNumber: args.phoneNumber,
      headerTitle: 'purchase a plan',
      beginsOnDateText: formatWithOrdinal(beginDate),
      items: items,
      totals: totals,
    );
  }

  HomeRoamingConfirmationData updateBeginDate({
    required HomeRoamingConfirmationData data,
    required DateTime beginDate,
  }) {
    final subtitle = 'begins ${_shortDate(beginDate)}';

    return HomeRoamingConfirmationData(
      phoneNumber: data.phoneNumber,
      headerTitle: data.headerTitle,
      beginsOnDateText: formatWithOrdinal(beginDate),
      items: data.items
          .map((item) => item.copyWith(subtitle: subtitle))
          .toList(),
      totals: data.totals,
    );
  }

  Future<HomeRoamingPromoResponse> applyPromo({
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
      debugPrint('HomeRoamingConfirmationRepository: applying promo from $url');
    }

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint(
          'HomeRoamingConfirmationRepository: apply promo status=${response.statusCode}',
        );
      }

      return HomeRoamingPromoResponse.fromDynamic(response.data);
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

  String _planTitle(BasePlanModel? selectedPlan) {
    if (selectedPlan == null) {
      return 'selected plan';
    }

    final planName = selectedPlan.planName.trim();
    final title = planName.isEmpty ? 'selected plan' : planName;
    final duration = _planDurationText(selectedPlan.frequency);

    if (duration.isEmpty) {
      return title;
    }

    return '$title - $duration';
  }

  String _planTypeLabel(String? planTypeCode) {
    switch (planTypeCode?.trim().toUpperCase()) {
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

  String _planDurationText(String frequency) {
    switch (frequency.trim().toUpperCase()) {
      case 'D':
        return '1 day';
      case '3':
        return '3 days';
      case '5':
        return '5 days';
      case 'W':
        return '7 days';
      case 'T':
        return '10 days';
      case 'B':
      case 'H':
        return '15 days';
      case 'M':
        return '30 days';
      case 'S':
        return '60 days';
      case 'N':
        return '90 days';
      case 'A':
        return '1 year';
      default:
        return '';
    }
  }

  String _shortDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$day-$month-$year';
  }
}
