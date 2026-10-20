import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

enum PlanBenefitType { data, talkMins, sms, bonusData, intlTalkText, mms }

class PlanBenefit extends Equatable {
  const PlanBenefit({
    required this.type,
    required this.label,
    required this.value,
    required this.sub,
    required this.sourceIdentifier,
    this.destination = '',
  });

  final PlanBenefitType type;
  final String label;
  final String value;
  final String sub;

  /// Retained for guest-only icon selection and prioritization. Never render it.
  final String sourceIdentifier;
  final String destination;

  String get displayText {
    if (value == 'Unlimited') return 'Unlimited $label';
    if (label.endsWith('minutes') || label.endsWith('messages')) {
      return '$value $label';
    }
    return <String>[
      value,
      sub,
      label,
    ].where((part) => part.trim().isNotEmpty).join(' ');
  }

  @override
  List<Object?> get props => [
    type,
    label,
    value,
    sub,
    sourceIdentifier,
    destination,
  ];
}

class GuestPlanDisplayModel extends Equatable {
  const GuestPlanDisplayModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.formattedPrice,
    required this.basePrice,
    required this.vatAmount,
    required this.description,
    required this.highlights,
    required this.benefits,
    this.destination = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String formattedPrice;
  final double basePrice;
  final double vatAmount;
  final String description;
  final List<PlanBenefit> highlights;
  final List<PlanBenefit> benefits;
  final String destination;

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    price,
    formattedPrice,
    basePrice,
    vatAmount,
    description,
    highlights,
    benefits,
    destination,
  ];
}

class GuestPurchasePlanAddOnsRouteArgs extends Equatable {
  const GuestPurchasePlanAddOnsRouteArgs({
    required this.phoneNumber,
    required this.selectedPlan,
    this.selectedBasePlan,
    this.existingActivePlan,
  });

  final String phoneNumber;
  final GuestPlanDisplayModel selectedPlan;

  /// Raw catalog model for the plan the user picked. Carries
  /// `availableBoltOns` + `frequency` so the dedicated add-ons screen
  /// can show the real bolt-on tiles and compute the expiry date.
  /// Nullable so legacy call sites keep working.
  final BasePlanModel? selectedBasePlan;

  /// The entered number's currently-active primary plan (from
  /// /Guest/existingplans), used to compute the start date of the
  /// about-to-activate plan. When null, the plan starts today.
  final BasePlanModel? existingActivePlan;

  @override
  List<Object?> get props => [
    phoneNumber,
    selectedPlan,
    selectedBasePlan,
    existingActivePlan,
  ];
}
