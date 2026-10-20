import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';

/// Parses a `/bundles`-shaped response map into an [AddOnsResult].
///
/// Shared by the authenticated prepaid flow (`GET /device/{id}/bundles`)
/// and the guest flow (`POST /Guest/existingplans`). The two endpoints
/// return byte-for-byte identical payloads, so one parser serves both.
class BundleResponseParser {
  const BundleResponseParser._();

  static AddOnsResult parse(Map<String, dynamic> bundles) {
    final rawPrimaryPlans = _asMapList(bundles['PrimaryPlans']);

    final primaryPlans = rawPrimaryPlans
        .map((map) => BasePlanModel.fromApiMap(map, includeRawPayload: false))
        .toList(growable: false);

    final sortedPrimaryPlans = _sortByEarliestStartDate(primaryPlans);

    final addOns = sortedPrimaryPlans.isNotEmpty
        ? _mapAvailableBoltOnsToUiAddOns(sortedPrimaryPlans.first)
        : <HomePlanAddOnModel>[];

    final secondaryPlans = _sortByEarliestStartDate(
      _asMapList(bundles['SecondaryPlans'])
          .map((map) => BasePlanModel.fromApiMap(map, includeRawPayload: false))
          .toList(growable: false),
    );

    final standAlonePlans = _sortByEarliestStartDate(
      _asMapList(bundles['StandAlonePlans'])
          .map((map) => BasePlanModel.fromApiMap(map, includeRawPayload: false))
          .toList(growable: false),
    );

    return AddOnsResult(
      addOns: addOns,
      primaryPlans: sortedPrimaryPlans,
      secondaryPlans: secondaryPlans,
      standAlonePlans: standAlonePlans,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  static List<BasePlanModel> _sortByEarliestStartDate(
    List<BasePlanModel> plans,
  ) {
    final sortable = plans
        .asMap()
        .entries
        .map(
          (entry) => _SortablePlan(originalIndex: entry.key, plan: entry.value),
        )
        .toList(growable: false);

    sortable.sort((left, right) {
      final leftStartDate = left.plan.startDateTime;
      final rightStartDate = right.plan.startDateTime;

      if (leftStartDate == null && rightStartDate == null) {
        return left.originalIndex.compareTo(right.originalIndex);
      }

      if (leftStartDate == null) return 1;
      if (rightStartDate == null) return -1;

      final dateCompare = leftStartDate.compareTo(rightStartDate);
      if (dateCompare != 0) return dateCompare;

      return left.originalIndex.compareTo(right.originalIndex);
    });

    return sortable.map((entry) => entry.plan).toList(growable: false);
  }

  static List<HomePlanAddOnModel> _mapAvailableBoltOnsToUiAddOns(
    BasePlanModel primaryPlan,
  ) {
    return primaryPlan.availableBoltOns
        .map(
          (addOnPlan) => HomePlanAddOnModel(
            id: addOnPlan.planId,
            title: addOnPlan.planName,
            label: _buildAddOnLabel(addOnPlan),
            value: _buildAddOnValue(addOnPlan),
            price: addOnPlan.planAmount,
            vatAmount: addOnPlan.vatAmount,
            planTypeCode: addOnPlan.planType,
          ),
        )
        .toList(growable: false);
  }

  static String _buildAddOnLabel(BasePlanModel addOnPlan) {
    final firstBucket = addOnPlan.planBuckets.isEmpty
        ? null
        : addOnPlan.planBuckets.first;

    if (firstBucket == null) {
      return 'balance';
    }

    final normalizedBucketName = firstBucket.name.trim().toLowerCase();
    if (normalizedBucketName.isEmpty) {
      return 'balance';
    }

    switch (normalizedBucketName) {
      case 'data':
        return 'data balance';
      case 'minutes':
        return 'minutes balance';
      case 'texts':
        return 'text balance';
      default:
        return '$normalizedBucketName balance';
    }
  }

  static String _buildAddOnValue(BasePlanModel addOnPlan) {
    final firstBucket = addOnPlan.planBuckets.isEmpty
        ? null
        : addOnPlan.planBuckets.first;

    if (firstBucket == null) {
      return '';
    }

    final amountText = _formatWholeOrDecimal(firstBucket.amount);
    final unitText = firstBucket.unit.trim().toLowerCase();

    if (unitText.isEmpty) {
      return amountText;
    }

    return '$amountText$unitText';
  }

  static String _formatWholeOrDecimal(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map(
          (map) => map.map(
            (dynamic key, dynamic value) =>
                MapEntry<String, dynamic>(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }
}

class _SortablePlan {
  const _SortablePlan({required this.originalIndex, required this.plan});

  final int originalIndex;
  final BasePlanModel plan;
}
