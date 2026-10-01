import 'package:equatable/equatable.dart';

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
  });

  final String phoneNumber;
  final GuestPlanDisplayModel selectedPlan;

  @override
  List<Object?> get props => [phoneNumber, selectedPlan];
}
