import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_bundle.dart';

/// Translates this feature's `HomePlansPaymentSelectedItem` list into the
/// generic [PlanBundle] expected by the shared `ChangeBundleService`. Lives
/// at the feature boundary so the shared service stays domain-free.
class PlanBundleMapper {
  PlanBundleMapper._();

  static PlanBundle fromSelectedItems(
    List<HomePlansPaymentSelectedItem> items,
  ) {
    final primary = <int>[];
    final secondary = <int>[];
    final standalone = <int>[];

    for (final item in items) {
      final planId = int.tryParse(item.id.trim());
      if (planId == null) {
        throw Exception('Invalid plan id for ${item.title}.');
      }
      switch (item.planType) {
        case HomePlansPaymentPlanType.primary:
          primary.add(planId);
          break;
        case HomePlansPaymentPlanType.secondary:
          secondary.add(planId);
          break;
        case HomePlansPaymentPlanType.standalone:
          standalone.add(planId);
          break;
      }
    }

    return PlanBundle(
      primaryPlans: primary,
      secondaryPlans: secondary,
      standalonePlans: standalone,
    );
  }
}
