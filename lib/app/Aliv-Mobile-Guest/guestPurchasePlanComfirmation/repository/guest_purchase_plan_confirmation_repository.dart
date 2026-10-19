import '../models/guest_purchase_plan_confirmation_models.dart';

class GuestPurchasePlanConfirmationRepository {
  /// Builds confirmation screen data from navigation arguments.
  Future<GuestPurchasePlanConfirmationData> load({
    required GuestPurchasePlanConfirmationRouteArgs args,
  }) async {
    final List<PurchaseLineItem> items = <PurchaseLineItem>[
      PurchaseLineItem(
        id: 'primary',
        type: PurchaseLineType.primaryPlan,
        label: 'primary plan',
        title: args.primaryPlanName,
        subtitle: _planBeginsText(args),
        price: args.primaryPlanPrice,
      ),
    ];

    if (args.flow == GuestPurchasePlanConfirmationEntryFlow.proceed) {
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

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (sum, item) => sum + item.price),
      vat: 0,
    );

    return GuestPurchasePlanConfirmationData(
      phoneNumber: args.phoneNumber,
      headerTitle: args.accountHolderName,
      items: items,
      totals: totals,
    );
  }

  String _planBeginsText(GuestPurchasePlanConfirmationRouteArgs args) {
    if (args.forceNow) {
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
      return '${_twoDigits(parsedDate.day)}-'
          '${_twoDigits(parsedDate.month)}-'
          '${_twoDigits(parsedDate.year % 100)}';
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

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
