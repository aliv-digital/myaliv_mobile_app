import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';

/// Name allowlists for the guest catalog tabs.
class GuestPrimaryPlanFilterService {
  const GuestPrimaryPlanFilterService();

  static final RegExp _whitespace = RegExp(r'\s+');
  static const Map<PlanCategory, Set<String>> _allowedNames = {
    PlanCategory.daily: {'freedom5'},
    PlanCategory.weekly: {'freedom45', 'freedom15', 'freedom8'},
    PlanCategory.monthly: {'liberty120', 'liberty70', 'liberty40'},
    PlanCategory.roaming: {'roam50', 'roam30', 'roam20'},
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
  }) {
    final allowed = _allowedNames[category];
    if (allowed == null) {
      return List<BasePlanModel>.of(plans, growable: false);
    }
    return plans
        .where(
          (plan) => allowed.contains(
            plan.planName.toLowerCase().replaceAll(_whitespace, ''),
          ),
        )
        .toList(growable: false);
  }
}
