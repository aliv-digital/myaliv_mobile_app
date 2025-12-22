enum PlanBenefitType {
  data,
  talkMins,
  sms,
  bonusData,
  intlTalkText,
  mms,
}

class PlanBenefit {
  final PlanBenefitType type;
  final String label; // data / talk mins / sms ...
  final String value; // 1 / 30 / 300
  final String sub;   // GB / local talk mins / local text ...

  const PlanBenefit({
    required this.type,
    required this.label,
    required this.value,
    required this.sub,
  });
}

class PlanModel {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String description; // expanded text
  final List<PlanBenefit> benefits; // scrollable row

  const PlanModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.description,
    required this.benefits,
  });
}
