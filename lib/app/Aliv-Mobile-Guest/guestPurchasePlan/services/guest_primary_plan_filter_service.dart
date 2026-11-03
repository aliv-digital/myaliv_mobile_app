import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/payment_option.dart';

/// Name allowlists for the guest catalog tabs.
class GuestPrimaryPlanFilterService {
  const GuestPrimaryPlanFilterService();

  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _roamingDurationName = RegExp(
    r'^(roam|travel)(50|30|20)[-–—]?(14|7)[-–—]?days?$',
  );
  static const Map<PlanCategory, Set<String>> _allowedNames = {
    PlanCategory.daily: {'freedom5'},
    PlanCategory.weekly: {'freedom45', 'freedom15', 'freedom8'},
    PlanCategory.monthly: {'liberty120', 'liberty70', 'liberty40'},
    PlanCategory.roaming: {'roam50', 'roam30', 'roam20'},
    PlanCategory.postpaidRoaming: {'travel50', 'travel30', 'travel20'},
    PlanCategory.roameasy: {
      'roameasyusa&can',
      'roameasycarib',
      'roameasyeurope',
    },
    PlanCategory.libertyGlobal: {
      'libertyglobalcaribbean',
      'libertyglobalchina',
      'libertyglobaleurope',
      'libertyglobalhaiti',
    },
    PlanCategory.mifi: {
      'mifi140',
      'mifi90',
      'mifi75',
      'tab140',
      'tab90',
      'tab75',
    },
  };

  List<BasePlanModel> filter(
    List<BasePlanModel> plans, {
    required PlanCategory category,
    PaymentOption? paymentOption,
  }) {
    if (paymentOption == PaymentOption.postpay &&
        category != PlanCategory.roaming &&
        category != PlanCategory.postpaidRoaming) {
      return const [];
    }
    if (paymentOption == PaymentOption.prepay &&
        category == PlanCategory.postpaidRoaming) {
      return const [];
    }
    return plans
        .where((plan) {
          final planPayment = PaymentOption.parse(plan.paymentOption);
          if (paymentOption != null &&
              planPayment != null &&
              planPayment != paymentOption) {
            return false;
          }
          final effectiveCategory =
              category == PlanCategory.roaming &&
                  (paymentOption ?? planPayment) == PaymentOption.postpay
              ? PlanCategory.postpaidRoaming
              : category;
          final allowed = _allowedNames[effectiveCategory];
          return allowed == null ||
              allowed.contains(
                _normalizedName(plan.planName, effectiveCategory),
              );
        })
        .toList(growable: false);
  }

  String _normalizedName(String name, PlanCategory category) {
    final normalized = name.toLowerCase().replaceAll(_whitespace, '');
    if (category == PlanCategory.roaming ||
        category == PlanCategory.postpaidRoaming) {
      // The API can include the advertised duration, e.g. "roam50 14-day".
      // Remove only a recognized duration belonging to the listed product.
      final match = _roamingDurationName.firstMatch(normalized);
      if (match != null && match[3] == (match[2] == '50' ? '14' : '7')) {
        return '${match[1]}${match[2]}';
      }
    }
    return normalized;
  }
}
