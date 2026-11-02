import '../models/roaming_plan_confirmation_models.dart';
import '../../../../resources/extentions/dateformatter.dart';

class RoamingPlanConfirmationRepository {
  /// Future: call API, build the same data shape, return it.
  Future<RoamingPlanConfirmationData> load({
    required RoamingPlanConfirmationRouteArgs args,
  }) async {
    // Mirror the authenticated flow: `price` is the base portion and
    // `vatAmount` is the VAT portion so subtotal/vat/total render correctly.
    final double base = args.planBasePrice ?? args.planPrice;

    final items = <PurchaseLineItem>[
      PurchaseLineItem(
        id: args.planId,
        type: PurchaseLineType.primaryPlan,
        label: 'standalone',
        title: _planTitle(args),
        subtitle: args.forceNow
            ? 'begins immediately'
            : 'begins ${_shortDate(args.beginDate)}',
        price: base,
        basePrice: args.planBasePrice,
        vatAmount: args.planVatAmount,
      ),
    ];

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: items.fold<double>(0, (s, x) => s + x.vatAmount),
    );

    return RoamingPlanConfirmationData(
      phoneNumber: args.phoneNumber,
      headerTitle: 'guest purchase a plan',
      beginsOnDateText: formatWithOrdinal(args.beginDate),
      items: items,
      totals: totals,
    );
  }

  RoamingPlanConfirmationData updateBeginDate({
    required RoamingPlanConfirmationData data,
    required DateTime beginDate,
  }) {
    final subtitle = 'begins ${_shortDate(beginDate)}';

    return RoamingPlanConfirmationData(
      phoneNumber: data.phoneNumber,
      headerTitle: data.headerTitle,
      beginsOnDateText: formatWithOrdinal(beginDate),
      items: data.items
          .map((item) => item.copyWith(subtitle: subtitle))
          .toList(growable: false),
      totals: data.totals,
    );
  }

  String _planTitle(RoamingPlanConfirmationRouteArgs args) {
    final duration = args.planDuration.trim();
    return duration.isEmpty ? args.planName : '${args.planName} - $duration';
  }

  String _shortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$day-$month-$year';
  }
}
