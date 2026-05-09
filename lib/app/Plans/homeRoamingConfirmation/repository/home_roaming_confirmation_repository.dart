import '../../../../resources/extentions/dateformatter.dart';
import '../../PlanScreen/models/base_plan_model.dart';
import '../models/home_roaming_confirmation_models.dart';

class HomeRoamingConfirmationRepository {
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
      items: data.items.map((item) => item.copyWith(subtitle: subtitle)).toList(),
      totals: data.totals,
    );
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
