import '../models/home_plan_confirmation_models.dart';

class HomePlanConfirmationRepository {
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

    final double primaryVat =
        args.isPrimaryPlanActive ? 0 : args.primaryPlanVatAmount;
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

  Future<void> applyPromo({required String code}) async {
    // API integration will be added here once the promo endpoint is available.
    return;
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
