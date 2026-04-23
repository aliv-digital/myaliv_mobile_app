import '../../PlanScreen/models/base_plan_model.dart';
import '../model/plan_purchase_add_on_models.dart';

class PlanPurchasePlanAddOnsRepository {
  // Future: replace these with API calls
  Future<PlanPurchaseActivePlanSummary> fetchActivePlan() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const PlanPurchaseActivePlanSummary(
      label: 'active plan',
      name: 'liberty70',
      autoRenew: true,
      activeDateLabel: 'active',
      activeDate: '20/08/24',
      expireDateLabel: 'expire',
      expireDate: '19/09/24',
    );
  }

  Future<PlanPurchaseFairUsePolicy> fetchFairUsePolicy() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return const PlanPurchaseFairUsePolicy(
      title: 'fair use policy',
      description:
          "add-ons can only be added to your active primary plan and expires when it ends. "
          "if you don't want an add-on select skip.",
    );
  }

  Future<List<PlanPurchaseAddOnItem>> fetchAddOns() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      // PlanPurchaseAddOnItem(
      //   id: 'a1',
      //   title: 'liberty data 1',
      //   subtitleLabel: 'data balance',
      //   subtitleValue: '1gb',
      //   price: 5.00,
      // ),
      // PlanPurchaseAddOnItem(
      //   id: 'a2',
      //   title: 'liberty data 2',
      //   subtitleLabel: 'data balance',
      //   subtitleValue: '2gb',
      //   price: 5.00, vatAmount: null,
      // ),
      // PlanPurchaseAddOnItem(
      //   id: 'a3',
      //   title: 'liberty data 3',
      //   subtitleLabel: 'data balance',
      //   subtitleValue: '3gb',
      //   price: 5.00,
      // ),
    ];
  }

  List<PlanPurchaseAddOnItem> mapAvailableBoltOnsToAddOnItems(
    BasePlanModel? primaryPlan,
  ) {
    if (primaryPlan == null) {
      return const <PlanPurchaseAddOnItem>[];
    }

    return primaryPlan.availableBoltOns.map(
          (addOnPlan) => PlanPurchaseAddOnItem(
            id: addOnPlan.planId,
            title: addOnPlan.planName,
            subtitleLabel: _buildAddOnLabel(addOnPlan),
            subtitleValue: _buildAddOnValue(addOnPlan),
            price: addOnPlan.planAmount,
            vatAmount: addOnPlan.vatAmount,
          ),
        )
        .toList(growable: false);
  }

  String _buildAddOnLabel(BasePlanModel addOnPlan) {
    final firstBucket = addOnPlan.planBuckets.isEmpty ? null : addOnPlan.planBuckets.first;

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

  String _buildAddOnValue(BasePlanModel addOnPlan) {
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

  String _formatWholeOrDecimal(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
