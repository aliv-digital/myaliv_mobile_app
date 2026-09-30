import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

import '../models/plan_model.dart';

class GuestPlanPresentationMapper {
  const GuestPlanPresentationMapper();

  GuestPlanDisplayModel map(BasePlanModel plan, {bool isRoamEasy = false}) {
    final destination = _destinationFor(plan, isRoamEasy: isRoamEasy);
    final benefits = plan.planBuckets
        .where((bucket) => !bucket.suppress)
        .map((bucket) => _mapBenefit(bucket, destination: destination))
        .whereType<PlanBenefit>()
        .toList(growable: false);
    final highlights = List<PlanBenefit>.of(benefits)
      ..sort(
        (left, right) => _priority(
          left,
          destination: destination,
        ).compareTo(_priority(right, destination: destination)),
      );
    final totalPrice = plan.planAmount + plan.vatAmount;

    return GuestPlanDisplayModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: _duration(plan.frequency),
      price: totalPrice,
      formattedPrice: '\$${totalPrice.toStringAsFixed(2)}',
      basePrice: plan.planAmount,
      vatAmount: plan.vatAmount,
      description: _plainText(
        plan.planDescription.trim().isNotEmpty
            ? plan.planDescription
            : plan.planDetails,
      ),
      highlights: List<PlanBenefit>.unmodifiable(highlights.take(3)),
      benefits: List<PlanBenefit>.unmodifiable(benefits),
      destination: destination,
    );
  }

  List<GuestPlanDisplayModel> mapAll(
    Iterable<BasePlanModel> plans, {
    bool isRoamEasy = false,
  }) => plans
      .map((plan) => map(plan, isRoamEasy: isRoamEasy))
      .toList(growable: false);

  PlanBenefit? _mapBenefit(
    BasePlanBucketModel bucket, {
    required String destination,
  }) {
    if (!bucket.unlimited && bucket.amount <= 0) return null;

    final identifier = bucket.bucketUnit.trim().toLowerCase();
    final name = bucket.name.trim().toLowerCase();
    if (identifier.isEmpty && name.isEmpty) return null;
    final type = _benefitType(identifier, name);
    final destinationLabel = _destinationLabel(identifier, destination);
    final label = _label(
      identifier,
      name,
      type,
      destinationLabel: destinationLabel,
    );

    return PlanBenefit(
      type: type,
      label: label,
      value: bucket.unlimited ? 'Unlimited' : _amountText(bucket.amount),
      sub: bucket.unlimited ? '' : _unit(bucket.unit, type),
      sourceIdentifier: identifier,
      destination: destinationLabel,
    );
  }

  PlanBenefitType _benefitType(String identifier, String name) {
    if (identifier.contains('ldi_us_canada')) {
      return PlanBenefitType.intlTalkText;
    }
    if (identifier.contains('mms_nat_us')) return PlanBenefitType.mms;
    if (identifier.contains('data') || name.contains('data')) {
      return name.contains('bonus')
          ? PlanBenefitType.bonusData
          : PlanBenefitType.data;
    }
    if (identifier.contains('sms') ||
        identifier.contains('mms') ||
        name.contains('text') ||
        name.contains('message')) {
      return PlanBenefitType.sms;
    }
    return PlanBenefitType.talkMins;
  }

  String _label(
    String identifier,
    String name,
    PlanBenefitType type, {
    required String destinationLabel,
  }) {
    if (destinationLabel.isNotEmpty && type == PlanBenefitType.data) {
      return '$destinationLabel data';
    }
    if (identifier.contains('ldi_us_canada')) return 'US/Canada minutes';
    if (identifier.contains('mms_nat_us')) return 'Aliv-to-Aliv messages';
    if (_isGenericRoamingData(identifier, name)) return 'Roaming data';

    return switch (type) {
      PlanBenefitType.data => 'Data',
      PlanBenefitType.bonusData => 'Bonus data',
      PlanBenefitType.intlTalkText => 'US/Canada minutes',
      PlanBenefitType.mms => 'Aliv-to-Aliv messages',
      PlanBenefitType.sms =>
        _isOnNet(identifier) ? 'Aliv-to-Aliv messages' : 'Messages',
      PlanBenefitType.talkMins =>
        _isOnNet(identifier) ? 'Aliv-to-Aliv minutes' : 'Minutes',
    };
  }

  String _destinationFor(BasePlanModel plan, {required bool isRoamEasy}) {
    if (!isRoamEasy) return '';
    final value = '${plan.planName} ${plan.planDescription}'.toLowerCase();
    if (value.contains('carib')) return 'Caribbean';
    if (value.contains('europe') || value.contains(' uk ')) {
      return 'UK & Europe';
    }
    if (value.contains('usa') ||
        value.contains('us & can') ||
        value.contains('us/can')) {
      return 'USA & Canada';
    }
    return '';
  }

  String _destinationLabel(String identifier, String destination) {
    if (identifier.contains('carib_data') ||
        (identifier.contains('data') && identifier.contains('caribbean'))) {
      return 'Caribbean';
    }
    if (identifier.contains('uk_europe_data') ||
        (identifier.contains('data') && identifier.contains('uk_europe'))) {
      return 'UK & Europe';
    }
    if (identifier.contains('roaming_data') ||
        identifier.contains('data_roam_as_home')) {
      return destination == 'USA & Canada' ? destination : 'Roaming';
    }
    return '';
  }

  int _priority(PlanBenefit benefit, {required String destination}) {
    if (destination.isNotEmpty && benefit.destination == destination) return 0;
    if (benefit.destination.isNotEmpty && benefit.destination != 'Roaming') {
      return 5;
    }
    return switch (benefit.type) {
      PlanBenefitType.data => 10,
      PlanBenefitType.bonusData => 15,
      PlanBenefitType.talkMins => 20,
      PlanBenefitType.intlTalkText => 21,
      PlanBenefitType.sms => 30,
      PlanBenefitType.mms => 31,
    };
  }

  String _duration(String frequency) =>
      switch (frequency.trim().toUpperCase()) {
        'D' => '1 day',
        '3' => '3 days',
        '5' => '5 days',
        'W' => '7 days',
        'T' => '10 days',
        'B' || 'H' => '14 days',
        'M' => '30 days',
        'S' => '60 days',
        'N' => '90 days',
        'A' => '365 days',
        final value when value.isNotEmpty => value,
        _ => '',
      };

  String _unit(String unit, PlanBenefitType type) {
    final normalized = unit.trim();
    if (normalized.isNotEmpty) {
      final lower = normalized.toLowerCase();
      if (lower == 'text' || lower == 'sms' || lower == 'mms') {
        return 'messages';
      }
      if (lower == 'minute' || lower == 'minutes') return 'minutes';
      if (lower == 'gb') return 'GB';
      if (lower == 'mb') return 'MB';
      return normalized;
    }
    return switch (type) {
      PlanBenefitType.data || PlanBenefitType.bonusData => 'GB',
      PlanBenefitType.talkMins || PlanBenefitType.intlTalkText => 'minutes',
      PlanBenefitType.sms || PlanBenefitType.mms => 'messages',
    };
  }

  String _amountText(double amount) => amount == amount.truncateToDouble()
      ? amount.toInt().toString()
      : amount.toString();

  bool _isGenericRoamingData(String identifier, String name) =>
      identifier.contains('roaming_data') ||
      identifier.contains('data_roam_as_home') ||
      name.contains('roaming data');

  bool _isOnNet(String identifier) =>
      identifier.contains('onnet') || identifier.contains('nat_us');

  String _plainText(String value) => value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\s*\n\s*'), '\n')
      .trim();
}
