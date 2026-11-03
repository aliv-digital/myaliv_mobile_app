import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

/// Guest add-on rules for the tab and purchase flow.
class GuestAddOnFilterService {
  const GuestAddOnFilterService();

  static final RegExp _separators = RegExp(r'[^a-z0-9]');
  static const Map<String, Set<String>> _allowedAmounts = {
    'data': {'1', '2', '3', '10'},
    'talk': {'100'},
    'text': {'100'},
  };
  static final List<String> _nameVariants = [
    for (final family in ['freedom', 'liberty'])
      for (final entry in _allowedAmounts.entries)
        for (final amount in entry.value) ...[
          '$family${entry.key}$amount',
          '$family$amount${entry.key}',
          '${entry.key}$family$amount',
          '${entry.key}$amount$family',
          '$amount$family${entry.key}',
          '$amount${entry.key}$family',
        ],
  ];
  static final RegExp _allowedNames = RegExp(
    '(?<![0-9])(?:${_nameVariants.join('|')})(?![0-9])',
  );

  bool matchesName(String name) {
    final normalized = name.toLowerCase().replaceAll(_separators, '');
    // Match a complete listed phrase, never separate words around an inserted
    // plan number: "freedom45 data1" is not "freedom data1".
    return _allowedNames.hasMatch(normalized);
  }

  /// [primaryPlans] retains the repository's earliest-start ordering.
  List<HomePlanAddOnModel> filter(
    List<BasePlanModel> primaryPlans, {
    DateTime? now,
  }) {
    final primary = activePrimaryPlan(primaryPlans, now: now);
    if (primary == null) {
      return const [];
    }
    return filterAvailableAddOns(primary.availableBoltOns);
  }

  /// Catalog add-ons can be checked before the selected plan becomes active.
  List<HomePlanAddOnModel> filterAvailableAddOns(
    Iterable<BasePlanModel> addOns,
  ) {
    return addOns
        .where((addOn) => matchesName(addOn.planName))
        .map(_toDisplayModel)
        .toList(growable: false);
  }

  BasePlanModel? activePrimaryPlan(
    List<BasePlanModel> primaryPlans, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    for (final primary in primaryPlans) {
      if (_isActive(primary, currentTime)) {
        return primary;
      }
    }
    return null;
  }

  bool _isActive(BasePlanModel plan, DateTime now) {
    // Match the guest purchase state's date and missing-date semantics.
    final today = DateTime(now.year, now.month, now.day);
    final start = plan.startDateTime;
    if (start != null &&
        DateTime(start.year, start.month, start.day).isAfter(today)) {
      return false;
    }
    final end = plan.endDateTime;
    return end == null || end.isAfter(now);
  }

  HomePlanAddOnModel _toDisplayModel(BasePlanModel addOn) {
    final bucket = addOn.planBuckets.firstOrNull;
    final bucketName = bucket?.name.trim().toLowerCase() ?? '';
    final label = switch (bucketName) {
      '' => 'balance',
      'texts' => 'text balance',
      _ => '$bucketName balance',
    };
    var value = '';
    if (bucket != null) {
      final amount = bucket.amount;
      final amountText = amount == amount.truncateToDouble()
          ? amount.toInt().toString()
          : amount.toString();
      value = '$amountText${bucket.unit.trim().toLowerCase()}';
    }

    return HomePlanAddOnModel(
      id: addOn.planId,
      title: addOn.planName,
      label: label,
      value: value,
      price: addOn.planAmount,
      vatAmount: addOn.vatAmount,
      planTypeCode: addOn.planType,
    );
  }
}
