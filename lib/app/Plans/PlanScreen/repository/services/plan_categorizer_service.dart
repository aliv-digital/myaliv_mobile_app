import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_type.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_frequency.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_group.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/payment_option.dart';

/// Service to categorize plans based on their attributes
class PlanCategorizerService {
  /// Determine which category a plan belongs to
  ///
  /// Categorization rules:
  /// - Daily: PlanType=P, Frequency=D
  /// - Weekly: PlanType=P, Frequency=W
  /// - Monthly: PlanType=P, Frequency=M (not MiFi)
  /// - Roaming: PlanType=A, PlanGroup=roaming (prepaid)
  /// - RoamEasy: PlanType=A, PlanGroup=roameasy
  /// - MiFi: PlanType=P, PlanGroup=mifi (30 day)
  /// - LibertyGlobal: PlanType=A, PlanGroup=liberty global
  /// - PostpaidRoaming: PlanType=A, PlanGroup=roaming, PaymentOption=postpay
  ///                    OR PlanType=S with roaming-related content (postpay users)
  /// - Unknown: Doesn't match any criteria
  PlanCategory categorize(Map<String, dynamic> plan) {
    final planType = PlanType.parse(plan['PlanType']);
    final frequency = PlanFrequency.parse(plan['Frequency']);
    final planGroup = PlanGroup.parse(plan['PlanGroup']);
    final paymentOption = PaymentOption.parse(plan['PaymentOption']);

    // Primary Plans (PlanType = P)
    if (planType == PlanType.primary) {
      return _categorizePrimaryPlan(frequency, planGroup);
    }

    // Add-on Plans (PlanType = A)
    if (planType == PlanType.addon) {
      return _categorizeAddonPlan(planGroup, paymentOption);
    }

    // Special/Subscription Plans (PlanType = S)
    if (planType == PlanType.special) {
      return _categorizeSpecialPlan(plan, planGroup, paymentOption);
    }

    // Unknown plan type
    return PlanCategory.unknown;
  }

  /// Categorize primary plans by frequency and group
  PlanCategory _categorizePrimaryPlan(
    PlanFrequency? frequency,
    PlanGroup? planGroup,
  ) {
    // MiFi plans (special case - has planGroup)
    if (planGroup == PlanGroup.mifi) {
      return PlanCategory.mifi;
    }

    // Frequency-based plans
    switch (frequency) {
      case PlanFrequency.daily:
        return PlanCategory.daily;
      case PlanFrequency.weekly:
        return PlanCategory.weekly;
      case PlanFrequency.monthly:
        return PlanCategory.monthly;
      case null:
        return PlanCategory.unknown;
    }
  }

  /// Categorize add-on plans by group and payment option
  PlanCategory _categorizeAddonPlan(
    PlanGroup? planGroup,
    PaymentOption? paymentOption,
  ) {
    switch (planGroup) {
      case PlanGroup.roaming:
        // Distinguish between prepaid and postpaid roaming
        if (paymentOption == PaymentOption.postpay) {
          return PlanCategory.postpaidRoaming;
        }
        return PlanCategory.roaming;

      case PlanGroup.roameasy:
        return PlanCategory.roameasy;

      case PlanGroup.libertyGlobal:
        return PlanCategory.libertyGlobal;

      case PlanGroup.promotionBonusDataAddons:
        // Bonus data add-ons (shouldn't be Type A, but handle it)
        if (paymentOption == PaymentOption.postpay) {
          return PlanCategory.postpaidRoaming;
        }
        return PlanCategory.roaming;

      case PlanGroup.testStandalonePlans:
        // Test plans - mark as unknown to hide from regular users
        return PlanCategory.unknown;

      case PlanGroup.mifi:
        return PlanCategory.unknown;

      case null:
        return PlanCategory.unknown;
    }
  }

  /// Categorize special/subscription plans (PlanType = S)
  PlanCategory _categorizeSpecialPlan(
    Map<String, dynamic> plan,
    PlanGroup? planGroup,
    PaymentOption? paymentOption,
  ) {
    // Check for promotion/bonus roaming data add-ons
    if (planGroup == PlanGroup.promotionBonusDataAddons) {
      // These are bonus roaming data for postpay users
      if (paymentOption == PaymentOption.postpay) {
        return PlanCategory.postpaidRoaming;
      }
      return PlanCategory.roaming; // Prepaid bonus data
    }

    // Check for roaming-related special plans
    final planName = (plan['PlanName'] as String?)?.toLowerCase() ?? '';
    final planDescription = (plan['PlanDescription'] as String?)?.toLowerCase() ?? '';

    final isRoamingRelated = planName.contains('roam') ||
                             planDescription.contains('roam') ||
                             planGroup == PlanGroup.roaming;

    // Postpaid roaming special plans
    if (isRoamingRelated && paymentOption == PaymentOption.postpay) {
      return PlanCategory.postpaidRoaming;
    }

    // Check for Liberty Global plans
    if (planGroup == PlanGroup.libertyGlobal) {
      return PlanCategory.libertyGlobal;
    }

    // Other special plans default to unknown
    return PlanCategory.unknown;
  }

  /// Validate that a plan has minimum required fields
  bool isValidPlan(Map<String, dynamic> plan) {
    return plan.containsKey('PlanType') &&
        plan.containsKey('PlanID') &&  // Fixed: API uses 'PlanID' not 'PlanId'
        plan['PlanType'] != null &&
        plan['PlanID'] != null;
  }

  /// Get categorization metadata for debugging
  Map<String, dynamic> getCategoryMetadata(Map<String, dynamic> plan) {
    return {
      'planType': plan['PlanType'],
      'frequency': plan['Frequency'],
      'planGroup': plan['PlanGroup'],
      'paymentOption': plan['PaymentOption'],
      'category': categorize(plan).name,
    };
  }
}
